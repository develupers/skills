#!/usr/bin/env bash

# Speckit Workflow State Detection Script
# Outputs JSON with current workflow state

set -e

# Get repository root
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$REPO_ROOT"

# Get current branch
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")

# Check if on feature branch (pattern: ###-feature-name)
IS_FEATURE_BRANCH=false
FEATURE_NAME=""
FEATURE_NUMBER=""
if [[ "$CURRENT_BRANCH" =~ ^([0-9]{3})-(.+)$ ]]; then
    IS_FEATURE_BRANCH=true
    FEATURE_NUMBER="${BASH_REMATCH[1]}"
    FEATURE_NAME="${BASH_REMATCH[2]}"
fi

# Define paths
SPECS_DIR="$REPO_ROOT/specs"
SPECIFY_DIR="$REPO_ROOT/.specify"
CONSTITUTION="$SPECIFY_DIR/memory/constitution.md"

# Check constitution exists
HAS_CONSTITUTION=false
[[ -f "$CONSTITUTION" ]] && HAS_CONSTITUTION=true

# Feature-specific paths (if on feature branch)
FEATURE_DIR=""
HAS_SPEC=false
HAS_PLAN=false
HAS_RESEARCH=false
HAS_DATA_MODEL=false
HAS_CONTRACTS=false
HAS_QUICKSTART=false
HAS_TASKS=false
HAS_CHECKLIST=false

if $IS_FEATURE_BRANCH; then
    FEATURE_DIR="$SPECS_DIR/$CURRENT_BRANCH"
    [[ -f "$FEATURE_DIR/spec.md" ]] && HAS_SPEC=true
    [[ -f "$FEATURE_DIR/plan.md" ]] && HAS_PLAN=true
    [[ -f "$FEATURE_DIR/research.md" ]] && HAS_RESEARCH=true
    [[ -f "$FEATURE_DIR/data-model.md" ]] && HAS_DATA_MODEL=true
    [[ -d "$FEATURE_DIR/contracts" && -n "$(ls -A "$FEATURE_DIR/contracts" 2>/dev/null)" ]] && HAS_CONTRACTS=true
    [[ -f "$FEATURE_DIR/quickstart.md" ]] && HAS_QUICKSTART=true
    [[ -f "$FEATURE_DIR/tasks.md" ]] && HAS_TASKS=true
    [[ -f "$FEATURE_DIR/checklist.md" ]] && HAS_CHECKLIST=true
fi

# List all existing features
EXISTING_FEATURES=$(ls -1 "$SPECS_DIR" 2>/dev/null | grep -E '^[0-9]{3}-' | tr '\n' ',' | sed 's/,$//')

# Determine workflow phase
PHASE="unknown"
NEXT_COMMAND=""
NEXT_REASON=""

if ! $HAS_CONSTITUTION; then
    PHASE="0-constitution"
    NEXT_COMMAND="/speckit.constitution"
    NEXT_REASON="No project constitution found. Start by establishing development principles."
elif ! $IS_FEATURE_BRANCH; then
    PHASE="1-create-branch"
    NEXT_COMMAND="git checkout -b ###-feature-name"
    NEXT_REASON="Not on a feature branch. Create one with pattern ###-feature-name (e.g., 007-new-feature)."
elif ! $HAS_SPEC; then
    PHASE="2-specify"
    NEXT_COMMAND="/speckit.specify"
    NEXT_REASON="Feature branch exists but no spec.md. Define requirements and user stories."
elif ! $HAS_PLAN; then
    PHASE="3-plan"
    NEXT_COMMAND="/speckit.plan"
    NEXT_REASON="Spec complete. Create technical implementation plan."
elif ! $HAS_TASKS; then
    PHASE="4-tasks"
    NEXT_COMMAND="/speckit.tasks"
    NEXT_REASON="Plan complete. Generate actionable task breakdown."
else
    PHASE="5-implement"
    NEXT_COMMAND="/speckit.implement"
    NEXT_REASON="Tasks ready. Execute implementation."
fi

# Output JSON
cat << EOF
{
  "branch": "$CURRENT_BRANCH",
  "isFeatureBranch": $IS_FEATURE_BRANCH,
  "featureNumber": "$FEATURE_NUMBER",
  "featureName": "$FEATURE_NAME",
  "featureDir": "$FEATURE_DIR",
  "hasConstitution": $HAS_CONSTITUTION,
  "hasSpec": $HAS_SPEC,
  "hasPlan": $HAS_PLAN,
  "hasResearch": $HAS_RESEARCH,
  "hasDataModel": $HAS_DATA_MODEL,
  "hasContracts": $HAS_CONTRACTS,
  "hasQuickstart": $HAS_QUICKSTART,
  "hasTasks": $HAS_TASKS,
  "hasChecklist": $HAS_CHECKLIST,
  "existingFeatures": "$EXISTING_FEATURES",
  "phase": "$PHASE",
  "nextCommand": "$NEXT_COMMAND",
  "nextReason": "$NEXT_REASON"
}
EOF
