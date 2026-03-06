#!/bin/bash
# 用法: ./scripts/sdd-dashboard.sh
# 展示所有 Story 的 SDD 开发进度

echo "══════════════════════════════════════"
echo "  SDD Dashboard — $(date '+%Y-%m-%d %H:%M')"
echo "══════════════════════════════════════"

echo ""
echo "Worktrees:"
git worktree list 2>/dev/null | while read line; do echo "  $line"; done
echo ""

for d in .specify/specs/*/; do
    [ -f "$d/spec.md" ] || continue

    s=$(basename "$d")
    echo "─────────────────────────────────"
    echo "Story: $s"

    [ -f "$d/plan.md" ]   && echo "  [x] plan.md"     || echo "  [ ] plan.md"
    [ -d "$d/contracts" ] && echo "  [x] contracts/"   || echo "  [ ] contracts/"
    [ -f "$d/tasks.md" ]  && echo "  [x] tasks.md"     || echo "  [ ] tasks.md"

    if [ -f "$d/tasks.md" ]; then
        total=$(grep -c "^### Task" "$d/tasks.md" 2>/dev/null || echo 0)
        echo "  Tasks: $total total"
    fi

    echo ""
done
