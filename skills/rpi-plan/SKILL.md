---
name: rpi-plan
description: "Run only the Planning phase of the RPI workflow. Creates an iterative, annotatable implementation plan from research findings. Use when you already have research and want to create or revise a plan."
argument-hint: Optional path to research file or topic name
---

# RPI Planning Phase

You are running the **Planning phase only** from the RPI methodology.

**Announce:** "Running RPI Planning phase — iterative plan creation with annotation support"

## Platform Detection

Detect your environment:
- If the `Task` tool is available with `subagent_type` → **Claude Code**
- If `codex exec` or Codex agent roles are available → **Codex CLI**

**Asking the user:** use `AskUserQuestion` (Claude Code) or `AskUserTool` (Codex CLI).

## Process

### 1. Locate Research

Check for existing research in order of priority:

1. If `$ARGUMENTS` is a file path: use that as the research file
2. If `$ARGUMENTS` is a topic: look for `docs/rpi/*-<topic>/research.md`
3. If nothing found: look for the most recent `docs/rpi/*/research.md`
4. If still nothing: ask the user to either provide a research file or run `/rpi-research` first

### 2. Context Check

Ask the user:
- **"What's the desired outcome?"** (if not already clear from research)
- **"What type of task is this?"** — feature, bugfix, debug, refactor

### 3. Dispatch Planner

Dispatch the **planner** agent:

**Claude Code:**
```
Task tool:
  subagent_type: claude-rpi:planner
  description: "Plan: [topic]"
  prompt: |
    Create an implementation plan based on research findings.

    Research file: [path to research.md]
    Task type: [feature/bugfix/debug/refactor]
    Desired outcome: [from user]

    Write the plan to: docs/rpi/YYYY-MM-DD-<topic>/plan.md
```

**Codex CLI:**
```
codex exec --role rpi-planner "Create implementation plan. Research: [path to research.md]. Task type: [type]. Outcome: [outcome]. Write to: docs/rpi/YYYY-MM-DD-<topic>/plan.md"
```

### 4. Annotation Cycle

After the planner returns:

1. Read plan.md
2. Present key sections in terminal: approach, task breakdown, risks
3. Ask:

**"Review the plan. You can:**
- **Give feedback here** — I'll revise
- **Edit plan.md directly** — Add `<!-- NOTE: ... -->` annotations and tell me when done
- **Say 'approved'** — Finalize the plan"

4. If feedback: re-dispatch planner to revise. Repeat.
5. If file edited: re-dispatch planner to address annotations. Repeat.
6. If approved: finalize.

Maximum 6 iterations.

### 5. Handoff

Let the user know: **"Plan approved and saved to `docs/rpi/<session>/plan.md`. You can implement with `/rpi-implement` when ready."**
