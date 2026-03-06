# CLAUDE.md 模板

将以下内容添加到项目的 `CLAUDE.md` 文件中（由 `init.sh project` 自动追加）。

---

```markdown
## SDD Configuration

> SDD 技能包配置，供 /sdd:* 指令读取。
> 安装说明：https://git.bilibili.co/efficiency-ai/platform-agent-skills

- Test command: `<your test command, e.g. pytest / npm test / go test ./...>`
- Lint command: `<your lint command, e.g. ruff check src/ / eslint src/ / golangci-lint run>`
- Test framework: <pytest / jest / vitest / go-test / rspec / ...>
- Source directory: <src/ / lib/ / app/ / cmd/ / ...>
```

---

## 填写示例

### Python / FastAPI + pytest

```markdown
## SDD Configuration
- Test command: `pytest`
- Lint command: `ruff check src/`
- Test framework: pytest
- Source directory: src/
```

### Node.js / Express + Jest

```markdown
## SDD Configuration
- Test command: `npm test`
- Lint command: `eslint src/`
- Test framework: jest
- Source directory: src/
```

### Go

```markdown
## SDD Configuration
- Test command: `go test ./...`
- Lint command: `golangci-lint run`
- Test framework: go-test
- Source directory: cmd/
```

### TypeScript / Next.js + Vitest

```markdown
## SDD Configuration
- Test command: `npx vitest run`
- Lint command: `npx eslint src/`
- Test framework: vitest
- Source directory: src/
```

### Java / Spring Boot + Maven

```markdown
## SDD Configuration
- Test command: `mvn test`
- Lint command: `mvn checkstyle:check`
- Test framework: junit
- Source directory: src/main/java/
```

---

## 说明

`/sdd:implement` 和 `/sdd:status` 指令会读取 `## SDD Configuration` 中的以下字段：

| 字段 | 用途 |
|------|------|
| `Test command` | Step 6 全量测试、Step 4 Red/Green 验证 |
| `Lint command` | Step 6 Lint 检查 |
| `Test framework` | 告知 Codex 使用哪种测试框架编写测试 |
| `Source directory` | 引导 Codex/海狸 查找现有代码模式 |
