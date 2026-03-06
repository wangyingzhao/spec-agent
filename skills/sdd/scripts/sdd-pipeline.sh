#!/bin/bash
# 用法: ./scripts/sdd-pipeline.sh .specify/specs/001-my-feature
# 半自动流水线：Plan (Opus) + Tasks 自动生成，Implement 暂停等你审阅

set -e
SPEC_DIR="$1"
[ -f "$SPEC_DIR/spec.md" ] || { echo "ERROR: spec.md not found in $SPEC_DIR"; exit 1; }

echo "══════════════════════════════════════"
echo "  SDD Pipeline: $(basename $SPEC_DIR)"
echo "══════════════════════════════════════"

# Phase 1: Plan (Opus)
echo ""
echo "[1/2] Generating plan (Opus)..."
claude -p "Read .specify/templates/commands/plan.md for format requirements. Read $SPEC_DIR/spec.md and .specify/memory/constitution.md. Explore the project codebase structure to understand architecture patterns (use Glob and Read tools). Read CLAUDE.md ## SDD Configuration for tech stack info. Generate plan.md, contracts/api-spec.json, and data-model.md (if needed) in $SPEC_DIR/. Include Phase -1 gates with constitution compliance." \
  --model opus \
  --allowedTools "Read,Glob,Grep,Write,Agent" \
  --max-turns 30
echo "  Done: $SPEC_DIR/plan.md"

# Phase 2: Tasks
echo ""
echo "[2/2] Generating tasks..."
claude -p "Read .specify/templates/commands/tasks.md for format requirements. Read $SPEC_DIR/spec.md, plan.md, contracts/. Generate tasks.md in $SPEC_DIR/ with dependency ordering and [P] parallel markers." \
  --allowedTools "Read,Write" \
  --max-turns 10
echo "  Done: $SPEC_DIR/tasks.md"

echo ""
echo "══════════════════════════════════════"
echo "  Plan + Tasks ready for review:"
echo "    $SPEC_DIR/plan.md"
echo "    $SPEC_DIR/contracts/"
echo "    $SPEC_DIR/tasks.md"
echo ""
echo "  Next: start Claude Code and run:"
echo "    /sdd:implement $SPEC_DIR"
echo "══════════════════════════════════════"
