#!/bin/bash
# platform-agent-skills install.sh
# 全局安装：复制 SDD 指令、同步规范文档、检测并引导安装依赖（specify / uv / serena）
# 用法: ./install.sh

set -e   # 严格模式（关键操作失败即退出）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SDD_SKILLS_DIR="$SCRIPT_DIR/skills/sdd"

echo "══════════════════════════════════════"
echo "  platform-agent-skills: 全局安装"
echo "══════════════════════════════════════"

# 1. 复制 SDD 指令
DEST="$HOME/.claude/commands/sdd"
mkdir -p "$DEST"

echo ""
echo "复制 SDD 指令到 $DEST ..."
cp "$SDD_SKILLS_DIR/commands/plan.md"       "$DEST/plan.md"
cp "$SDD_SKILLS_DIR/commands/tasks.md"      "$DEST/tasks.md"
cp "$SDD_SKILLS_DIR/commands/implement.md"  "$DEST/implement.md"
cp "$SDD_SKILLS_DIR/commands/review.md"     "$DEST/review.md"
cp "$SDD_SKILLS_DIR/commands/status.md"     "$DEST/status.md"
cp "$SDD_SKILLS_DIR/commands/parallel.md"   "$DEST/parallel.md"

echo ""
echo "已安装以下指令（全局可用）："
ls "$DEST" | while read f; do echo "  /sdd:${f%.md}"; done

# 2. 同步规范文档
STANDARDS_SRC="$SCRIPT_DIR/docs/standard"
if [ -d "$STANDARDS_SRC" ] && [ -n "$(ls "$STANDARDS_SRC"/*.md 2>/dev/null)" ]; then
    echo ""
    echo "同步规范文档到 ~/.claude/sdd-standards/ ..."
    STANDARDS_DEST="$HOME/.claude/sdd-standards"
    mkdir -p "$STANDARDS_DEST"
    cp "$STANDARDS_SRC"/*.md "$STANDARDS_DEST/"
    echo "  Done: $(ls "$STANDARDS_DEST"/*.md | wc -l | tr -d ' ') 份规范文档 → $STANDARDS_DEST"
fi

# ─────────────────────────────────────────
# 3. 注册全局命令 sdd-init
# ─────────────────────────────────────────
BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"
ln -sf "$SCRIPT_DIR/init.sh" "$BIN_DIR/sdd-init"
echo ""
echo "注册全局命令 sdd-init → $BIN_DIR/sdd-init"

# 检测 ~/.local/bin 是否在 PATH 中
if echo "$PATH" | tr ':' '\n' | grep -qx "$BIN_DIR"; then
    echo "  Done: sdd-init 已可用（$BIN_DIR 在 PATH 中）"
else
    echo "  Done: 软链接已创建，但 $BIN_DIR 不在 PATH 中"
    # 检测 shell 并给出对应配置建议
    SHELL_RC=""
    case "$SHELL" in
        */zsh)  SHELL_RC="~/.zshrc" ;;
        */bash) SHELL_RC="~/.bashrc" ;;
        *)      SHELL_RC="~/.profile" ;;
    esac
    echo "  请将以下内容加入 $SHELL_RC："
    echo "    export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo "  然后执行: source $SHELL_RC"
fi

# ─────────────────────────────────────────
# 4. 依赖检测与引导安装（可选，失败不中断）
# ─────────────────────────────────────────
set +e
echo ""
echo "──────────────────────────────────────"
echo "  依赖检测"
echo "──────────────────────────────────────"

# [1] specify CLI（spec-kit，项目初始化时用于 specify init）
echo ""
if command -v specify &>/dev/null; then
    echo "  [✓] specify   $(specify --version 2>/dev/null || echo '已安装')"
else
    echo "  [✗] specify   未安装（项目初始化时需要，用于 specify init）"
    if [ -t 0 ]; then
        printf "      是否现在安装 specify-cli？[y/N] "
        read -r reply
        if [[ "$reply" =~ ^[Yy]$ ]]; then
            if command -v npm &>/dev/null; then
                npm install -g specify-cli
                command -v specify &>/dev/null \
                    && echo "  [✓] specify 安装成功：$(specify --version 2>/dev/null || echo 'ok')" \
                    || echo "  [!] 安装完成，请重启终端后验证"
            else
                echo "  [!] 未检测到 npm，请先安装 Node.js: https://nodejs.org"
            fi
        else
            echo "      跳过。手动安装: npm install -g specify-cli"
        fi
    else
        echo "      手动安装: npm install -g specify-cli"
    fi
fi

# [2] uv（serena 依赖）
echo ""
if command -v uv &>/dev/null; then
    echo "  [✓] uv        $(uv --version 2>/dev/null | head -1)"
else
    echo "  [✗] uv        未安装（serena 代码索引通过 uvx 运行）"
    if [ -t 0 ]; then
        # 交互式终端：询问是否自动安装
        printf "      是否现在安装 uv？[y/N] "
        read -r reply
        if [[ "$reply" =~ ^[Yy]$ ]]; then
            echo "      安装中..."
            if command -v brew &>/dev/null; then
                brew install uv
            else
                curl -LsSf https://astral.sh/uv/install.sh | sh
                # 将 uv 加入当前会话 PATH
                export PATH="$HOME/.cargo/bin:$HOME/.local/bin:$PATH"
            fi
            if command -v uv &>/dev/null; then
                echo "  [✓] uv 安装成功：$(uv --version 2>/dev/null | head -1)"
            else
                echo "  [!] uv 安装完成，请重启终端后再运行 sdd-init"
            fi
        else
            echo "      跳过。手动安装: brew install uv"
        fi
    else
        echo "      手动安装: brew install uv  或  curl -LsSf https://astral.sh/uv/install.sh | sh"
    fi
fi

# [3] serena（通过 uvx 按需拉取）
echo ""
if command -v uvx &>/dev/null; then
    echo "  [✓] serena    将通过 uvx 在 sdd-init 中按需拉取（无需单独安装）"
else
    echo "  [-] serena    uv 就绪后可用，init.sh 执行时自动拉取"
fi

echo ""
echo "══════════════════════════════════════"
echo "  安装完成！"
echo ""
echo "  Next steps:"
echo "  1. 在目标项目目录执行："
echo "       cd your-project"
echo "       sdd-init"
echo ""
echo "  2. 填写 CLAUDE.md 中的 ## SDD Configuration"
echo ""
echo "  3. 在 Claude Code 中运行 /speckit.constitution 完成宪法初始化"
echo ""
echo "  4. 启动 Claude Code，输入 /sdd: 开始使用"
echo "══════════════════════════════════════"
