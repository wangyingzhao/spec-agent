# Pattern A-Lite：轻量功能开发

适用于：无数据模型变更的简单功能（纯业务逻辑、配置项、工具函数等）

---

## 使用场景

- 新增计算逻辑或工具函数
- 修改现有接口的业务规则
- 添加配置项或特性开关
- 无需新增数据表的功能

## 与 Pattern A 的区别

| 特征 | Pattern A | Pattern A-Lite |
|------|-----------|----------------|
| 数据模型变更 | 有 | 无 |
| contracts/ | 必需 | 视情况（如修改接口则需要） |
| data-model.md | 必需 | 不需要 |
| Opus 推理深度 | 深度分析 | 快速方案 |
| Task 数量 | 5-8 个 | 2-4 个 |

## 流程（可跳过 pipeline 直接手动执行）

```
spec.md
  │
  ├─ /sdd:plan      猫头鹰快速生成方案（可省略 data-model.md）
  │
  ├─ /sdd:tasks     啄木鸟拆解（通常 2-4 个 Task）
  │
  └─ /sdd:implement 海狸实现（自动审查）
```

## spec.md 推荐结构（精简版）

```markdown
# Feature: <功能名>

## Goal
<一句话说明目标>

## Acceptance Criteria (AC)
- AC-1: <具体可验证的行为>
- AC-2: ...

## Out of Scope
- <不包含的内容>
```

## 最佳实践

- 如果不需要 contracts/，在 plan.md 中说明原因
- Task 粒度控制在"一个文件一个 Task"
- 如果修改已有接口，仍需要更新 contracts/
