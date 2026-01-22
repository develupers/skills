---
name: gitflow
description: "Orchestrate Git Flow operations. Use when asked: start feature, finish feature, create release, hotfix, git flow status, what branch should I create, publish branch."
---

## Git Flow Workflow Orchestrator

Help users manage Git Flow branching operations by detecting current state, recommending actions, and executing git flow commands.

### Step 1: Parse User Request

Check if the user provided arguments (`$ARGUMENTS`):

**If arguments provided**, parse the command format:
- `start <type> <name>` - Start a new branch (feature/bugfix/release/hotfix/support)
- `finish [type] [name]` - Finish current or specified branch
- `publish [type] [name]` - Publish current or specified branch to remote
- `track <type> <name>` - Track a remote branch
- `pull <type> <name>` - Pull updates from remote branch
- `delete <type> <name>` - Delete a branch
- `diff [type] [name]` - Show diff against base branch
- `rebase [type] [name]` - Rebase on base branch
- `status` or no arguments - Show current git flow state

**Branch types:** `feature`, `bugfix`, `release`, `hotfix`, `support`

### Step 2: Detect Current State

Run the detection script to analyze the current git flow state:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/skills/gitflow/scripts/detect-state.sh
```

Parse the JSON output to understand:
- Whether git flow is initialized
- Current branch name and type (feature/bugfix/release/hotfix/develop/master)
- Available operations for the current context
- Recommended next action

### Step 3: Execute Requested Operation

Based on the parsed request and current state:

#### Start Operations
```bash
# Start a feature branch from develop
git flow feature start <name>

# Start a bugfix branch from develop
git flow bugfix start <name>

# Start a release branch from develop
git flow release start <version>

# Start a hotfix branch from master/main
git flow hotfix start <version>

# Start a support branch from a tag
git flow support start <version> <tag>
```

#### Finish Operations
**Important**: Always confirm with user before finishing, as this merges and may delete the branch.

```bash
# Finish feature (merges to develop, deletes branch)
git flow feature finish <name>

# Finish bugfix (merges to develop, deletes branch)
git flow bugfix finish <name>

# Finish release (merges to develop AND master, creates tag, deletes branch)
git flow release finish <version> -m "Release <version>"

# Finish hotfix (merges to develop AND master, creates tag, deletes branch)
git flow hotfix finish <version> -m "Hotfix <version>"
```

#### Publish Operations
```bash
git flow <type> publish <name>
```

#### Track Operations
```bash
git flow <type> track <name>
```

#### Pull Operations
```bash
git flow <type> pull origin <name>
```

#### Delete Operations
**Important**: Always confirm with user before deleting.

```bash
git flow <type> delete <name>
```

#### Diff Operations
```bash
git flow <type> diff <name>
```

#### Rebase Operations
```bash
git flow <type> rebase <name>
```

### Step 4: Present Status (for status command or no arguments)

Display a clear status overview:

```
## Git Flow Status

**Current Branch**: {branch_name}
**Branch Type**: {type} (feature/bugfix/release/hotfix/develop/master)
**Git Flow Initialized**: {yes/no}

### Branch Configuration
| Setting | Value |
|---------|-------|
| Master branch | {master} |
| Develop branch | {develop} |
| Feature prefix | {feature/} |
| Bugfix prefix | {bugfix/} |
| Release prefix | {release/} |
| Hotfix prefix | {hotfix/} |
| Support prefix | {support/} |

### Active Branches
| Type | Branches |
|------|----------|
| Features | {list} |
| Bugfixes | {list} |
| Releases | {list} |
| Hotfixes | {list} |

### Available Operations
{list of operations available for current branch}

### Suggested Next Action
{recommendation based on current state}
```

### Step 5: Confirm Destructive Operations

Before executing these operations, use AskUserQuestion to confirm:
- `finish` - Merges and may delete the branch
- `delete` - Permanently removes the branch
- `rebase` - Rewrites history

Example confirmation:
```
Finishing feature/user-auth will:
1. Merge feature/user-auth into develop
2. Delete feature/user-auth branch locally
3. Delete feature/user-auth branch remotely (if published)

Proceed?
```

### Git Flow Command Reference

| Operation | Feature | Bugfix | Release | Hotfix | Support |
|-----------|---------|--------|---------|--------|---------|
| start | Y | Y | Y | Y | Y |
| finish | Y | Y | Y | Y | - |
| publish | Y | Y | Y | Y | - |
| track | Y | Y | Y | - | - |
| pull | Y | Y | - | - | - |
| delete | Y | Y | Y | Y | - |
| diff | Y | Y | - | - | - |
| rebase | Y | Y | - | - | - |

### Workflow Diagram

```
                    ┌─────────────────────────────────────────────────────┐
                    │                   GIT FLOW                          │
                    ├─────────────────────────────────────────────────────┤
                    │                                                     │
   master/main ─────┼──●────────────────●─────────────────●───────────────┤
                    │  │                ↑                 ↑               │
                    │  │                │ (release        │ (hotfix       │
                    │  │                │  finish)        │  finish)      │
                    │  │                │                 │               │
      hotfix ───────┼──┼────────────────┼─────────────────●───────────────┤
                    │  │                │                 │               │
     release ───────┼──┼────────────────●─────────────────┼───────────────┤
                    │  │                ↑                 │               │
                    │  │                │ (release        │               │
                    │  │                │  start)         ↓               │
     develop ───────┼──●────●─────●─────●─────────────────●───────────────┤
                    │       │     ↑                                       │
                    │       │     │ (feature finish)                      │
                    │       │     │                                       │
     feature ───────┼───────●─────●───────────────────────────────────────┤
                    │       (feature start)                               │
                    │                                                     │
                    └─────────────────────────────────────────────────────┘
```

### Example Interactions

**User**: `/gitflow`
**Response**: Show current git flow status with active branches and suggested action

**User**: `/gitflow start feature user-authentication`
**Response**: Execute `git flow feature start user-authentication`

**User**: `/gitflow finish`
**Response**: Detect current branch type, confirm with user, then finish

**User**: `/gitflow publish`
**Response**: Detect current branch, execute `git flow <type> publish <name>`

### Error Handling

If git flow is not initialized:
```
Git Flow is not initialized in this repository.

Initialize with: git flow init

This will prompt you to configure:
- Production branch name (default: master)
- Development branch name (default: develop)
- Feature/bugfix/release/hotfix/support prefixes
```

If on wrong branch type for operation:
```
Cannot {operation} - current branch '{branch}' is not a {required_type} branch.

You are on: {branch_type}
Expected: {required_type}

Available operations for {branch_type}:
- {list of available operations}
```
