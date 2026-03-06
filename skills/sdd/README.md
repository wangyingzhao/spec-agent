# SDD 技能包

Spec-Driven Development（规格驱动开发）技能包，提供 6 条 Claude Code 自定义指令。

## 工作流程

```
spec.md
  │
  ▼
/sdd:plan        猫头鹰（Architect）生成技术方案
  │
  ▼
/sdd:tasks       啄木鸟（TaskBreaker）拆解任务清单
  │
  ▼
/sdd:implement   海狸（Dev）TDD 实现 + 哈士奇（Review）审查
  │
  ▼
/sdd:review      哈士奇独立审查（可选，已集成在 implement 中）
  │
  ▼
/sdd:status      鹦鹉汇报全流程进度
```

并行开发：
```
/sdd:parallel 001-feature-a 002-feature-b 003-feature-c
```

## 指令说明

### `/sdd:plan <spec-dir>`
**猫头鹰（Architect Agent）**

- 使用 Opus 模型深度思考
- 探索项目代码结构（与语言/框架无关）
- 生成 `plan.md`、`contracts/api-spec.json`、`data-model.md`
- 包含 Phase -1 前置门禁（简洁性、反过度抽象、宪法合规）

### `/sdd:tasks <spec-dir>`
**啄木鸟（TaskBreaker Agent）**

- 读取 plan.md 和 contracts/
- 生成有序任务清单，标注依赖关系
- 标记可并行执行的 Task `[P]`
- 精确到文件路径

### `/sdd:implement <spec-dir>`
**海狸（Dev Agent）**

- TDD 循环：Red → Green → Refactor
- 测试由 Codex 编写（可降级为海狸自己写）
- 支持并行 Task（使用子 Agent）
- 自动触发哈士奇进程审查
- 最多 3 轮修复循环

### `/sdd:review <spec-dir>`
**哈士奇（Review Agent）**

- SDD 一致性验证（AC 覆盖、契约匹配、宪法合规）
- Codex 协助代码安全/质量审查
- 输出结构化审查报告

### `/sdd:status <spec-dir>`
**鹦鹉（Status Agent）**

- 检查所有 SDD 产物是否存在
- 读取 Agent 实时状态（海狸/哈士奇）
- 运行测试并统计结果（读取 CLAUDE.md SDD Configuration）
- 检查 AC 覆盖率

### `/sdd:parallel <stories>`
**领队**

- 为每个 Story 创建独立 git worktree
- 复制 Spec 和宪法文件
- 输出多 Tab 并行开发启动指南

## 语言无关性

所有指令均从 `CLAUDE.md` 的 `## SDD Configuration` 段读取项目配置：

```markdown
## SDD Configuration
- Test command: `<your test command>`
- Lint command: `<your lint command>`
- Test framework: <framework name>
- Source directory: <source dir>
```

使用 `init.sh project` 在项目中自动生成此配置段。

## 辅助脚本

| 脚本 | 用途 |
|------|------|
| `scripts/sdd-dashboard.sh` | 查看所有 Story 的产物状态 |
| `scripts/sdd-parallel.sh <stories>` | 快速创建多个并行 worktree |
| `scripts/sdd-pipeline.sh <spec-dir>` | 自动运行 Plan + Tasks 阶段 |
