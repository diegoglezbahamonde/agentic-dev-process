---
description: Close out work on a ticket — open the PR if not yet, or finalize after merge (close ticket, switch back to base, delete branch). Detects which state you're in.
argument-hint: <TICKET-ID>
---

# /finish $ARGUMENTS

Detect the current state and do the right thing. Read the [commit-and-pr skill](../skills/commit-and-pr/SKILL.md) before drafting any commit message or PR body.

## Step 0 — Detect state

1. **Branch**: `git branch --show-current`. If on the base branch, abort with: "On `<base>`. Switch to the work branch first."
2. **PR for this branch**: `gh pr view --json number,state,url,title,baseRefName,mergeable 2>/dev/null`. The command failing simply means no PR yet — that's signal, not error.

State machine:

| State | Action |
|---|---|
| No PR for this branch | **Step 1** — Open it. |
| PR open, not merged | **Step 2** — Status only. |
| PR merged | **Step 3** — Close out. |
| PR closed without merge | Tell the user; stop. |

## Step 1 — Open the PR

1. **Verify the working tree is clean** (`git status --porcelain` empty) and the branch is pushed (`git push -u origin <branch>` if not). Do not push if the user hasn't approved — ask first.
2. **Fetch ticket `$ARGUMENTS`**: try the configured tracker MCP, then `.tickets/$ARGUMENTS.md`, then ask the user to paste a one-line summary.
3. **See what's shipping**: `git diff origin/<base>...HEAD` (full diff) and `git diff --stat origin/<base>...HEAD` (counts).
4. **Draft the PR title and body** per the [commit-and-pr skill](../skills/commit-and-pr/SKILL.md):
   - Title: ≤70 chars, sentence case, in domain terms. Will be the squash subject.
   - Body: `## Summary` (1–3 bullets + ticket link) then `## Test plan` (checklist of what the reviewer should verify, including manual steps).
5. **Show the user the draft.** Ask: *"Open the PR?"*
6. **On approval**, create with a HEREDOC:
   ```bash
   gh pr create --title "<title>" --body "$(cat <<'EOF'
   ## Summary
   ...

   ## Test plan
   - [ ] ...
   EOF
   )"
   ```
7. **Link the PR back to the ticket** if the tracker MCP supports it (comment on `$ARGUMENTS` with the PR URL). Skip silently if no MCP.
8. **Report the PR URL.**

## Step 2 — PR open, not merged

1. Show: PR number, URL, state, mergeable status.
2. Run `gh pr checks` and surface failing checks briefly (test name + status).
3. If checks are red: ask *"Want to address the failures?"*. Don't auto-fix.
4. If green and mergeable: report *"PR is ready for review/merge. Nothing more to do here until it's merged. Re-run `/finish $ARGUMENTS` after merge to close out."*

## Step 3 — PR merged

1. Confirm: *"PR `<url>` merged. Ready to close out the ticket and clean up?"*
2. **On approval, via the tracker MCP** (or instruct manually if no MCP):
   - Transition `$ARGUMENTS` to Done (or this team's equivalent column).
   - Comment with the merged PR URL if it isn't auto-linked.
3. **Switch back to the base branch**: `git checkout <base> && git pull --ff-only`.
4. **Offer to delete the local branch**: ask before running `git branch -d <branch>`. If `git branch -d` complains about unmerged changes (e.g., the squash discarded the original commits), confirm with the user before forcing with `-D`.
5. Done. If the user has another ticket, suggest `/work <next-ticket>`.

## Rules

- **Never push, force-push, or merge without explicit user approval** at the moment of action. Approval to "open the PR" is not approval to merge it.
- **Never close a ticket as Won't Do / Cancelled / similar from this command.** This command is the happy path. Cancelled work is a manual decision.
- **Never bypass the commit-and-pr skill.** The Summary + Test plan structure is what reviewers rely on; the structure is not optional even if the diff is small.
- **Don't fabricate a Test plan.** If the only meaningful verification is "the existing suite passes", say that. Padding the checklist with fake-looking items is worse than a one-line plan.
