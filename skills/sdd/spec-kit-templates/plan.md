# spec-kit: Plan Template

## Purpose
Generate a technical implementation plan from a feature specification.

## Required Inputs
- `spec.md`: Feature specification with user stories, FRs, and ACs
- `constitution.md`: Project architectural principles

## Output Artifacts
All artifacts must be written to the same directory as spec.md.

### plan.md
Must include:

#### Phase -1: Pre-Implementation Gates
- **Simplicity Gate**: Are we introducing unnecessary complexity? Can we reuse existing code?
- **Anti-Abstraction Gate**: Are we wrapping frameworks unnecessarily?
- **Integration-First Gate**: Are we mocking things we shouldn't?
- **Constitution Compliance**: Check each article, mark OK or NEEDS ATTENTION

#### Implementation Plan
For each layer of changes:
- Exact file paths to create or modify
- Method signatures
- Key logic description
- Dependencies on other layers

### contracts/api-spec.json
OpenAPI-style contract for each endpoint:
```json
{
  "path": "/api/v1/resource",
  "method": "GET",
  "parameters": {},
  "responses": {}
}
```

### data-model.md (if needed)
- New tables/columns
- Relationships
- Indexes

### research.md (if needed)
- Technology choices and rationale
- Library comparisons
