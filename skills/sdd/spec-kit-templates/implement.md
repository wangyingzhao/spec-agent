# spec-kit: Implement Template

## Purpose
Implement tasks from tasks.md following project conventions and TDD.

## Required Inputs
- `spec.md`: Feature specification
- `plan.md`: Technical implementation plan
- `contracts/`: API contracts
- `tasks.md`: Task breakdown
- `constitution.md`: Project principles

## Implementation Rules

### Code Style
- Follow existing project conventions (check neighboring files)
- Use the same patterns as existing code (routing, error handling, response format)
- Respect the layer boundaries defined in constitution.md
- Use the test framework and source directory specified in CLAUDE.md ## SDD Configuration

### TDD Cycle
For each task:
1. **Red**: Write a failing test first
2. **Green**: Write the minimum code to make it pass
3. **Refactor**: Clean up while keeping tests green

### Validation Checkpoints
After each task:
- [ ] All related tests pass
- [ ] Code follows constitution.md principles
- [ ] API signatures match contracts/
- [ ] No lint errors (run lint command from CLAUDE.md ## SDD Configuration)

### Completion Criteria
- All tasks in tasks.md are implemented
- All ACs from spec.md have corresponding passing tests
- Full test suite passes with no regressions
- AC coverage matrix is documented
