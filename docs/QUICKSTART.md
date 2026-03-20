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
- 将 6 个 `/sdd:*` 指令复制到 `~/.claude/commands/sdd/`（全局生效）
- 提取 speckit 指令（`/speckit.specify`、`/speckit.clarify` 等）到 `~/.claude/commands/`（全局生效）
- 将 `docs/standard/` 规范文档同步到 `~/.claude/sdd-standards/`（供宪法初始化参考）
- 注册 `sdd-init` 全局命令并自动配置 PATH
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

这会依次完成 8 个步骤：

| 步骤 | 内容 |
|------|------|
| [1/8] | 复制 3 个辅助脚本到 `scripts/` |
| [2/8] | 初始化 `.specify/` 目录（如未存在，运行 `specify init`） |
| [3/8] | 复制 spec-kit 模板到 `.specify/templates/commands/` |
| [4/8] | 创建 `.sdd/agents/` 和 `.sdd/handoff/` 目录 |
| [5/8] | 在 `CLAUDE.md` 中追加 `## SDD Configuration` 段 |
| [6/8] | 同步 `docs/standard/` 规范 → `.specify/memory/standards/`，写入种子宪法 |
| [7/8] | 配置 serena MCP（写 `.mcp.json`），触发初始代码索引 |
| [8/8] | 写入 `.claude/settings.json`，授权 `Bash(codex *)` 工具权限；检测 codex CLI |

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
| 需求阶段 | spec-kit 原生 | `/speckit.specify` | 从需求描述生成结构化 spec.md |
| 需求阶段 | spec-kit 原生 | `/speckit.clarify` | 需求确认与澄清 |
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
/speckit.specify .specify/specs/001-my-feature   # 生成 spec.md
/speckit.clarify .specify/specs/001-my-feature  # 需求确认与澄清
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

**Q: `/sdd:review` 提示"Codex 不在线"？**
A: 两步排查：① 运行 `codex --version` 确认 CLI 已安装（未安装：`npm install -g @openai/codex`）；② 检查项目 `.claude/settings.json` 是否包含 `"Bash(codex *)"` 权限（`sdd-init` 会自动写入；也可手动添加）。

**Q: 指令里找不到 `/sdd:` 前缀？**
A: 确认已运行 `./install.sh`，并检查 `~/.claude/commands/sdd/` 目录是否存在。

**Q: specify 未安装怎么办？**
A: `install.sh` 会询问是否自动安装（优先使用 `uv tool install specify-cli`，也支持 `pipx` 和 `pip3`）。也可手动安装后再执行 `sdd-init`。若实在不想装，`sdd-init` 会退而手动创建 `.specify/` 目录结构。

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

---

## DevOps 指令（/devops:*）

`/devops:*` 指令由 **信鸽** 驱动，对接 Bilibili EP Agileflow 平台，负责触发构建发布和查询流水线状态。

### 前提：配置凭证

`./init.sh` 会自动在 `~/.claude/agileflow.env` 中创建凭证文件（权限 600，不进 git），前三项已预填，**只需补填 Cookie**：

```bash
# ~/.claude/agileflow.env（以下三项已由 init.sh 预填，无需修改）
AGILEFLOW_CLIENT_ID=97322054661        # /devops:pipeline 使用（Access-Token 鉴权）
AGILEFLOW_CLIENT_SECRET=d8853ef964dc47308c12de10d48b7819
AGILEFLOW_PERM_CODE=ee_platform
AGILEFLOW_COOKIE=                      # /devops:deploy 使用，← 唯一需要手动填写的项
```

> 在浏览器登录 agileflow.bilibili.co → 打开 DevTools → Network → 复制任意请求的 `Cookie` 请求头值填入。

---

### /devops:deploy — 一键发布

```
/devops:deploy [appid] [branch] [env] [选项]
```

**所有参数均可省略**，信鸽会自动推断：

| 参数 | 默认值来源 |
|------|-----------|
| `appid` | 当前目录 `env.properties` 中的 `app_id=` 字段 |
| `branch` | 当前 git 分支（`git branch --show-current`） |
| `env` | `uat` |

**示例：**

```bash
/devops:deploy                          # 全默认，从 env.properties 取 appid，当前分支，uat
/devops:deploy --env prod               # 仅改环境
/devops:deploy ops.foo.bar              # 手动指定 appid
/devops:deploy ops.foo.bar main prod    # 完整指定
/devops:deploy --force                  # 跳过"进行中检查"，强制发布
```

**发布前自动检查：** 信鸽会先查询是否有正在运行的发布流水线。若存在，**阻止本次发布**并展示进行中的流水线详情；加 `--force` 可跳过检查强制执行。

**env.properties 格式：**
```properties
app_id=ops.flow-api.mercury
```
若文件中有多个 `app_id=`，信鸽会列出所有候选值让你确认。

---

### /devops:pipeline — 流水线查询

```
/devops:pipeline <子命令> [参数]
```

| 子命令 | 说明 | 示例 |
|--------|------|------|
| `status <appid>` | 查看最近一条发布流水线状态 | `/devops:pipeline status ops.foo.bar` |
| `list <appid>` | 列出历史流水线记录 | `/devops:pipeline list ops.foo.bar` |
| `detail <pipeline_id>` | 查看指定流水线详情 | `/devops:pipeline detail 12345` |
| `configs <appid>` | 查看流水线配置 | `/devops:pipeline configs ops.foo.bar` |
| `auth` | 验证凭证是否有效 | `/devops:pipeline auth` |
| `check` | 检查内网连接 | `/devops:pipeline check` |
| `help` | 显示帮助 | `/devops:pipeline help` |

---

### 典型发布流程

```
/devops:deploy                          # 触发发布（全默认）
/devops:pipeline status ops.foo.bar    # 查看发布进度
```
