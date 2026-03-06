# spec-kit: Tasks Template

## Purpose
Break down a plan.md into executable, dependency-ordered tasks.

## Required Inputs
- `spec.md`: Feature specification
- `plan.md`: Technical implementation plan
- `contracts/`: API contracts

## Output: tasks.md

### Task Format
Each task must include:
- **Title**: Imperative verb + description
- **File**: Exact file path(s) to create or modify
- **Depends**: Task numbers this depends on (or "none")
- **Parallel**: `[P]` if this task can run in parallel with other [P] tasks
- **Contract**: Which FR from spec.md this implements
- **Validates**: Which AC(s) from spec.md this covers

### Ordering Rules
1. Data layer tasks first (models, repositories)
2. Business logic tasks second (services)
3. API layer tasks third (routers/controllers)
4. Test tasks can be marked [P] if they only depend on completed implementation tasks

### Example
```markdown
### Task 1: Add Article model with tag relationship
- File: src/models/article.py
- Depends: none
- Parallel: [P]
- Contract: FR-1
- Validates: —
```
