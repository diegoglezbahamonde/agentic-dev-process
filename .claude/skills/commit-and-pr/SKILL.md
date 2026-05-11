---
name: commit-and-pr
description: How this team formats commits, names branches, and writes PRs — subject in domain language with body explaining why, Co-Authored-By trailer when an agent helped, branch named <ticket-id>-<short-desc>, PR description as Summary + Test plan checklist. Use when about to commit, draft a commit message, draft a PR description, open a PR, or invoked by /finish.
---

# commit-and-pr

Use whenever you're about to write a commit message, draft a PR description, open a PR, or are invoked by `/finish`.

## Doc

- [Commit and PR](../../../docs/process/commit-and-pr.md) — full format, examples, and rules.

## Quick rules (without reading anything else)

- **Commit subject**: a clear one-liner in domain terms. Sentence case. ≤72 chars. Names the change, not the file.
- **Commit body**: explain *why*, not *what*. Mention non-obvious tradeoffs. Bullets for distinct concerns; paragraphs for connected thoughts.
- **Trailer**: `Co-Authored-By: Claude <model> <noreply@anthropic.com>` when an agent contributed substantively.
- **Branch**: `<ticket-id-lowercase>-<short-kebab-desc>` (e.g., `jira-487-csv-export`). One ticket per branch.
- **PR title**: same shape as a commit subject; ≤70 chars. Becomes the squash subject — write it accordingly.
- **PR description**: `## Summary` (1–3 bullets + ticket link) then `## Test plan` (markdown checklist of what the reviewer should verify, including manual steps).
- **Never `--no-verify`**; never force-push to base branches; never amend pushed commits unless you own the branch.
- **Don't commit or open a PR without explicit user approval.** Drafting is free; executing is not.
