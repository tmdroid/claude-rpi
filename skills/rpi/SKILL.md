---
name: rpi
description: "Use for any development task: features, bugs, debugging, refactoring. Implements the Research-Plan-Implement methodology — systematic codebase research, iterative planning with annotation cycles, and supervised implementation with specialized agents. Invoke with /rpi."
argument-hint: Optional task description
---

# Research-Plan-Implement Workflow

You are orchestrating the RPI methodology — a systematic workflow for AI-assisted software development.

**Core principle: Never write code until the user has reviewed and approved a written plan.**

**Announce:** "Using RPI workflow: Research → Plan → Implement"

## Phase 0: Task Classification

Start by understanding what kind of work this is. Use AskUserQuestion:

**Question:** "What type of task are you working on?"
**Options:**
- **New feature** — Full Research → Plan → Implement cycle
- **Bug fix** — Research (reproduce + root cause) → Plan (targeted fix) → Implement
- **Debugging** — Research (investigate symptoms) → Plan (hypothesis) → Implement (verify)
- **Refactor** — Research (current state) → Plan (target architecture) → Implement

If the user provided a task description via `$ARGUMENTS`, use it to pre-classify and confirm.

Store the task type — it determines which agent is dispatched in Phase 3.

## Phase 0.5: Context Gathering

Ask clarifying questions **one at a time** using AskUserQuestion. Do not batch questions.

1. **"What's the desired outcome?"** — What should be true when this is done?
2. **"Any constraints or requirements?"** — Performance, compatibility, style, technology constraints
3. **"Which areas of the codebase are relevant?"** — Offer to help identify if user is unsure. If they name areas, note them for the researcher.
4. **"Any reference implementations or examples to follow?"** — Existing code, open source examples, documentation links

Skip questions that are already answered by `$ARGUMENTS` or earlier conversation.

**Create session directory:**
```
docs/rpi/YYYY-MM-DD-<topic>/
```

Write a brief `session.md` file with the task type, desired outcome, and constraints as captured above.

## Phase 1: Research

<HARD-GATE>
Do NOT proceed to Phase 2 until the user has reviewed the research findings and explicitly approved them. Phrases like "looks good", "approved", "that's right", "move on" count as approval. If unsure, ask: "Ready to move to planning?"
</HARD-GATE>

### Dispatch Researcher

Use the Task tool to dispatch the **researcher** agent:

```
Task tool:
  subagent_type: claude-rpi:researcher
  description: "Research: [topic]"
  prompt: |
    Research the codebase for: [task description]
    Task type: [feature/bugfix/debug/refactor]
    Areas to focus on: [from context gathering]

    Write your findings to: docs/rpi/YYYY-MM-DD-<topic>/research.md

    [For debugging tasks, add:]
    Start with reproduction: [bug description/symptoms]

    [For refactor tasks, add:]
    Focus on: current architecture, test coverage, public interfaces
```

### Team Option

Check if the TeamCreate tool is available. If yes, ask:

**"This codebase area is [small/medium/large]. Would you like me to spin up a research team for parallel exploration, or keep it single-agent?"**

If team chosen:
- Create team with TeamCreate
- Dispatch multiple researcher agents, each focusing on a different area (e.g., frontend, backend, tests, config)
- Merge findings into a single research.md

### Present Findings

After the researcher agent returns:

1. Read `docs/rpi/<session>/research.md`
2. Present a **terminal summary** of key findings:
   - Most important files identified
   - Architecture patterns found
   - Critical gotchas or risks
   - (Keep it concise — the full details are in the file)
3. Ask: **"Does this match your understanding? Want me to dig deeper into anything specific?"**
4. If user wants deeper investigation: re-dispatch researcher with specific focus areas
5. If user approves: proceed to Phase 2

## Phase 2: Planning

<HARD-GATE>
Do NOT proceed to Phase 3 until the user has explicitly approved the plan. The annotation cycle may repeat 1-6 times. Do not rush the user — this phase is where 80% of the value comes from.
</HARD-GATE>

### Dispatch Planner

Use the Task tool to dispatch the **planner** agent:

