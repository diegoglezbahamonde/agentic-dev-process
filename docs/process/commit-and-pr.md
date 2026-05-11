# Commit and PR

How this team writes commits, names branches, and structures PRs.

## Commit messages

### Subject (first line)

- One clear sentence in domain terms. Not strictly Conventional Commits — informativeness beats prefix discipline.
- ≤72 characters; aim for ≤50 if you can.
- Sentence case (`Add CSV export for paid invoices`), not all-lower, not Title Case.
- Names the **change in domain language** (`Add CSV export for paid invoices`), not the file or function (`Update invoice.py`).
- A leading scope is fine if it adds clarity (`billing: add CSV export for paid invoices`); not required.

### Body

- Blank line after the subject.
- Explain **why** the change exists, not what changed — the diff shows what.
- Mention non-obvious tradeoffs and any follow-ups intentionally deferred.
- Bullet lists for multiple distinct concerns; paragraphs for one connected thought.
- Wrap at ~72 cols for terminal readability.

### Trailers

- `Co-Authored-By: Claude <model> <noreply@anthropic.com>` when an agent contributed substantively. (Setting `attribution.commit` in `.claude/settings.json` automates this.)
- `Refs:` or `Closes:` for ticket linkage if your tracker doesn't auto-link from the branch name.

### Example

```
Add CSV export for paid invoices

Finance does this by hand each month and the report is consistently
late. A queryable export endpoint takes the manual step out of the
loop.

The reader bypasses the domain (CQRS — list reads project directly to
DTOs) so we don't construct N invoice aggregates per request.

Defers: a UI for picking the month — finance is fine with a curl-able
URL for now. See JIRA-501 if/when we change that.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
```

## Branch naming

`<ticket-id-lowercase>-<short-kebab-description>`

- `jira-487-csv-export`
- `lin-1234-overdue-banner`

One ticket per branch. Don't reuse a branch across tickets — squash-merging assumes a clean cut between stories.

## PR title

Same shape as a commit subject. ≤70 chars. The user reading the PR list scans these — make them informative on their own without needing the description.

If the team squash-merges (default), the PR title becomes the squash commit's subject. Write it accordingly.

## PR description

Two required sections, in this order:

```markdown
## Summary
- 1–3 bullets describing what shipped and the user-visible effect.
- Link to ticket: [JIRA-487](https://your-org.atlassian.net/browse/JIRA-487).

## Test plan
- [ ] Unit tests cover the new behavior (paid month, empty month, cancelled-after-paid).
- [ ] Integration test added for the InvoiceReader adapter.
- [ ] Manual: `curl /exports/paid-invoices?month=2026-05` returns CSV with expected header.
- [ ] Manual: same URL with a month that has zero paid invoices returns header-only response.
```

The Test plan is a **checklist the reviewer ticks as they verify**. It's not "tests I wrote"; it's "what to check before approving". Manual steps are fine — the reviewer needs to know what to actually do.

For docs-only or pure refactor PRs, the Test plan can be a single line (`- [ ] N/A — docs only` or `- [ ] Existing suite passes`). Don't pad.

## Rules

- **Never `--no-verify`** to skip hooks. If a hook fails, fix the underlying issue.
- **Never `--no-gpg-sign`** to skip signing if the repo requires it.
- **Never force-push to a base branch** (`main`, `master`, `develop`). On feature branches, force-push only after confirming the branch is yours alone.
- **Never amend a commit that's been pushed** unless you own the branch and the rewrite is intentional.
- **Don't commit unless the user asked.** You may draft commit messages freely; running `git commit` requires explicit consent.
- **Don't open a PR without the user.** `/finish` drafts the title + body and asks before creating.
- **One commit per logical change** is ideal but not enforced — during `/work` it's fine to land work as several green-point commits, since the team squash-merges. The squash message is what the team sees.

## Related

- [User story](user-story.md) — PR Summary often paraphrases the ticket Story; PR Test plan derives from the ticket's acceptance criteria.
- [TDD workflow](../testing/tdd-workflow.md) — green-point commits during `/work` are how the squash gets its clean history.
