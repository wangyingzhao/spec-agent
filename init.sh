#!/bin/bash
# platform-agent-skills init.sh
# 项目初始化：在目标项目目录执行，完成 SDD 工作流脚手架搭建
# 用法: /path/to/platform-agent-skills/init.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SDD_SKILLS_DIR="$SCRIPT_DIR/skills/sdd"
PROJECT_DIR="$(pwd)"

# ─────────────────────────────────────────
# Serena helper functions
# ─────────────────────────────────────────
_write_serena_mcp_json() {
    local mcp_json="$1"
    local project_dir="$2"

    if [ -f "$mcp_json" ]; then
        if grep -q '"serena"' "$mcp_json"; then
            echo "  Skip: .mcp.json 中已有 serena 配置"
            return
        fi
        if command -v python3 &>/dev/null; then
            python3 - "$mcp_json" "$project_dir" <<'PYEOF'
import json, sys
mcp_file, project_dir = sys.argv[1], sys.argv[2]
with open(mcp_file) as f:
    cfg = json.load(f)
cfg.setdefault("mcpServers", {})
cfg["mcpServers"]["serena"] = {
    "command": "uvx",
    "args": ["--from", "serena", "serena-mcp", "--project-root", project_dir],
    "env": {}
}
with open(mcp_file, "w") as f:
    json.dump(cfg, f, indent=2, ensure_ascii=False)
    f.write("\n")
PYEOF
            echo "  Done: serena 已合并到已有 .mcp.json"
        else
            echo "  Warn: 已有 .mcp.json，请手动添加 serena 配置（见 docs/QUICKSTART.md）"
        fi
    else
        cat > "$mcp_json" <<MCPEOF
{
  "mcpServers": {
    "serena": {
      "command": "uvx",
      "args": ["--from", "serena", "serena-mcp", "--project-root", "${project_dir}"],
      "env": {}
    }
  }
}
MCPEOF
        echo "  Done: 创建 .mcp.json（serena MCP 配置）"
    fi
}

_setup_serena() {
    local project_dir="$1"
    local mcp_json="$project_dir/.mcp.json"

    if ! command -v uvx &>/dev/null && ! python3 -c "import serena" &>/dev/null 2>&1; then
        echo "  Warn: 未检测到 uvx 或 serena，跳过自动安装"
        echo "  手动安装: pip install serena 或 brew install uv"
        echo "  安装后重新运行 init.sh 完成索引初始化"
        _write_serena_mcp_json "$mcp_json" "$project_dir"
        return
    fi

    _write_serena_mcp_json "$mcp_json" "$project_dir"

    echo "  构建初始代码索引（serena index）..."
    if command -v uvx &>/dev/null; then
        if uvx --from serena serena index "$project_dir" 2>/dev/null; then
            echo "  Done: Serena 索引构建完成"
        else
            echo "  Done: .mcp.json 已写入；索引将在 Claude Code 首次连接时自动构建"
        fi
    else
        if python3 -m serena index "$project_dir" 2>/dev/null; then
            echo "  Done: Serena 索引构建完成"
        else
            echo "  Done: .mcp.json 已写入；索引将在 Claude Code 首次连接时自动构建"
        fi
    fi
}

# ─────────────────────────────────────────
# 主逻辑
# ─────────────────────────────────────────
echo "══════════════════════════════════════"
echo "  platform-agent-skills: 项目初始化"
echo "  目标项目: $PROJECT_DIR"
echo "══════════════════════════════════════"

# ─────────────────────────────────────────
# 前置检查：Claude Code /init
# ─────────────────────────────────────────
if [ ! -f "$PROJECT_DIR/CLAUDE.md" ] && [ ! -d "$PROJECT_DIR/.claude" ]; then
    echo ""
    echo "  ⚠  未检测到 CLAUDE.md 或 .claude/ 目录"
    echo "     建议先在 Claude Code 中执行 /init，让 AI 分析项目结构并生成项目描述。"
    echo "     sdd-init 将在此基础上追加 SDD 配置，两者互补。"
    echo ""
    if [ -t 0 ]; then
        printf "  跳过 /init，直接继续？[y/N] "
        read -r reply
        [[ "$reply" =~ ^[Yy]$ ]] || { echo "  已取消。请先在 Claude Code 中运行 /init 后再执行 sdd-init。"; exit 0; }
    fi
fi

# Step 1: 复制脚本
echo ""
echo "[1/7] 复制辅助脚本到 scripts/ ..."
mkdir -p "$PROJECT_DIR/scripts"
cp "$SDD_SKILLS_DIR/scripts/sdd-dashboard.sh" "$PROJECT_DIR/scripts/"
cp "$SDD_SKILLS_DIR/scripts/sdd-parallel.sh"  "$PROJECT_DIR/scripts/"
cp "$SDD_SKILLS_DIR/scripts/sdd-pipeline.sh"  "$PROJECT_DIR/scripts/"
chmod +x "$PROJECT_DIR/scripts/sdd-dashboard.sh"
chmod +x "$PROJECT_DIR/scripts/sdd-parallel.sh"
chmod +x "$PROJECT_DIR/scripts/sdd-pipeline.sh"
echo "  Done: scripts/sdd-{dashboard,parallel,pipeline}.sh"

# Step 2: 初始化 .specify/
echo ""
echo "[2/7] 初始化 .specify/ ..."
if [ ! -d "$PROJECT_DIR/.specify" ]; then
    if command -v specify &>/dev/null; then
        specify init . --ai claude 2>/dev/null || true
        echo "  Done: specify init 完成"
    else
        mkdir -p "$PROJECT_DIR/.specify/specs" \
                 "$PROJECT_DIR/.specify/memory" \
                 "$PROJECT_DIR/.specify/templates/commands"
        echo "  Done: 手动创建 .specify/ 目录结构（specify CLI 未安装）"
    fi
