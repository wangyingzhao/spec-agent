# SDD 技能包快速入门

## 前提条件

- [Claude Code](https://claude.ai/code) 已安装
- （可选）[specify](https://specify.dev) 已安装（用于管理 spec-kit）
- （可选）[Codex CLI](https://github.com/openai/codex) 已安装（用于 TDD Red 阶段和审查）
- （可选）[uv](https://github.com/astral-sh/uv) 已安装（用于 serena 代码索引；`brew install uv`）

---

## 安装（5 分钟）

### Step 1：克隆技能包

```bash
git clone git@git.bilibili.co:efficiency-ai/platform-agent-skills.git ~/platform-agent-skills
```

### Step 2：全局安装 SDD 指令

```bash
cd ~/platform-agent-skills
./install.sh
```

这会：
- 将 6 个 `.md` 指令复制到 `~/.claude/commands/sdd/`（全局生效）
- 将 `docs/standard/` 规范文档同步到 `~/.claude/sdd-standards/`（供宪法初始化参考）
- 检测依赖并引导安装：`specify-cli`（项目初始化需要）、`uv`（serena 索引需要）

**验证：**
```bash
ls ~/.claude/commands/sdd/
# plan.md  tasks.md  implement.md  review.md  status.md  parallel.md

ls ~/.claude/sdd-standards/
# 接口规范.md  数据库建表_命名_操作等规范.md  ...
```

---

## 项目初始化（每个新项目执行一次）

### Step 3：在目标项目中初始化

```bash
cd your-project
sdd-init
```

这会依次完成 7 个步骤：

| 步骤 | 内容 |
|------|------|
| [1/7] | 复制 3 个辅助脚本到 `scripts/` |
| [2/7] | 初始化 `.specify/` 目录（如未存在，运行 `specify init`） |
| [3/7] | 复制 spec-kit 模板到 `.specify/templates/commands/` |
| [4/7] | 创建 `.sdd/agents/` 和 `.sdd/handoff/` 目录 |
| [5/7] | 在 `CLAUDE.md` 中追加 `## SDD Configuration` 段 |
| [6/7] | 同步 `docs/standard/` 规范 → `.specify/memory/standards/`，写入种子宪法 |
| [7/7] | 配置 serena MCP（写 `.mcp.json`），触发初始代码索引 |

### Step 4：填写项目配置

编辑 `CLAUDE.md`，填写 `## SDD Configuration` 段：

```markdown
## SDD Configuration
- Test command: `pytest`                  # 改为你的测试命令
- Lint command: `ruff check src/`         # 改为你的 Lint 命令
- Test framework: pytest                  # pytest / jest / go-test / ...
- Source directory: src/                  # src/ / lib/ / app/ / ...
```

### Step 5：完成宪法初始化

`sdd-init` 已将规范文档写入 `.specify/memory/standards/` 并创建了种子 `constitution.md`。启动 Claude Code 后运行一次：

```
/speckit.constitution
```

这会让 AI 读取项目代码结构 + `standards/` 规范 → 生成完整、定制化的宪法。

> 后续修改了 `docs/standard/` 中的规范文档，重新运行 `sdd-init` 刷新文件，然后再次执行 `/speckit.constitution` 即可。

---

## 指令分工

SDD 工作流由两套指令共同覆盖，各司其职：

| 阶段 | 指令来源 | 指令 | 职责 |
|------|---------|------|------|
| 需求阶段 | spec-kit 原生 | `/speckit.spec` | 从需求描述生成结构化 spec.md |
| 需求阶段 | spec-kit 原生 | `/speckit.review` | 审核 spec.md 的完整性与一致性 |
| 需求阶段 | spec-kit 原生 | `/speckit.constitution` | 生成/更新项目宪法 |
| 实现阶段 | 本仓库 `/sdd:*` | `/sdd:plan` | 从 spec.md 生成技术方案 |
| 实现阶段 | 本仓库 `/sdd:*` | `/sdd:tasks` | 拆解任务清单 |
| 实现阶段 | 本仓库 `/sdd:*` | `/sdd:implement` | TDD 实现 |
| 实现阶段 | 本仓库 `/sdd:*` | `/sdd:review` | 代码审查 |
| 实现阶段 | 本仓库 `/sdd:*` | `/sdd:status` | 进度汇报 |

> **需求 Spec 的生成和审核，使用 spec-kit 原生指令（`/speckit.*`）；
> 技术实现阶段，使用本仓库的 `/sdd:*` 指令。**

---

## 使用流程

### 写 Spec

在 `.specify/specs/` 下创建 Feature 目录，然后用 spec-kit 生成和审核：

```bash
mkdir .specify/specs/001-my-feature
```

```
/speckit.spec .specify/specs/001-my-feature     # 生成 spec.md
/speckit.review .specify/specs/001-my-feature   # 审核 spec.md
```

### 运行 SDD 流程

在 Claude Code 中依次执行：

```
/sdd:plan .specify/specs/001-my-feature
```
> 猫头鹰（Opus）生成技术方案，包含接口契约和数据模型

```
/sdd:tasks .specify/specs/001-my-feature
```
> 啄木鸟拆解任务清单，标注依赖和并行任务

（审阅 plan.md 和 tasks.md 后）

```
/sdd:implement .specify/specs/001-my-feature
```
> 海狸 TDD 实现，自动触发哈士奇审查

（可选）查看进度：

```
/sdd:status .specify/specs/001-my-feature
```

---

## 并行开发（多 Story）

```bash
./scripts/sdd-pipeline.sh .specify/specs/001-feature-a   # 生成方案和任务
./scripts/sdd-pipeline.sh .specify/specs/002-feature-b
```

然后：

```
/sdd:parallel 001-feature-a 002-feature-b
```

按提示在多个终端 Tab 中并行开发。

---

## 常见问题

**Q: Codex 不可用怎么办？**
A: 海狸会自动降级为自己编写测试，哈士奇会独立完成审查，功能完整。

**Q: 指令里找不到 `/sdd:` 前缀？**
A: 确认已运行 `./install.sh`，并检查 `~/.claude/commands/sdd/` 目录是否存在。

**Q: specify 未安装怎么办？**
A: `install.sh` 会询问是否自动安装（`npm install -g specify-cli`）。也可手动安装后再执行 `sdd-init`。若实在不想装，`sdd-init` 会退而手动创建 `.specify/` 目录结构。

**Q: 如何适配非 Python 项目？**
A: 在 `CLAUDE.md` 的 `## SDD Configuration` 中填写正确的测试命令和 Lint 命令即可，指令本身与语言无关。

**Q: serena 没有安装怎么办？**
A: `sdd-init` 会打印安装指引并跳过索引，`.mcp.json` 仍会写入。安装 serena 后重新执行 `sdd-init` 即可补跑索引。安装方式：`brew install uv && uvx --from serena serena-mcp --help`。

**Q: 项目已有 `.mcp.json`，会被覆盖吗？**
A: 不会。脚本检测到已有文件时，会用 Python 合并 `serena` 配置到已有 `mcpServers` 中，不影响其他 MCP 服务。

**Q: 规范更新了如何同步？**
A: 修改 `docs/standard/` 后重新执行 `sdd-init`，规范文件会刷新到 `.specify/memory/standards/`。然后在 Claude Code 中重跑 `/speckit.constitution` 使宪法生效。

**Q: `constitution.md` 和 `standards/` 有什么关系？**
A: `standards/` 是从本仓库同步的原始规范文件（接口规范、DB 规范等）。`constitution.md` 是 `/speckit.constitution` 基于这些规范 + 项目代码结构生成的**项目级约束宪法**，是 SDD 指令的实际参考依据。
