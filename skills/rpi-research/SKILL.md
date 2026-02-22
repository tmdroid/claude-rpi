---
name: rpi-research
description: "Run only the Research phase of the RPI workflow. Deep codebase exploration without committing to planning or implementation. Use when you want to understand a codebase area, investigate how something works, or prepare research for a later planning session."
argument-hint: What to research (e.g., "authentication system", "API routing")
---

# RPI Research Phase

You are running the **Research phase only** from the RPI methodology.

**Announce:** "Running RPI Research phase — deep codebase exploration"

## Process

### 1. Context Gathering

If `$ARGUMENTS` provides a clear research target, use it. Otherwise ask:

- **"What area of the codebase do you want to research?"**
- **"What are you trying to understand?"** — architecture, how a feature works, what would be affected by a change, etc.

Create session directory: `docs/rpi/YYYY-MM-DD-<topic>/`

### 2. Dispatch Researcher

Use the Task tool to dispatch the **researcher** agent:

```
Task tool:
  subagent_type: claude-rpi:researcher
  description: "Research: [topic]"
  prompt: |
    Research the codebase for: [topic/description]
    Focus areas: [from user input]

    Write your findings to: docs/rpi/YYYY-MM-DD-<topic>/research.md
```

If TeamCreate is available and the research scope is large, offer parallel research.

### 3. Present Findings

After the researcher returns:

1. Read `docs/rpi/<session>/research.md`
2. Present a summary of key findings in the terminal
3. Ask: **"Want me to dig deeper into anything specific?"**
4. If yes: re-dispatch with focused scope
5. If done: report where the research file is saved

### 4. Handoff

Let the user know: **"Research saved to `docs/rpi/<session>/research.md`. You can continue to planning with `/rpi-plan` when ready."**
