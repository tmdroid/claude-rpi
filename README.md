# claude-rpi

A Claude Code plugin implementing the **Research-Plan-Implement** methodology — a systematic workflow for AI-assisted software development.

Based on [How I Use Claude Code](https://boristane.com/blog/how-i-use-claude-code/) by Boris Tane.

## Core Principle

> Never let Claude write code until you've reviewed and approved a written plan.

This plugin enforces a three-phase workflow with hard gates between each phase, ensuring you stay in architectural control while Claude handles mechanical execution.

## Installation

### From GitHub (recommended)

```bash
# 1. Add the tmdroid plugins marketplace (one-time setup)
claude plugin marketplace add tmdroid/tmdroid-plugins

# 2. Install the plugin
claude plugin install claude-rpi@tmdroid-plugins
```

That's it. Restart Claude Code and `/rpi` is ready to use.

### Verify installation

```bash
claude plugin list  # Should show: claude-rpi@tmdroid-plugins ✔ enabled
```

### Update

```bash
claude plugin marketplace update tmdroid-plugins
claude plugin update claude-rpi@tmdroid-plugins
```

### Uninstall

```bash
claude plugin uninstall claude-rpi
# Optionally remove the marketplace too:
claude plugin marketplace remove tmdroid-plugins
```

### For AI Agents: Automated Installation

If you are an AI coding agent and have been asked to install this plugin, run these commands. No human input required.

```bash
claude plugin marketplace add tmdroid/tmdroid-plugins && \
claude plugin install claude-rpi@tmdroid-plugins --scope user
```

Verify:

```bash
claude plugin list 2>&1 | grep -q "claude-rpi" && echo "SUCCESS: claude-rpi installed" || echo "FAILED: claude-rpi not found"
```

After installation, the session must be restarted for the plugin to take effect. The `/rpi`, `/rpi-research`, `/rpi-plan`, and `/rpi-implement` commands will then be available.

## Quick Start

```
/rpi add user authentication to the API
```

Claude will walk you through:
1. Clarifying questions about your task
2. Deep codebase research
3. Iterative planning with annotation support
4. Supervised implementation

## Commands

| Command | Description |
|---------|-------------|
| `/rpi` | Full Research-Plan-Implement workflow |
| `/rpi-research` | Research phase only — deep codebase exploration |
| `/rpi-plan` | Planning phase only — iterative plan with annotations |
| `/rpi-implement` | Implementation phase only — execute an approved plan |

## The Workflow

```
Phase 0: Task Classification
  "What type of task?" → feature / bugfix / debug / refactor

Phase 0.5: Context Gathering
  Clarifying questions, one at a time

Phase 1: Research                          ← Researcher agent
  Deep codebase exploration → research.md
  ┌─────────────────────────────────┐
  │  GATE: User reviews & approves  │
  └─────────────────────────────────┘

Phase 2: Planning                          ← Planner agent
  Draft plan → plan.md
  ┌─ Annotation Cycle (1-6x) ──────┐
  │  User gives feedback / edits    │
  │  Planner revises                │
  │  Repeat until approved          │
  └─────────────────────────────────┘
  ┌─────────────────────────────────┐
  │  GATE: User approves plan       │
  └─────────────────────────────────┘

Phase 3: Implementation                    ← Specialized agent
  Execute plan → mark progress
  User supervises with terse corrections

Phase 4: Verification
  Tests, type checks, linting → summary
  Commit / PR / continue iterating
```

## Specialized Agents

The plugin dispatches the right agent for the job:

| Agent | Color | Purpose |
|-------|-------|---------|
| **researcher** | Blue | Deep codebase exploration, architecture mapping, gotcha detection |
| **planner** | Green | Structured plan drafting, annotation cycle support |
| **feature-implementer** | Cyan | Disciplined plan execution for new features |
| **debugger** | Red | Scientific debugging — reproduce, isolate, hypothesize, verify |
| **bugfixer** | Orange | TDD-based fixes — regression test first, then minimal surgical fix |
| **refactorer** | Magenta | Incremental restructuring with test safety at every step |

## The Annotation Cycle

The planning phase supports a unique **annotation cycle** — the key differentiator from other workflows:

1. Claude writes a plan to `plan.md`
2. You review it in terminal or open the file in your editor
3. Add annotations using either format:
   ```markdown
   <!-- NOTE: This approach won't work because of X -->
   ```
   ```markdown
   > [!annotation] We need to handle edge case Y
   ```
4. Tell Claude you've annotated the file
5. Claude revises the plan, responding to each annotation
6. Repeat until you approve

This creates a **shared mutable state** between you and Claude — the plan file serves as the collaboration medium.

## Team Mode

When Claude Code's agentic teams feature is available, the plugin offers to spin up coordinated teams at each phase:

- **Research team** — Multiple agents exploring different codebase areas in parallel
- **Implementation team** — Parallel execution of independent plan tasks

The plugin detects team availability automatically and falls back to single-agent execution when teams aren't available.

## Output Files

Each RPI session creates a structured directory:

```
docs/rpi/
└── 2026-02-22-add-auth/
    ├── session.md        # Task type, goals, constraints, outcome
    ├── research.md       # Codebase findings
    └── plan.md           # Implementation plan (with annotations)
```

These files persist across sessions, so you can:
- Resume work with `/rpi-implement` pointing to an existing plan
- Review past research when working on related features
- Reference plans as documentation

## Task Types

| Type | Research Focus | Planning Focus | Implementation Agent |
|------|---------------|----------------|---------------------|
| **Feature** | Architecture, patterns, dependencies | Full approach + task breakdown | feature-implementer |
| **Bug fix** | Reproduce + root cause | Targeted fix + regression test | bugfixer |
| **Debug** | Symptoms + investigation | Hypothesis + verification | debugger |
| **Refactor** | Current state + test coverage | Target architecture + incremental steps | refactorer |

## Credits

- Methodology inspired by [Boris Tane's article](https://boristane.com/blog/how-i-use-claude-code/) on the Research-Plan-Implement workflow
- Built for [Claude Code](https://claude.ai/code) by Anthropic

## License

MIT
