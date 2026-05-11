---
name: user-story
description: How this team writes user stories — five-section format (Title, Story, Domain acceptance criteria as Given/When/Then scenarios, Technical notes naming bounded context and ports/adapters, Open questions). Use when refining a freeform idea into a draft ticket (including from /refine), reviewing a draft story before it lands in the tracker, or when /work encounters a ticket missing this structure.
---

# user-story

Use this skill when drafting, reviewing, or refining a ticket — including from the `/refine` command.

## Doc

- [User story](../../../docs/process/user-story.md) — full structure, worked example, and rules.

## Quick rules (without reading anything else)

- **Five sections, in order**: Title, Story, Domain (acceptance criteria as GWT), Technical notes, Open questions.
- **Scenarios are concrete**: Given `<state>`, When `<action>`, Then `<observable outcome>`. No vague "should handle X".
- **Ubiquitous language wins.** Product's term beats engineering's. If product calls it `invoice`, the story says `invoice`.
- **Technical notes lead with the bounded context**, then aggregates, then ports/adapters, then read-or-write classification.
- **Classify reads vs writes early** (CQRS). The two paths look very different — choosing late is expensive.
- **Never zero open questions if you have any.** Pretending to know breeds wrong implementations.

## Related skills

- [architecture](../architecture/SKILL.md) — Technical-notes section uses these names (port, adapter, aggregate, bounded context).
- [testing](../testing/SKILL.md) — acceptance criteria become the first failing tests; same Given/When/Then structure.