```
Task tool:
  subagent_type: claude-rpi:planner
  description: "Plan: [topic]"
  prompt: |
    Create an implementation plan based on research findings.

    Research file: docs/rpi/YYYY-MM-DD-<topic>/research.md
    Task type: [feature/bugfix/debug/refactor]
    Desired outcome: [from context gathering]
    Constraints: [from context gathering]

    Write the plan to: docs/rpi/YYYY-MM-DD-<topic>/plan.md
```

### Annotation Cycle

After the planner returns:

1. Read `docs/rpi/<session>/plan.md`
2. Present **key sections** in terminal for quick feedback:
   - The approach (what and why)
   - Task breakdown overview (numbered list, not full detail)
   - Risk areas
3. Ask the user:

**"Review the plan. You can:**
- **Give feedback here** — I'll revise based on your notes
- **Edit plan.md directly** — Add `<!-- NOTE: your note -->` annotations and tell me when done
- **Say 'approved'** — Move to implementation"

4. **If terminal feedback given:**
   - Re-dispatch planner with the feedback
   - Planner revises and updates plan.md
   - Return to step 1

5. **If user edited the file:**
   - Re-dispatch planner with instruction to find and address all annotations
   - Planner reads annotations, revises, adds `> **Addressed:** ...` responses
   - Return to step 1

6. **If user approves:**
   - Exit the annotation cycle
   - Proceed to Phase 3

**Maximum 6 iterations.** If still not approved after 6, ask: "We've done 6 revision rounds. Should we continue refining, or is there a fundamental approach issue we should reconsider?"

## Phase 3: Implementation

### Dispatch Implementer

Based on the task type from Phase 0, dispatch the appropriate agent:

| Task Type | Agent | Focus |
|-----------|-------|-------|
| New feature | `claude-rpi:feature-implementer` | Follow plan step by step |
| Bug fix | `claude-rpi:bugfixer` | TDD: regression test → fix → verify |
| Debugging | `claude-rpi:debugger` | If root cause not yet found; else bugfixer |
| Refactor | `claude-rpi:refactorer` | Incremental changes with test safety |

```
Task tool:
  subagent_type: claude-rpi:[agent-name]
  description: "Implement: [topic]"
  prompt: |
    Implement the approved plan.

    Plan file: docs/rpi/YYYY-MM-DD-<topic>/plan.md
    Research file: docs/rpi/YYYY-MM-DD-<topic>/research.md

    Follow the plan exactly. Mark checkboxes as you complete each task.
    Run tests after each significant change.
    If you hit something not covered by the plan, stop and ask.
```

### Team Option for Implementation

If TeamCreate is available and the plan has independent tasks, ask:

**"The plan has [N] independent tasks. Would you like a team to implement them in parallel, or keep it sequential?"**

If team chosen:
- Create implementation team
- Assign independent tasks to different agents
- Coordinate via shared plan.md (each marks their own checkboxes)

### Supervision Mode

During implementation, your role shifts to supervision:

- **Terse corrections:** If the agent goes wrong, give single-sentence redirections
- **Reference existing code:** "Look at how `src/auth/middleware.ts` handles this"
- **Revert and re-scope:** If direction is fundamentally wrong, tell the agent to revert
- **Screenshot feedback:** For visual changes, share screenshots

## Phase 4: Verification

After implementation completes:

1. **Detect and run the project's verification tools:**
   - Look for: `package.json` (scripts), `Makefile`, `pytest.ini`, `.github/workflows/`
   - Run: tests, type checks, linting (whatever the project uses)

2. **Present summary:**
   - Files created/modified
   - Test results
   - Any warnings or issues

3. **Ask the user:**

**"Implementation complete. What would you like to do?"**
- **Commit** — Stage and commit the changes
- **Create PR** — Commit, push, and create a pull request
- **Continue iterating** — Make additional changes or fixes
- **Review changes** — Show a detailed diff first

4. **Update session.md** with a summary of what was accomplished.

## Session Structure

Keep research, planning, and implementation in a **single continuous session** whenever possible. This maintains contextual understanding throughout the workflow. If context is getting long, the persistent markdown files ensure nothing is lost.

## File Output Structure

```
docs/rpi/
└── YYYY-MM-DD-<topic>/
    ├── session.md        # Task type, goals, constraints, outcome summary
    ├── research.md       # Codebase findings from researcher agent
    └── plan.md           # Implementation plan (with annotations and responses)
```
