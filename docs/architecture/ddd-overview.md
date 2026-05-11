# DDD overview

## The rule

Model the domain explicitly. Code uses the vocabulary of the business, not the framework. Domain logic lives in entities, value objects, aggregates, and domain services — never in controllers, repositories, or use cases.

## Why

- Conversations with stakeholders and code refer to the same names.
- Behavior is where the data is, not scattered across services.
- Infrastructure changes (DB, HTTP framework) leave the domain untouched.

## Layers

```
domain         ← entities, value objects, aggregates, domain events, domain services. No external deps.
application    ← use cases (interface + impl), ports. Depends only on domain.
infrastructure ← adapters that implement ports (DB, HTTP clients, message bus).
interfaces     ← HTTP routes, CLI, workers. Translate transport into use case calls.
```

Dependencies point inward. The domain knows nothing about the rest.

## Key building blocks

- **Entity** — identity-bearing object. Equality is by ID.
- **Value object** — equality by value. Immutable. Self-validating.
- **Aggregate** — consistency boundary. A root entity guarding invariants over its internals. One aggregate per transaction.
- **Domain event** — something that happened in the past. Named in past tense (`InvoicePaid`, not `PayInvoice`).
- **Domain service** — behavior that doesn't naturally belong to a single entity (e.g. a pricing calculation across multiple aggregates).

## Ubiquitous language

Maintain a `docs/domain-glossary.md` per project listing the domain terms. Code identifiers must use those terms. If product calls it "invoice" and code calls it "bill", that's a bug.

## Related

- [Hexagonal (ports & adapters)](hexagonal-ports-adapters.md)
- [Use case interface](use-case-interface.md)
