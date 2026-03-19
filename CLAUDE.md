# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 仓库用途

这是 **platform-agent-skills** 技能包仓库，本身不是一个应用项目，而是一套供其他项目使用的 Claude Code 自定义指令（skill）集合。核心产物是：

- `skills/sdd/commands/` — 6 条 `/sdd:*` 指令（`.md` 文件）
- `skills/agileflow/commands/agileflow.md` — `/agileflow` 指令
- `install.sh` — 全局安装脚本（将指令复制到 `~/.claude/commands/`）
- `init.sh` — 项目初始化脚本（在目标项目中创建 SDD 工作流脚手架）

## 安装与验证

```bash
# 全局安装（将所有指令注册到 ~/.claude/commands/）
./install.sh

# 验证安装结果
ls ~/.claude/commands/sdd/         # → 6 个 .md 文件
ls ~/.claude/commands/agileflow.md # → agileflow 指令
```

安装后在任意项目的 Claude Code 中输入 `/sdd:` 或 `/agileflow` 即可使用。

## 指令调用规则

Claude Code 的自定义指令寻址规则：

| 文件路径 | 调用方式 |
|---------|---------|
| `~/.claude/commands/sdd/plan.md` | `/sdd:plan <args>` |
| `~/.claude/commands/agileflow.md` | `/agileflow <args>` |

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

## Agileflow 指令

`/agileflow` 使用方式二鉴权（client_id + client_secret → Access-Token），凭证从目标项目 `CLAUDE.md` 的 `## Agileflow Configuration` 读取：

```markdown
## Agileflow Configuration
AGILEFLOW_CLIENT_ID=97322054661
AGILEFLOW_CLIENT_SECRET=d8853ef964dc47308c12de10d48b7819
AGILEFLOW_PERM_CODE=ee_platform
```
