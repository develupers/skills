This skill guides users through the Spec-Driven Development (speckit) workflow. Use when the user asks "what's next?", "where am I in speckit?", "speckit status", "which speckit command should I run?", "help me with speckit workflow", "what speckit command comes after X?", or mentions being lost in the speckit process.

---

## Speckit Workflow Navigator

Guide users through the Spec-Driven Development workflow by detecting their current state and recommending the appropriate next command.

### Step 1: Detect Current State

Run the detection script to analyze the current workflow state:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/skills/speckit-guide/scripts/detect-state.sh
```

Parse the JSON output to understand:
- Current git branch and whether it's a feature branch
- Which speckit artifacts exist (constitution, spec, plan, tasks, etc.)
- Current phase and recommended next command

### Step 2: Present Workflow Status

Display a clear status overview using this format:

```
## Speckit Workflow Status

**Branch**: {branch} {feature_badge}
**Feature Directory**: {feature_dir or "N/A"}

### Artifacts
| Document | Status | Command |
|----------|--------|---------|
| Constitution | {check or x} | /speckit.constitution |
| Specification | {check or x} | /speckit.specify |
| Implementation Plan | {check or x} | /speckit.plan |
| Task Breakdown | {check or x} | /speckit.tasks |

### Current Phase: {phase_name}

{next_reason}

**Next Command**: `{next_command}`
```

### Step 3: Provide Context

Based on the detected phase, explain what the next command does:

**Phase 0 - Constitution** (`/speckit.constitution`):
- Establishes project development principles
- Creates `.specify/memory/constitution.md`
- One-time setup per project

**Phase 1 - Create Branch**:
- Create feature branch with pattern `###-feature-name`
- Example: `git checkout -b 007-user-authentication`
- Each feature gets its own spec directory

**Phase 2 - Specify** (`/speckit.specify`):
- Define requirements and user stories
- Creates `specs/{branch}/spec.md`
- Focus on WHAT and WHY, not HOW
- User stories should be prioritized (P1, P2, P3...)

**Phase 3 - Plan** (`/speckit.plan`):
- Define technical implementation approach
- Creates `plan.md`, `research.md`, `data-model.md`
- May create `contracts/` for API definitions
- Focus on HOW to implement

**Phase 4 - Tasks** (`/speckit.tasks`):
- Generate actionable task breakdown
- Creates `tasks.md` with checkboxes
- Tasks organized by user story
- Includes parallel execution markers [P]

**Phase 5 - Implement** (`/speckit.implement`):
- Execute tasks systematically
- Validates prerequisites before each task
- Updates task checkboxes as completed

### Step 4: Offer Additional Options

Always mention these supplementary commands:

- **`/speckit.clarify`** - Ask clarifying questions about incomplete specs (use after /speckit.specify if requirements are unclear)
- **`/speckit.analyze`** - Validate consistency across all speckit artifacts (use anytime for quality check)
- **`/speckit.checklist`** - Generate custom quality checklist (use before finalizing)

### Workflow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    SPECKIT WORKFLOW                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────┐                                              │
│  │ Constitution │ ─────────────────────────────────────────┐   │
│  │ (one-time)   │                                          │   │
│  └──────────────┘                                          │   │
│         │                                                   │   │
│         ▼                                                   │   │
│  ┌──────────────┐    ┌──────────────┐                      │   │
│  │ Create       │───▶│   Specify    │◀──┐                  │   │
│  │ Feature Branch│    │ (spec.md)   │   │                  │   │
│  └──────────────┘    └──────────────┘   │                  │   │
│                             │           │                   │   │
│                             ▼           │                   │   │
│                      ┌──────────────┐   │                  │   │
│                      │   Clarify    │───┘                  │   │
│                      │ (optional)   │                       │   │
│                      └──────────────┘                       │   │
│                             │                               │   │
│                             ▼                               │   │
│                      ┌──────────────┐                       │   │
│                      │    Plan      │                       │   │
│                      │ (plan.md)   │                       │   │
│                      └──────────────┘                       │   │
│                             │                               │   │
│                             ▼                               │   │
│                      ┌──────────────┐                       │   │
│                      │   Tasks      │                       │   │
│                      │ (tasks.md)  │                       │   │
│                      └──────────────┘                       │   │
│                             │                               │   │
│                             ▼                               │   │
│                      ┌──────────────┐    ┌──────────────┐  │   │
│                      │  Implement   │───▶│  Analyze     │◀─┘   │
│                      │ (execute)    │    │ (anytime)    │      │
│                      └──────────────┘    └──────────────┘      │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Example Output

For a user on branch `006-order-management` with spec.md and plan.md but no tasks.md:

```
## Speckit Workflow Status

**Branch**: 006-order-management (Feature Branch)
**Feature Directory**: specs/006-order-management/

### Artifacts
| Document | Status | Command |
|----------|--------|---------|
| Constitution | ✓ | /speckit.constitution |
| Specification | ✓ | /speckit.specify |
| Implementation Plan | ✓ | /speckit.plan |
| Task Breakdown | ✗ | /speckit.tasks |

### Current Phase: Generate Tasks

Plan complete. Generate actionable task breakdown.

**Next Command**: `/speckit.tasks`

This will:
- Read your plan.md and spec.md
- Generate tasks organized by user story
- Create dependency graph
- Mark parallelizable tasks with [P]
- Output to specs/006-order-management/tasks.md
```
