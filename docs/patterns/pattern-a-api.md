# Pattern A：API 功能开发

适用于：新增 REST API 端点（有数据读写、业务逻辑、测试要求）

---

## 使用场景

- 新增 CRUD 接口
- 新增带业务逻辑的查询接口
- 需要数据模型变更的功能

## 流程

```
spec.md
  │
  ├─ /sdd:plan      猫头鹰生成完整方案（Opus，含接口契约 + 数据模型）
  │
  ├─ /sdd:tasks     啄木鸟拆解任务（数据层 → 业务层 → API 层）
  │
  ├─ /sdd:implement 海狸 TDD 实现（自动审查）
  │
  └─ /sdd:status    鹦鹉检查进度
```

## spec.md 推荐结构

```markdown
# Feature: <功能名>

## User Stories
As a <角色>, I want to <行为>, so that <价值>.

## Functional Requirements (FR)
- FR-1: ...
- FR-2: ...

## Acceptance Criteria (AC)
- AC-1: Given <条件>, when <操作>, then <结果>
- AC-2: ...

## Non-Functional Requirements
- Performance: ...
- Security: ...
```

## plan.md 产出物

- `plan.md`：分层实现方案（数据层、业务层、API 层）+ Phase -1 门禁
- `contracts/api-spec.json`：OpenAPI 风格接口契约
- `data-model.md`：数据模型变更说明

## 典型 Task 结构

```
Task 1: 新增数据模型/Schema（无依赖）[P]
Task 2: 新增 Repository/DAO 层（依赖 Task 1）
Task 3: 新增 Service 层（依赖 Task 2）
Task 4: 新增 Controller/Router（依赖 Task 3）
Task 5: 集成测试（依赖 Task 4）[P]
```

## 注意事项

- contracts/ 要在 implement 前确认，海狸严格按契约实现
- 数据模型变更需要在 constitution.md 中检查是否违反约束
- 集成测试建议标记 [P] 与其他 Story 并行
