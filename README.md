# Agentic Engineering Workflow

A Claude Code configuration that encodes an agile development workflow as skills, subagents, commands, and hooks. The goal: move from manually executing every step (refinement → implementation → review → merge) to directing an agent that does the execution while you verify.

## Mental model

- **CLAUDE.md** — always-on project context (kept small)
- **Skills** — opinionated knowledge loaded on demand (test style, architecture, templates)
- **Subagents** — isolated specialists with their own context (planner, reviewer, refiner)
- **Commands** — parameterized workflows you invoke (`/work JIRA-123`)
- **Hooks** — deterministic shell scripts on lifecycle events (lint, secret scan, test gate)
- **MCP** — connections to Jira, GitHub, etc.

Rule of thumb: deterministic checks → hooks. Knowledge → skills. Recurring workflows → commands. Isolated specialist work → subagents.

## Workflow

The core loop is **Explore → Plan → Implement → Verify**, with explicit pauses between phases.

```
/refine <idea>        → drafts a Jira-ready ticket
/plan JIRA-123        → produces an implementation plan, you approve
/work JIRA-123        → full E→P→I→V loop with checkpoints
/review               → fresh-context self-review of the current branch
/finish JIRA-123      → squash, format message, close ticket
```

## Repo layout

```
.
├── CLAUDE.md                       # project context, always loaded
├── .claude/
│   ├── settings.json               # hook config, permissions
│   ├── skills/                     # progressive-disclosure knowledge
│   ├── agents/                     # subagents with isolated context
│   ├── commands/                   # slash command templates
│   └── hooks/                      # deterministic shell guardrails
└── .mcp.json                       # Jira + GitHub MCP servers
```

## Setup

1. Fill in placeholders in `CLAUDE.md` (stack, architecture name).
2. Edit `.mcp.json` with your Jira URL and credentials env vars.
3. Adjust hook commands in `.claude/settings.json` to match your toolchain (linter, test runner, secret scanner).
4. Tune each skill's content to your team's actual conventions — the files shipped here are starting points, not gospel.
5. Make hooks executable: `chmod +x .claude/hooks/*.sh`.

## Build order

Don't enable everything at once. Suggested order:

1. CLAUDE.md + `testing-conventions` + `architecture` skills
2. `lint-on-edit` and `block-secrets` hooks
3. `/work` command + `implementation-planner` subagent
4. Jira MCP + `user-story` skill + `/refine`
5. `code-reviewer` subagent + `/review`
6. `/finish` + `commit-and-pr` skill
7. The rest as needs arise

Use each piece on a real ticket before adding the next.
