# Test pyramid

## The rule

Tests are layered by scope and cost. Most tests live at the bottom (cheap, focused); fewer at the top (expensive, end-to-end). Each layer has a distinct job — don't duplicate the same assertion across layers.

```
        /\
       /  \    E2E         (handful)         — the system from a user's seat
      /----\   API         (dozens)          — HTTP contract with real adapters
     /------\  Integration (hundreds)        — adapter ↔ real dependency
    /--------\ Unit        (thousands)       — domain + use cases with fakes
```

## Layers

### Unit
- **Subject**: a single domain object, value object, or use case in isolation.
- **Dependencies**: in-memory fakes for ports. No DB, no network, no clock.
- **Speed**: milliseconds. Run on every save.
- **What they prove**: business rules and use case orchestration are correct.

### Integration
- **Subject**: an outbound adapter against the real dependency it wraps (Postgres, Redis, S3 — via testcontainers or a docker-compose).
- **Speed**: seconds.
- **What they prove**: the adapter speaks the dependency's protocol correctly. SQL works, migrations apply, pagination paginates.

### API (contract)
- **Subject**: an inbound HTTP/CLI adapter wired to the real application + real outbound adapters.
- **Speed**: seconds.
- **What they prove**: routing, serialization, status codes, auth — the wire contract.

### E2E
- **Subject**: the deployed system, exercised through the same surface a user uses (browser, CLI invocation).
- **Speed**: tens of seconds to minutes.
- **What they prove**: the pieces are wired together. Reserved for golden paths.

## Why

- Cheap tests give fast feedback during the [TDD loop](tdd-workflow.md). If you have to spin up a browser to test a pricing rule, you won't write the test.
- Each layer's failures point to a different cause. A red unit test says "the rule is wrong"; a red API test says "the wiring is wrong". Mixed-purpose tests can't do that.
- Slow tests at the bottom of the pyramid become un-runnable; fast tests at the top become flaky and shallow.

## Rules

- A bug fix lands with a failing test at the **lowest layer that reproduces it**. If the bug is in a domain rule, the regression test is a unit test — not an E2E.
- Don't reach into the database from a unit test. If you need the DB, it's an integration test by definition.
- E2E tests cover golden paths only. Edge cases belong below.
- No layer is optional. A project with no integration tests can't trust its adapters; a project with no E2E can't trust its wiring.

## Related

- [TDD workflow](tdd-workflow.md)
- [Given / When / Then](given-when-then.md)
- [Hexagonal (ports & adapters)](../architecture/hexagonal-ports-adapters.md)
