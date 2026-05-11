---
description: Fresh-context review of the current branch (no arg) or a specific PR (with PR number / URL) by the code-reviewer subagent.
argument-hint: [<PR#> | <PR URL>]
---

# /review $ARGUMENTS

Invoke the `code-reviewer` subagent in a fresh context. The subagent is read-only and returns a structured review (Must-fix / Should-fix / Nit / Praise / Summary).

## Step 1 — Determine what to review

**If `$ARGUMENTS` looks like a PR number or PR URL:**

1. Resolve to a PR number (extract from URL if needed).
2. Fetch:
   - `gh pr view <PR#> --json title,body,baseRefName,headRefName,additions,deletions,changedFiles`
   - `gh pr diff <PR#>` (the unified diff)
3. Base ref = the PR's `baseRefName`; head ref = the PR's `headRefName`.

**If `$ARGUMENTS` is empty:**

1. Determine the base branch — try in order:
   - `git symbolic-ref refs/remotes/origin/HEAD` (the remote default branch).
   - `git config init.defaultBranch`.
   - Fall back to `main`.
2. Fetch:
   - `git diff <base>...HEAD` (the branch's diverged changes).
   - `git log <base>..HEAD --oneline` (recent commits for context).
   - `git diff --stat <base>...HEAD` (file count + line counts for the header).
3. Base ref = `<base>`; head ref = the current branch (`git branch --show-current`).

## Step 2 — Invoke the reviewer

Use the Agent tool with `subagent_type=code-reviewer`. Pass:

- The unified diff (verbatim).
- Base ref and head ref.
- File count, additions, deletions (for the review header).
- The PR title + body, OR the recent commit messages, so the reviewer knows what the diff *claims* to do.
- The ticket reference if mentioned in commits/PR (e.g., `JIRA-487`) — the reviewer can fetch it via the configured tracker MCP if it needs to verify intent matches implementation.

## Step 3 — Render

Show the reviewer's output **verbatim**. Do not summarize, re-prioritize, or drop sections — the author reads exactly what the reviewer produced. If the report has zero must-fixes, that's a meaningful signal; don't editorialize.

After the review, ask: *"Want me to address the must-fixes? (Or should-fixes?)"*. Don't start implementing fixes without an explicit go-ahead.

## Notes

- This command **supersedes the built-in `/review` skill** in this project — the built-in is PR-only, ours covers the pre-PR self-review case the README describes.
- For a heavier multi-agent review (parallel passes, longer running), the user can invoke `/ultrareview` separately. That's a different tool and is user-billed; do not invoke it from here.
