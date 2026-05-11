# Docs

Authoritative source for the team's conventions. Each file documents one convention.

Skills under `.claude/skills/` are thin triggers that point here. The agent should never read all docs upfront — read only what the current task requires.

## Architecture

- [DDD overview](architecture/ddd-overview.md)
- [Hexagonal (ports & adapters)](architecture/hexagonal-ports-adapters.md)
- [Use case interface](architecture/use-case-interface.md)
- [ServiceLocator-style injection](architecture/service-locator-injection.md)
- [Use case executor](architecture/use-case-executor.md)
- [CQRS: read/write separation](architecture/cqrs-read-write-separation.md)

## Backend

- [Python conventions](backend/python-conventions.md)

## Frontend

- [TypeScript conventions](frontend/typescript-conventions.md)

## Database

- [NOT NULL fields](database/not-null-fields.md)
- [No business logic in defaults](database/no-business-logic-in-defaults.md)

## Testing

- [Test pyramid](testing/test-pyramid.md)
- [TDD workflow](testing/tdd-workflow.md)
- [Given / When / Then](testing/given-when-then.md)
- [Full-entity asserts](testing/full-entity-asserts.md)
- [Object mothers](testing/object-mothers.md)