else
    echo "  Skip: .specify/ 已存在"
fi

# Step 3: 复制 spec-kit 模板
echo ""
echo "[3/7] 复制 spec-kit 模板到 .specify/templates/commands/ ..."
mkdir -p "$PROJECT_DIR/.specify/templates/commands"
cp "$SDD_SKILLS_DIR/spec-kit-templates/plan.md"      "$PROJECT_DIR/.specify/templates/commands/"
cp "$SDD_SKILLS_DIR/spec-kit-templates/tasks.md"     "$PROJECT_DIR/.specify/templates/commands/"
cp "$SDD_SKILLS_DIR/spec-kit-templates/implement.md" "$PROJECT_DIR/.specify/templates/commands/"
echo "  Done: .specify/templates/commands/{plan,tasks,implement}.md"

# Step 4: 创建运行时目录
echo ""
echo "[4/7] 创建运行时目录 ..."
mkdir -p "$PROJECT_DIR/.sdd/agents" "$PROJECT_DIR/.sdd/handoff"
echo "  Done: .sdd/agents/ 和 .sdd/handoff/"

# Step 5: 更新 CLAUDE.md
echo ""
echo "[5/7] 更新 CLAUDE.md ..."
CLAUDE_MD="$PROJECT_DIR/CLAUDE.md"
SDD_CONFIG_BLOCK="
## SDD Configuration

> SDD 技能包配置，供 /sdd:* 指令读取。填写你的项目实际命令。

- Test command: \`<your test command, e.g. pytest / npm test / go test ./...>\`
- Lint command: \`<your lint command, e.g. ruff check src/ / eslint src/>\`
- Test framework: <pytest / jest / vitest / go-test / rspec / ...>
- Source directory: <src/ / lib/ / app/ / ...>
"
if [ ! -f "$CLAUDE_MD" ]; then
    {
        echo "# Project"
        echo ""
        echo "## Overview"
        echo "<TODO: describe your project>"
        printf "%s" "$SDD_CONFIG_BLOCK"
    } > "$CLAUDE_MD"
    echo "  Done: 创建 CLAUDE.md（含 SDD Configuration）"
elif ! grep -q "## SDD Configuration" "$CLAUDE_MD"; then
    printf "%s" "$SDD_CONFIG_BLOCK" >> "$CLAUDE_MD"
    echo "  Done: 追加 ## SDD Configuration 到 CLAUDE.md"
else
    echo "  Skip: ## SDD Configuration 已存在于 CLAUDE.md"
fi

# Step 6: 同步规范文档 + 种子宪法
echo ""
echo "[6/7] 同步规范文档 + 初始化 spec 宪法 ..."
STANDARDS_SRC="$SCRIPT_DIR/docs/standard"
STANDARDS_DEST="$PROJECT_DIR/.specify/memory/standards"
CONSTITUTION="$PROJECT_DIR/.specify/memory/constitution.md"

if [ -d "$STANDARDS_SRC" ] && [ -n "$(ls "$STANDARDS_SRC"/*.md 2>/dev/null)" ]; then
    mkdir -p "$STANDARDS_DEST"
    cp "$STANDARDS_SRC"/*.md "$STANDARDS_DEST/"
    COUNT=$(ls "$STANDARDS_DEST"/*.md | wc -l | tr -d ' ')
    echo "  Done: $COUNT 份规范文档 → .specify/memory/standards/"

    STANDARDS_LIST=""
    for f in "$STANDARDS_DEST"/*.md; do
        fname=$(basename "$f")
        STANDARDS_LIST="${STANDARDS_LIST}  - standards/${fname}\n"
    done

    STANDARDS_BLOCK="
## Included Standards

> 以下规范由 platform-agent-skills init.sh 自动同步，作为本项目 Spec 宪法的约束依据。

${STANDARDS_LIST}
> 在 Claude Code 中运行 \`/speckit.constitution\` 可基于上述规范和当前项目结构重新生成完整宪法。
"
    if [ ! -f "$CONSTITUTION" ]; then
        {
            echo "# Project Constitution"
            echo ""
            echo "> 由 platform-agent-skills init.sh 创建的种子宪法。"
            echo "> 请在 Claude Code 中运行 \`/speckit.constitution\` 完成完整初始化。"
            printf "%s" "$STANDARDS_BLOCK"
        } > "$CONSTITUTION"
        echo "  Done: 创建种子 constitution.md（含规范引用）"
    elif ! grep -q "## Included Standards" "$CONSTITUTION"; then
        printf "%s" "$STANDARDS_BLOCK" >> "$CONSTITUTION"
        echo "  Done: 追加规范引用到已有 constitution.md"
    else
        echo "  Done: 规范文件已更新（constitution.md 引用不变）"
    fi
else
    echo "  Skip: docs/standard/ 为空，跳过规范同步"
fi

# Step 7: Serena 代码索引
echo ""
echo "[7/7] 配置 Serena 代码索引 ..."
_setup_serena "$PROJECT_DIR"

echo ""
echo "══════════════════════════════════════"
echo "  项目初始化完成！"
echo ""
echo "  Next steps:"
echo "  1. 编辑 CLAUDE.md，填写 ## SDD Configuration 中的命令"
echo "  2. 在 Claude Code 中运行 \`/speckit.constitution\` 完成宪法初始化"
echo "  3. 创建第一个 Spec："
echo "       mkdir .specify/specs/001-my-feature"
echo "       # 编写 .specify/specs/001-my-feature/spec.md"
echo "  4. 启动 Claude Code，运行："
echo "       /sdd:plan .specify/specs/001-my-feature"
echo "══════════════════════════════════════"
