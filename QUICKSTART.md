# Quickstart

A 15-minute walkthrough to get this workflow running on a real ticket.

## 1. Drop into your repo

Copy the contents of this scaffold into the root of your project:

```
your-project/
├── CLAUDE.md
├── .claude/
└── .mcp.json
```

If you already have a `CLAUDE.md`, merge — don't replace.

## 2. Fill in the project-specific bits

Edit these files:

- **`CLAUDE.md`** — replace every `<FILL IN>` placeholder with your actual stack.
- **`.claude/skills/architecture/SKILL.md`** — adapt the layers and folder-hints table to your real structure. This is the most important skill to customize; the shipped version is illustrative only.
- **`.mcp.json`** — put your Atlassian host in, set the `ATLASSIAN_EMAIL`, `ATLASSIAN_API_TOKEN`, and `GITHUB_TOKEN` env vars.

## 3. Adapt the hooks to your toolchain

Open `.claude/hooks/`:

- **`lint-on-edit.sh`** — replace the linter commands with what you actually run.
- **`tests-before-stop.sh`** — when you're ready to enforce a pre-finish test gate, set `TESTS_BEFORE_STOP=1` in your environment.
- **`enforce-tdd.sh`** — defaults to warn-only; set `TDD_HOOK_STRICT=1` later when the team is ready.

Make sure they're executable:

```bash
chmod +x .claude/hooks/*.sh
```

## 4. First real run — refine a ticket

In Claude Code:

```
/refine We need to let users export their paid invoices as CSV. Finance currently does this by hand each month.
```

The `ticket-refiner` subagent will produce a draft ticket with domain and technical sections, plus open questions. Answer the questions, then say "write it to Jira" if you want it created.

## 5. Plan and implement

Once the ticket exists:

```
/work JIRA-487
```

You'll get four checkpoints — exploration summary, plan, implementation per step, and final review. At each one, you can redirect cheaply.

## 6. Wrap up

When the PR is merged:

```
/finish JIRA-487
```

## What to expect on the first few runs

- Skills will trigger inconsistently. Tighten their descriptions when they don't fire (or fire too often).
- The hooks might be too strict or too loose. Tune them against real edits.
- The plan output will be too vague or too detailed. Adjust the planner subagent's "Plan format" section.

Treat the first two weeks as calibration. The repo is a living thing — every time you find yourself correcting the agent on the same thing twice, that's a signal to encode the correction in a skill.
