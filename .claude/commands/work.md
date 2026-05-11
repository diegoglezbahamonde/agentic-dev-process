---
description: Drive a ticket through Explore → Plan → Implement → Verify with explicit checkpoints. Use for any non-trivial work; do not code from a freeform prompt.
argument-hint: <TICKET-ID>
---

# /work $ARGUMENTS

You are driving ticket **$ARGUMENTS** through the four-phase loop. Each phase ends in a **checkpoint** where the user can redirect cheaply.

Use TodoWrite from the start to track all four phases as todos. Mark each completed as you go.

## Phase 0 — Fetch the ticket

Try in order, stop on the first that works:

1. If a Jira / Linear / Shortcut MCP server is configured, fetch ticket `$ARGUMENTS`.
2. If a file `.tickets/$ARGUMENTS.md` exists in the repo, read it.
3. Otherwise, ask the user to paste the ticket body.

State a one-line summary and confirm: "Ticket parsed: <summary>. Begin Explore?"

## Phase 1 — Explore

Read the parts of the codebase the ticket touches. Use Grep / Glob / Read; spawn an `Explore` agent if the search is broad. **Do not edit yet.** Avoid speculative reads — only what the ticket implicates.

Produce a summary covering:

- What the ticket asks for (in your own words)
- Which bounded context / module is affected
- Key files identified (with `path:line` references)
- Open questions or ambiguities for the user

**Checkpoint 1.** Present the summary. Ask: *"Findings look right? Anything missing? Ready to plan?"*

If the user redirects, re-explore. Don't proceed without confirmation.

## Phase 2 — Plan

Invoke the `implementation-planner` subagent via the Agent tool. Pass it:

- The ticket body (verbatim)
- Your exploration summary

The subagent has read-only access; it returns a step-by-step plan. **Show the plan to the user verbatim** — don't paraphrase or shorten. The user reads the same plan you do.

**Checkpoint 2.** Ask: *"Approve the plan, request revisions, or redirect? Cheaper to change direction now than mid-implementation."*

If the user wants revisions, re-invoke the planner with the feedback. Don't start implementing until they approve.

## Phase 3 — Implement

For each step in the approved plan, execute one TDD cycle:

1. Add the step to TodoWrite as `in_progress`.
2. **Red** — write the failing test the plan named. Run it. See it fail for the right reason. (See [.claude/skills/testing/SKILL.md](../skills/testing/SKILL.md).)
3. **Green** — write the smallest production change that turns the test green.
4. **Refactor** — clean up with the suite green. Tests must stay green throughout.
5. Mark the todo `completed`. Move to the next step.

While implementing:

- Apply the relevant project skills (`architecture`, `backend` / `frontend`, `database`) at each step. Read the docs the SKILL.md points to before changing layered code.
- Don't bypass hooks. If `block-secrets`, `lint-on-edit`, or `enforce-tdd` blocks, fix the underlying issue.
- Keep commits at green points if the user has asked you to commit incrementally; otherwise wait for the verify phase.
- If a step reveals the plan is wrong, **stop and renegotiate** — go back to Checkpoint 2 with a revised plan, don't paper over it.

When all steps are complete and the suite is green:

**Checkpoint 3.** Summarize what changed — files touched, line count delta, anything that surprised you. Ask: *"Implementation complete and green. Ready to verify?"*

## Phase 4 — Verify

Run, in order:

1. The full test suite (not just the new tests).
2. Project typechecks (mypy, tsc) and linters if not already covered by hooks.
3. If a `code-reviewer` subagent exists at [.claude/agents/code-reviewer.md](../agents/code-reviewer.md), invoke it on the diff (`git diff origin/main...HEAD` or against the base branch).

**Checkpoint 4.** Report:

- Pass / fail for each check.
- Reviewer findings (must-fix vs. nice-to-have).
- Suggested next step: commit + push, open PR via `/finish $ARGUMENTS`, or hand back.

**Do not commit, push, or open a PR unless the user explicitly asks.** This phase ends with a recommendation, not an action.
