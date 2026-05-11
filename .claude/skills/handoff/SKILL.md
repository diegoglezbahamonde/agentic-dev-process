---
name: handoff
description: Compact the current conversation into a handoff document so another agent (or the same one in a fresh session) can pick up the work. Use when a /work session is approaching the context limit, when you need to pause mid-Implement and resume tomorrow, or when explicitly asked to "write a handoff".
argument-hint: "What will the next session focus on?"
---

# handoff

Write a handoff document summarising the current conversation so a fresh agent can continue the work without re-deriving everything.

## Where to save

`.handoffs/<short-slug>-<YYYYMMDDHHMM>.md` in the repo (e.g., `.handoffs/jira-487-mid-implement-202605111430.md`). Create the `.handoffs/` directory if it doesn't exist. Do not commit the handoff unless the user asks — it's a working artifact, not a deliverable.

If `.handoffs/` isn't yet in `.gitignore`, add it (one line: `.handoffs/`).

## What to include

The handoff is a snapshot for a fresh agent that has zero conversation context. Cover:

1. **What we're doing** — the ticket / problem, in one paragraph. Link to `.tickets/<ID>.md` or the tracker URL if it exists; do not retype the ticket here.
2. **Where we are** — if mid-`/work`, name the phase and checkpoint (e.g., "Phase 3 Implement, step 2 of 4 done; step 3 has the failing test written but no production code yet"). If mid-`/refine`, name the iteration round.
3. **What's been decided** — non-obvious choices the next agent shouldn't relitigate. Link to commit SHAs / PR comments instead of restating.
4. **What's pending** — the immediate next action, then the rest in order.
5. **Blockers / open questions** — what's actually stuck and why.
6. **Skills to load first** — name them by skill name (`architecture`, `testing`, `backend`, `frontend`, `database`, `user-story`, `commit-and-pr`). Don't dump skill contents; the next agent reads them on demand.

## What NOT to include

- **Don't duplicate** content that lives elsewhere (the ticket, the plan, the diff, commit messages, the code itself). Reference by path / URL / SHA.
- **Don't summarize what the next agent can `git log` / `git diff` for.**
- **Don't include conversation transcript.** Distill, don't quote.
- **Don't write a "context dump."** A bad handoff is everything; a good handoff is the smallest set of links and decisions that lets the next agent be productive in five minutes.

## Format

```markdown
# Handoff: <one-line description>

**Ticket**: <ID + link>
**Branch**: <branch name>
**Status**: <one line: phase / step / blocker>

## What we're doing
<one paragraph>

## Where we are
<phase + checkpoint, with file paths and commit SHAs as anchors>

## Decided
- <decision> — see <commit SHA / PR comment>
- ...

## Pending (in order)
1. <next action>
2. ...

## Blockers / open questions
- ...

## Skills to load first
- architecture (for the layer change in step 2)
- testing (TDD discipline still applies)
- ...

## Resume command
<the slash command the next agent should run, e.g., `/work JIRA-487` or `/finish JIRA-487`>
```

After writing, print the path so the user knows where it is, and tell them the resume command they can hand to the next session.

---

_Adapted from [mattpocock/skills](https://github.com/mattpocock/skills) — productivity/handoff. Original is leaner; this version is project-specific (saves under `.handoffs/`, names this team's skills, ties into the `/work` phase model)._
