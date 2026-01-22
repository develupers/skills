#!/usr/bin/env bash

# Git Flow State Detection Script
# Outputs JSON with current git flow state and available operations

set -e

# Get repository root
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "")

if [ -z "$REPO_ROOT" ]; then
    cat << EOF
{
  "error": "Not a git repository",
  "initialized": false,
  "currentBranch": "",
  "branchType": "",
  "suggestion": "Initialize a git repository first: git init"
}
EOF
    exit 0
fi

cd "$REPO_ROOT"

# Get current branch
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "")

# Check if git flow is initialized by looking for gitflow config
GF_MASTER=$(git config --get gitflow.branch.master 2>/dev/null || echo "")
GF_DEVELOP=$(git config --get gitflow.branch.develop 2>/dev/null || echo "")
GF_FEATURE=$(git config --get gitflow.prefix.feature 2>/dev/null || echo "feature/")
GF_BUGFIX=$(git config --get gitflow.prefix.bugfix 2>/dev/null || echo "bugfix/")
GF_RELEASE=$(git config --get gitflow.prefix.release 2>/dev/null || echo "release/")
GF_HOTFIX=$(git config --get gitflow.prefix.hotfix 2>/dev/null || echo "hotfix/")
GF_SUPPORT=$(git config --get gitflow.prefix.support 2>/dev/null || echo "support/")

# Determine if git flow is initialized
INITIALIZED=false
if [ -n "$GF_MASTER" ] && [ -n "$GF_DEVELOP" ]; then
    INITIALIZED=true
fi

# Determine branch type
BRANCH_TYPE="other"
BRANCH_NAME=""

if [ "$CURRENT_BRANCH" = "$GF_MASTER" ] || [ "$CURRENT_BRANCH" = "master" ] || [ "$CURRENT_BRANCH" = "main" ]; then
    BRANCH_TYPE="master"
    BRANCH_NAME="$CURRENT_BRANCH"
elif [ "$CURRENT_BRANCH" = "$GF_DEVELOP" ] || [ "$CURRENT_BRANCH" = "develop" ]; then
    BRANCH_TYPE="develop"
    BRANCH_NAME="$CURRENT_BRANCH"
elif [[ "$CURRENT_BRANCH" == ${GF_FEATURE}* ]]; then
    BRANCH_TYPE="feature"
    BRANCH_NAME="${CURRENT_BRANCH#$GF_FEATURE}"
elif [[ "$CURRENT_BRANCH" == ${GF_BUGFIX}* ]]; then
    BRANCH_TYPE="bugfix"
    BRANCH_NAME="${CURRENT_BRANCH#$GF_BUGFIX}"
elif [[ "$CURRENT_BRANCH" == ${GF_RELEASE}* ]]; then
    BRANCH_TYPE="release"
    BRANCH_NAME="${CURRENT_BRANCH#$GF_RELEASE}"
elif [[ "$CURRENT_BRANCH" == ${GF_HOTFIX}* ]]; then
    BRANCH_TYPE="hotfix"
    BRANCH_NAME="${CURRENT_BRANCH#$GF_HOTFIX}"
elif [[ "$CURRENT_BRANCH" == ${GF_SUPPORT}* ]]; then
    BRANCH_TYPE="support"
    BRANCH_NAME="${CURRENT_BRANCH#$GF_SUPPORT}"
fi

# List active branches by type
list_branches() {
    local prefix=$1
    git branch --list "${prefix}*" 2>/dev/null | sed 's/^[* ]*//' | tr '\n' ',' | sed 's/,$//'
}

FEATURES=$(list_branches "$GF_FEATURE")
BUGFIXES=$(list_branches "$GF_BUGFIX")
RELEASES=$(list_branches "$GF_RELEASE")
HOTFIXES=$(list_branches "$GF_HOTFIX")
SUPPORTS=$(list_branches "$GF_SUPPORT")

# Determine available operations based on branch type
AVAILABLE_OPS=""
case "$BRANCH_TYPE" in
    "feature")
        AVAILABLE_OPS="finish, publish, track, pull, delete, diff, rebase"
        ;;
    "bugfix")
        AVAILABLE_OPS="finish, publish, track, pull, delete, diff, rebase"
        ;;
    "release")
        AVAILABLE_OPS="finish, publish, track, delete"
        ;;
    "hotfix")
        AVAILABLE_OPS="finish, publish, delete"
        ;;
    "support")
        AVAILABLE_OPS="(no finish available for support branches)"
        ;;
    "develop")
        AVAILABLE_OPS="start feature, start bugfix, start release"
        ;;
    "master")
        AVAILABLE_OPS="start hotfix, start support"
        ;;
    *)
        AVAILABLE_OPS="checkout to develop or master first"
        ;;
esac

# Determine suggested next action
SUGGESTION=""
if [ "$INITIALIZED" = false ]; then
    SUGGESTION="Git flow not initialized. Run: git flow init"
elif [ "$BRANCH_TYPE" = "develop" ]; then
    SUGGESTION="Ready to start a new feature or bugfix. Use: /gitflow start feature <name>"
elif [ "$BRANCH_TYPE" = "master" ]; then
    SUGGESTION="On production branch. Start a hotfix if needed: /gitflow start hotfix <version>"
elif [ "$BRANCH_TYPE" = "feature" ] || [ "$BRANCH_TYPE" = "bugfix" ]; then
    SUGGESTION="Working on $BRANCH_TYPE/$BRANCH_NAME. When ready: /gitflow finish or /gitflow publish"
elif [ "$BRANCH_TYPE" = "release" ]; then
    SUGGESTION="Release $BRANCH_NAME in progress. When ready: /gitflow finish"
elif [ "$BRANCH_TYPE" = "hotfix" ]; then
    SUGGESTION="Hotfix $BRANCH_NAME in progress. When ready: /gitflow finish"
fi

# Check if branch is published (has remote tracking)
IS_PUBLISHED=false
REMOTE_BRANCH=$(git config --get "branch.$CURRENT_BRANCH.remote" 2>/dev/null || echo "")
if [ -n "$REMOTE_BRANCH" ]; then
    IS_PUBLISHED=true
fi

# Output JSON
cat << EOF
{
  "initialized": $INITIALIZED,
  "currentBranch": "$CURRENT_BRANCH",
  "branchType": "$BRANCH_TYPE",
  "branchName": "$BRANCH_NAME",
  "isPublished": $IS_PUBLISHED,
  "config": {
    "master": "$GF_MASTER",
    "develop": "$GF_DEVELOP",
    "featurePrefix": "$GF_FEATURE",
    "bugfixPrefix": "$GF_BUGFIX",
    "releasePrefix": "$GF_RELEASE",
    "hotfixPrefix": "$GF_HOTFIX",
    "supportPrefix": "$GF_SUPPORT"
  },
  "activeBranches": {
    "features": "$FEATURES",
    "bugfixes": "$BUGFIXES",
    "releases": "$RELEASES",
    "hotfixes": "$HOTFIXES",
    "supports": "$SUPPORTS"
  },
  "availableOperations": "$AVAILABLE_OPS",
  "suggestion": "$SUGGESTION"
}
EOF
