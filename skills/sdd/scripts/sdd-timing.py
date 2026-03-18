#!/usr/bin/env python3
"""SDD 耗时统计 — 解析 Claude Code 会话 JSONL 日志，输出跨会话耗时汇总。

用法: python3 sdd-timing.py "$(pwd)"
"""

import json
import os
import re
import sys
from collections import defaultdict
from datetime import datetime, timezone
from pathlib import Path

# 超过此间隔（秒）的空闲不计入活跃时间
IDLE_THRESHOLD = 300  # 5 min

STEP_LABELS = {
    "plan": "猫头鹰·plan",
    "tasks": "啄木鸟·tasks",
    "implement": "海狸·implement",
    "parallel": "海狸·parallel",
    "review": "哈士奇·review",
    "status": "鹦鹉·status",
}


def resolve_project_dir(pwd: str) -> Path | None:
    """将 pwd 映射到 ~/.claude/projects/ 下的项目目录。"""
    projects_root = Path.home() / ".claude" / "projects"
    if not projects_root.is_dir():
        return None

    # 主映射：将 / 替换为 -
    mapped = pwd.replace("/", "-")
    candidate = projects_root / mapped
    if candidate.is_dir():
        return candidate

    # 后备 1：尝试用 unix 用户名替换 $HOME 中的用户目录名
    import getpass
    username = getpass.getuser()
    home = str(Path.home())
    if pwd.startswith(home):
        rel = pwd[len(home):]  # e.g. /develop/neptune
        alt_mapped = f"-Users-{username}{rel.replace('/', '-')}"
        candidate = projects_root / alt_mapped
        if candidate.is_dir():
            return candidate

    # 后备 2：提取 pwd 中 home 之后的相对路径部分，匹配任意项目目录的后缀
    rel_suffix = ""
    if pwd.startswith(home):
        rel_suffix = pwd[len(home):].replace("/", "-")  # e.g. -develop-neptune
    else:
        rel_suffix = mapped  # 完整路径

    for d in projects_root.iterdir():
        if d.is_dir() and d.name.endswith(rel_suffix):
            return d

    return None


def parse_timestamp(ts: str) -> datetime | None:
    try:
        return datetime.fromisoformat(ts.replace("Z", "+00:00"))
    except (ValueError, AttributeError):
        return None


