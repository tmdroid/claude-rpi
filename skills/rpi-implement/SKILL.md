---
name: rpi-implement
description: "Run only the Implementation phase of the RPI workflow. Executes an approved plan with the appropriate specialized agent. Use when you have an approved plan ready for implementation."
argument-hint: Optional path to plan file or topic name
---

# RPI Implementation Phase

You are running the **Implementation phase only** from the RPI methodology.

**Announce:** "Running RPI Implementation phase — executing approved plan"

## Platform Detection

Detect your environment:
- If the `Task` tool is available with `subagent_type` → **Claude Code**
- If `codex exec` or Codex agent roles are available → **Codex CLI**

**Asking the user:** use `AskUserQuestion` (Claude Code) or `AskUserTool` (Codex CLI).

## Process

### 1. Locate Plan

Check for an approved plan in order of priority:

1. If `$ARGUMENTS` is a file path: use that as the plan file
2. If `$ARGUMENTS` is a topic: look for `docs/rpi/*-<topic>/plan.md`
3. If nothing found: look for the most recent `docs/rpi/*/plan.md`
4. If still nothing: ask the user to provide a plan file or run `/rpi-plan` first

### 2. Determine Task Type

Read the plan to determine the task type. If unclear, ask:

**"What type of implementation is this?"**
- **New feature** → feature-implementer agent
- **Bug fix** → bugfixer agent
- **Debugging** → debugger agent
- **Refactor** → refactorer agent

### 3. Dispatch Agent

Based on task type, dispatch the appropriate agent:

| Task Type | Claude Code Agent | Codex Role |
|-----------|-------------------|------------|
| New feature | `claude-rpi:feature-implementer` | `rpi-feature-implementer` |
| Bug fix | `claude-rpi:bugfixer` | `rpi-bugfixer` |
| Debugging | `claude-rpi:debugger` | `rpi-debugger` |
| Refactor | `claude-rpi:refactorer` | `rpi-refactorer` |

**Claude Code:**
```
Task tool:
  subagent_type: claude-rpi:[agent-name]
  description: "Implement: [topic]"
  prompt: |
    Implement the approved plan.

    Plan file: [path to plan.md]
    Research file: [path to research.md, if exists]

    Follow the plan exactly. Mark checkboxes as you complete each task.
    Run tests after each significant change.
    If you hit something not covered by the plan, stop and ask.
```

**Codex CLI:**
```
codex exec --role rpi-[agent-name] "Implement the approved plan. Plan: [path to plan.md]. Research: [path to research.md]. Follow plan exactly. Mark checkboxes. Run tests. Stop and ask if uncovered."
```

If TeamCreate is available (Claude Code) and the plan has independent tasks, offer parallel implementation.

### 4. Supervision

During implementation:
- Monitor agent progress
- Answer agent questions promptly
- Provide terse corrections if needed
- Reference existing code for consistency

### 5. Verification

After implementation completes:

1. Run the project's tests, type checks, linting
2. Present summary of changes and test results
3. Ask:

**"Implementation complete. What would you like to do?"**
- **Commit** — Stage and commit
- **Create PR** — Commit, push, and open a PR
- **Continue iterating** — More changes
- **Review changes** — Show detailed diff first
