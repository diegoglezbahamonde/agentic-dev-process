---
description: Refine a freeform idea into a draft ticket via the ticket-refiner subagent. Iterate via Q&A; create the ticket in the tracker only when the user approves.
argument-hint: <freeform idea>
---

# /refine

You are refining the following idea into a ticket-ready story:

> $ARGUMENTS

## Step 1 — Draft

Invoke the `ticket-refiner` subagent via the Agent tool. Pass it:

- The freeform idea verbatim (above).
- Any conversation context that's directly relevant.

The subagent returns:

- A draft in the team's five-section format (Title, Story, Domain, Technical notes, Open questions).
- A numbered list of open questions.

Render the draft to the user as-is. **Do not paraphrase or shorten** — the user reads exactly what the refiner produced.

## Step 2 — Iterate

The user answers the questions, asks for changes, or says they're satisfied. For each round of feedback, re-invoke the `ticket-refiner` with:

- The previous draft (verbatim).
- The user's answers and change requests.

Show the updated draft. Repeat until the user is satisfied. Don't try to refine in your own context — the subagent has the skill loaded and the conventions; you'd lose fidelity by editing the draft yourself.

## Step 3 — Land it

When the user explicitly says "write it to Jira" / "create the ticket" / "ship it" / similar:

1. **If a Jira / Linear / Shortcut MCP is configured**, use it to create the ticket. Map sections sensibly:
   - **Title** → ticket title
   - **Story** + **Domain** + **Technical notes** + **Open questions** → description (markdown body)
   - Set the project / type per the user's tracker conventions; ask if unsure.
2. **If no tracker MCP is configured**, save the draft to `.tickets/<slug>.md` (where `<slug>` is a kebab-case version of the title). Tell the user to assign an ID when they file it.
3. Report the ticket ID (or filename) so the user can pick up with `/work <ID>` next.

**Do not create the ticket without an explicit go-ahead.** Drafts iterate cheaply; tracker tickets create noise (notifications, watchers, dashboards). When in doubt, ask.