def parse_sessions(project_dir: Path):
    """解析项目下所有 JSONL 文件，返回 (sessions, sdd_steps) 。"""
    sessions = []  # [(session_file, wall_seconds, active_seconds, first_ts, last_ts)]
    sdd_steps: dict[str, dict] = defaultdict(lambda: {"active": 0.0, "count": 0})
    other_active = 0.0

    for jsonl_file in sorted(project_dir.glob("*.jsonl")):
        messages = []
        with open(jsonl_file, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    obj = json.loads(line)
                except json.JSONDecodeError:
                    continue
                msg_type = obj.get("type")
                if msg_type not in ("user", "assistant"):
                    continue
                ts = parse_timestamp(obj.get("timestamp", ""))
                if ts is None:
                    continue
                # 检测 sdd 命令
                sdd_cmd = None
                if msg_type == "user":
                    content = obj.get("message", {}).get("content", "")
                    if isinstance(content, str):
                        m = re.search(r"<command-name>/sdd:(\w+)</command-name>", content)
                        if m:
                            sdd_cmd = m.group(1)
                messages.append({"type": msg_type, "ts": ts, "sdd_cmd": sdd_cmd})

        if len(messages) < 2:
            continue

        # 去重：同一秒内同类型只保留一条（多 content block 会产生重复行）
        messages.sort(key=lambda x: x["ts"])
        deduped = []
        for msg in messages:
            if deduped and msg["type"] == deduped[-1]["type"] and \
               abs((msg["ts"] - deduped[-1]["ts"]).total_seconds()) < 1:
                # 保留有 sdd_cmd 的那条
                if msg["sdd_cmd"] and not deduped[-1]["sdd_cmd"]:
                    deduped[-1] = msg
                continue
            deduped.append(msg)
        messages = deduped

        if len(messages) < 2:
            continue

        first_ts = messages[0]["ts"]
        last_ts = messages[-1]["ts"]
        wall_seconds = (last_ts - first_ts).total_seconds()

        # 计算活跃时间和步骤耗时
        # 策略：sdd 步骤从命令调用到下一个 user 消息（非命令本身）结束
        session_active = 0.0
        current_step = None
        step_active_accum = 0.0

        for i in range(1, len(messages)):
            gap = (messages[i]["ts"] - messages[i - 1]["ts"]).total_seconds()
            is_active = gap <= IDLE_THRESHOLD
            new_cmd = messages[i].get("sdd_cmd")
            is_user_msg = messages[i]["type"] == "user" and not new_cmd

            if is_active:
                session_active += gap

            # 结算当前步骤：遇到新 sdd 命令或非命令的 user 消息
            if current_step and (new_cmd or is_user_msg):
                if is_active:
                    step_active_accum += gap
                sdd_steps[current_step]["active"] += step_active_accum
                step_active_accum = 0.0
                current_step = None
            elif current_step and is_active:
                step_active_accum += gap

            # 开始新步骤
            if new_cmd:
                sdd_steps[new_cmd]["count"] += 1
                current_step = new_cmd
                step_active_accum = 0.0

        # 结算最后一个步骤
        if current_step:
            sdd_steps[current_step]["active"] += step_active_accum

        sessions.append((jsonl_file.name, wall_seconds, session_active, first_ts, last_ts))

    # 最终计算
    total_wall = sum(s[1] for s in sessions)
    total_active = sum(s[2] for s in sessions)
    step_active_sum = sum(v["active"] for v in sdd_steps.values())
    other_active = total_active - step_active_sum

    latest_ts = max((s[4] for s in sessions), default=None)

    return sessions, sdd_steps, total_wall, total_active, other_active, latest_ts


def fmt_duration(seconds: float) -> str:
    """格式化秒数为 Xh Ym 或 Xm Ys。"""
    seconds = max(0, seconds)
    if seconds >= 3600:
        h = int(seconds // 3600)
        m = int((seconds % 3600) // 60)
        return f"{h}h {m}m"
    else:
        m = int(seconds // 60)
        s = int(seconds % 60)
        return f"{m}m {s}s"


def main():
    if len(sys.argv) < 2:
        print("用法: python3 sdd-timing.py <project-path>", file=sys.stderr)
        sys.exit(1)

    pwd = sys.argv[1]
    project_dir = resolve_project_dir(pwd)

    if project_dir is None:
        print(f"未找到项目会话目录 (pwd={pwd})", file=sys.stderr)
        sys.exit(1)

    sessions, sdd_steps, total_wall, total_active, other_active, latest_ts = parse_sessions(project_dir)

    if not sessions:
        print("未找到有效会话数据")
        sys.exit(0)

    n = len(sessions)
    print(f"耗时统计 (跨会话汇总, {n} 个会话)")
    print(f"  总耗时:  {fmt_duration(total_wall)} (挂钟) / {fmt_duration(total_active)} (活跃)")

    # SDD 步骤明细
    ordered_keys = ["plan", "tasks", "implement", "parallel", "review", "status"]
    has_steps = any(k in sdd_steps for k in ordered_keys)
    if has_steps:
        print("  SDD 步骤:")
        for key in ordered_keys:
            if key not in sdd_steps:
                continue
            info = sdd_steps[key]
            label = STEP_LABELS.get(key, key)
            dur = fmt_duration(info["active"])
            cnt = info["count"]
            print(f"    {label:<20s} {dur:<12s} 共 {cnt} 次")

    # 未归入 SDD 步骤的其他交互
    if other_active > 0:
        print(f"  其他交互:             {fmt_duration(other_active)}")

    # 最近活动
    if latest_ts:
        local_str = latest_ts.astimezone().strftime("%Y-%m-%d %H:%M")
        print(f"  最近活动: {local_str}")


if __name__ == "__main__":
    main()
