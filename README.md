# platform-agent-skills

语言无关的 SDD（Spec-Driven Development）技能包，提供 6 条 `/sdd:*` Claude Code 自定义指令，适用于任意技术栈的项目。

## 快速开始

### Step 1：全局安装（一次，所有项目生效）

```bash
git clone git@git.bilibili.co:efficiency-ai/platform-agent-skills.git
cd platform-agent-skills
./install.sh
```

安装后，在任意项目的 Claude Code 中输入 `/sdd:` 即可看到全部指令。

### Step 2：项目初始化（在目标项目目录执行）

```bash
cd my-project
sdd-init
```

### Step 3：填写项目配置

编辑 `CLAUDE.md` 中的 `## SDD Configuration` 段，填入项目的测试命令、Lint 命令等。

### Step 4：开始 SDD 流程

> **前置流程（spec-kit 原生指令）**
> 在执行 `/sdd:*` 之前，需先用 spec-kit 完成需求阶段：
> ```
> /speckit.specify   # 从需求描述生成结构化 spec.md
> /speckit.clarify   # 需求确认与澄清
> ```
> 需求确认后，`.specify/specs/` 下会生成一个 Spec 目录，例如 `.specify/specs/001-my-feature`。
> - `.specify/specs/` 是 spec-kit 管理所有 Feature Spec 的根目录
> - `001-my-feature` 是本次功能的编号 + 名称，其中包含 `spec.md`（需求）等文件
> - `/sdd:*` 指令以该目录为输入，完成从方案到实现的全过程

```
/sdd:plan .specify/specs/001-my-feature
/sdd:tasks .specify/specs/001-my-feature
/sdd:implement .specify/specs/001-my-feature
/sdd:review .specify/specs/001-my-feature
/sdd:status .specify/specs/001-my-feature
```

---

## 指令列表

### /sdd:* 指令（本仓库提供）

负责**技术实现阶段**：从 Spec 生成方案、拆解任务、TDD 实现、审查、进度汇报。

| 指令 | 角色 | 职责 |
|------|------|------|
| `/sdd:plan <spec-dir>` | 猫头鹰（Architect） | 从 spec.md 生成技术方案 |
| `/sdd:tasks <spec-dir>` | 啄木鸟（TaskBreaker） | 将方案拆解为有序任务清单 |
| `/sdd:implement <spec-dir>` | 海狸（Dev） | TDD 循环实现所有任务 |
| `/sdd:review <spec-dir>` | 哈士奇（Review） | 代码质量与 Spec 一致性审查 |
| `/sdd:status <spec-dir>` | 鹦鹉（Status） | 汇报全流程进度 |
| `/sdd:parallel <stories>` | 章鱼（Orchestrator） | 为多 Story 搭建并行 worktree |

### spec-kit 原生指令（需单独安装 specify-cli）

负责**需求阶段**：需求 Spec 的生成、完善与审核。

| 指令 | 职责 |
|------|------|
| `/speckit.specify` | 从需求描述生成结构化 spec.md |
| `/speckit.clarify` | 需求确认与澄清 |
| `/speckit.constitution` | 基于项目结构和规范生成/更新宪法 |

> 完整的 spec-kit 指令文档见 specify-cli 官方文档。

---

## 目录结构

```
platform-agent-skills/
├── README.md
├── install.sh                         # 全局安装（一次性）
├── init.sh                            # 项目初始化（sdd-init，每项目执行一次）
├── skills/
│   └── sdd/
│       ├── README.md
│       ├── commands/                  # 6 条 Claude Code 自定义指令
│       ├── scripts/                   # 辅助脚本
│       └── spec-kit-templates/        # spec-kit 模板
└── docs/
    ├── QUICKSTART.md
    ├── CLAUDE-md-template.md
    ├── standard/                      # 项目规范文档（接口/DB/代码规范）
    └── patterns/
```

---

## 文档

- [快速入门](docs/QUICKSTART.md)
- [SDD 技能包说明](skills/sdd/README.md)
- [CLAUDE.md 模板](docs/CLAUDE-md-template.md)
- [模式：API 功能开发](docs/patterns/pattern-a-api.md)
- [模式：轻量功能](docs/patterns/pattern-a-lite.md)
- [模式：重构](docs/patterns/pattern-c-refactoring.md)
