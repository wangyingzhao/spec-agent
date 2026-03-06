#!/bin/bash
# 用法: ./scripts/sdd-parallel.sh 001-feature-a 002-feature-b
# 一键为多个 Story 创建 Worktree，准备并行开发

set -e

for story in "$@"; do
    spec_dir=".specify/specs/$story"
    [ -d "$spec_dir" ] || { echo "ERROR: Spec 目录不存在: $spec_dir"; exit 1; }

    wt=".claude/worktrees/$story"

    if [ ! -d "$wt" ]; then
        echo "Creating worktree: $wt (branch: $story)"
        git worktree add "$wt" -b "$story" 2>/dev/null || \
        git worktree add "$wt" "$story"
    fi

    # 复制 Spec 和宪法到 worktree
    mkdir -p "$wt/.specify/specs" "$wt/.specify/memory"
    cp -r "$spec_dir" "$wt/.specify/specs/"
    cp .specify/memory/constitution.md "$wt/.specify/memory/"

    echo "  Ready: cd $wt && claude"
done

echo ""
echo "All worktrees ready. Open a terminal tab for each story."
echo ""
echo "Each tab runs the same commands:"
echo "  /sdd:plan <spec-dir>"
echo "  /sdd:tasks <spec-dir>"
echo "  /sdd:implement <spec-dir>"
echo "  /sdd:review <spec-dir>"
echo "  /sdd:status <spec-dir>"
