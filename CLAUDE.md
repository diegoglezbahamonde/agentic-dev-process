# Project context

Keep this file small. Conventions live in skills and docs, not here.

## Stack

- Backend: Python
- Frontend: TypeScript
- Architecture: hexagonal (ports & adapters) with DDD
- Testing: TDD, strict from day one. Unit + integration + API + E2E.

## How you (the agent) work here

Before writing or modifying code:

1. Read the relevant skill(s) under `.claude/skills/` — match by the skill's description.
2. Skills point to focused docs under `docs/`. Read only the docs the task touches.
3. **Do not read all docs upfront.** The map below is for navigation, not bulk reading.
4. Tests come first. No production code without a failing test that motivates it.
5. Never bypass hooks. If a hook blocks you, fix the underlying issue.
6. Never invent ticket IDs, API contracts, or library APIs. If unsure, ask or read the code.

## Workflow

Ticket-driven work goes through `/work TICKET-ID`. It enforces Explore → Plan → Implement → Verify with checkpoints. Do not code directly from a freeform prompt.

If you don't have a ticket yet, draft one with `/refine <idea>` first — the `ticket-refiner` subagent produces a structured story you can review before it lands in the tracker.

When you finish a piece of work, the `code-reviewer` subagent reviews your diff before you hand back to the human.

## Doc map

```
docs/
├── architecture/
│   ├── ddd-overview.md
│   ├── hexagonal-ports-adapters.md
│   ├── use-case-interface.md
│   ├── service-locator-injection.md
│   ├── use-case-executor.md
│   └── cqrs-read-write-separation.md
├── backend/
│   └── python-conventions.md
├── frontend/
│   └── typescript-conventions.md
├── database/
│   ├── not-null-fields.md
│   └── no-business-logic-in-defaults.md
├── process/
│   └── user-story.md
└── testing/
    ├── test-pyramid.md
    ├── tdd-workflow.md
    ├── given-when-then.md
    ├── full-entity-asserts.md
    └── object-mothers.md
```

## Project-specific notes

<!-- Per-project additions: domain glossary pointer, deployment quirks, deprecated subsystems not to extend. -->
