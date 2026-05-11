# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 仓库用途

这是 **platform-agent-skills** 技能包仓库，本身不是一个应用项目，而是一套供其他项目使用的 Claude Code 自定义指令（skill）集合。核心产物是：

- `skills/sdd/commands/` — 6 条 `/sdd:*` 指令（`.md` 文件）
- `skills/devops/commands/` — 2 条 `/devops:*` 指令（`deploy.md` / `pipeline.md`）
- `install.sh` — 全局安装脚本（将指令复制到 `~/.claude/commands/`）
- `init.sh` — 项目初始化脚本（在目标项目中创建 SDD 工作流脚手架）

## 安装与验证

```bash
# 全局安装（将所有指令注册到 ~/.claude/commands/）
./install.sh

# 验证安装结果
ls ~/.claude/commands/sdd/      # → 6 个 .md 文件
ls ~/.claude/commands/devops/   # → deploy.md / pipeline.md
```

安装后在任意项目的 Claude Code 中输入 `/sdd:` 或 `/devops:` 即可使用。

## 指令调用规则

Claude Code 的自定义指令寻址规则：

| 文件路径 | 调用方式 |
|---------|---------|
| `~/.claude/commands/sdd/plan.md` | `/sdd:plan <args>` |
| `~/.claude/commands/devops/deploy.md` | `/devops:deploy <args>` |
| `~/.claude/commands/devops/pipeline.md` | `/devops:pipeline <args>` |

- **子目录下的文件**：`/目录名:文件名 <args>`
- **根目录下的文件**：`/文件名 <args>`

## SDD 指令工作流

每条指令接收一个 spec 目录路径作为参数（`$ARGUMENTS`），按顺序执行：

```
/speckit.specify   # 生成 spec.md（spec-kit 原生，需单独安装）
/sdd:plan          # 猫头鹰：生成技术方案 → plan.md
/sdd:tasks         # 啄木鸟：拆解任务 → tasks.md
/sdd:implement     # 海狸：TDD 实现（读取 CLAUDE.md ## SDD Configuration）
/sdd:review        # 哈士奇：代码质量审查
/sdd:status        # 鹦鹉：汇报进度
```

`/sdd:implement` 和 `/sdd:status` 会从目标项目的 `CLAUDE.md` 中读取 `## SDD Configuration`（测试命令、Lint 命令等），模板见 `docs/CLAUDE-md-template.md`。

## 修改指令后的更新

修改 `skills/` 下的 `.md` 文件后，需重新运行 `./install.sh` 使改动生效（脚本做简单的 `cp`，无构建步骤）。

## DevOps 指令（信鸽）

`/devops:deploy` 和 `/devops:pipeline` 对接 Internal Agileflow 平台，凭证存放于 `~/.claude/agileflow.env`（由 `init.sh` 自动创建，权限 600，不进 git）：

```bash
AGILEFLOW_CLIENT_ID=<your-client-id>       # pipeline 使用（Access-Token 鉴权）
AGILEFLOW_CLIENT_SECRET=<your-client-secret>
AGILEFLOW_PERM_CODE=<your-perm-code>
AGILEFLOW_COOKIE=                     # deploy 使用，从浏览器登录后复制
```

## TAPD 指令（书虫）

`/tapd` 对接 Internal TAPD 平台，凭证存放于 `~/.claude/tapd.env`（由 `init.sh` 自动创建，权限 600，不进 git）：

```bash
TAPD_API_USER=<your-tapd-user>         # 已预填
TAPD_API_PASSWORD=xxx                 # 已预填
TAPD_API_BASE_URL=https://tapd-api.example.com/tapd  # 已预填
TAPD_WORKSPACE_ID=                    # ← 填入项目 workspace_id
TAPD_USER_NICK=                       # ← 填入 TAPD 昵称
```

## TAPD 指令（书虫）

`/tapd` 对接 Internal TAPD 平台，凭证存放于 `~/.claude/tapd.env`（由 `init.sh` 自动创建，权限 600，不进 git）：

```bash
TAPD_API_USER=<your-tapd-user>         # 已预填
TAPD_API_PASSWORD=xxx                 # 已预填
TAPD_API_BASE_URL=https://tapd-api.example.com/tapd  # 已预填
TAPD_WORKSPACE_ID=                    # ← 填入项目 workspace_id
TAPD_USER_NICK=                       # ← 填入 TAPD 昵称
```
