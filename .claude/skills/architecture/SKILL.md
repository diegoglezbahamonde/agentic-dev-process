---
name: architecture
description: Architectural rules for this project — DDD, hexagonal (ports & adapters), use case interface in the application layer, ServiceLocator-style injection, use case executor, and CQRS-style read/write separation. Use this skill before adding a new use case, port, adapter, route, or domain object, and before changing layer dependencies. Skip for pure infrastructure tweaks (renaming a column, bumping a lib version).
---

# Architecture

Use this skill whenever you touch the application, domain, or infrastructure layers, or when you add a new use case, port, or adapter. Read only the docs relevant to the task.

## Doc map

- [DDD overview](../../../docs/architecture/ddd-overview.md) — layer responsibilities and dependency direction. Read for any cross-layer change.
- [Hexagonal (ports & adapters)](../../../docs/architecture/hexagonal-ports-adapters.md) — folder layout and the port/adapter pattern. Read when adding an adapter.
- [Use case interface](../../../docs/architecture/use-case-interface.md) — interface + command shape. Read when adding a use case.
- [ServiceLocator-style injection](../../../docs/architecture/service-locator-injection.md) — how use cases resolve dependencies. Read when adding a dependency to a use case.
- [Use case executor](../../../docs/architecture/use-case-executor.md) — how use cases are invoked. Read when wiring an HTTP route, CLI command, or worker.
- [CQRS: read/write separation](../../../docs/architecture/cqrs-read-write-separation.md) — lightweight separation: separate read/write ports, reads return DTOs, storage stays shared. Read when adding a list, search, or report endpoint.

## Quick rules (without reading anything else)

- Domain has no imports from application or infrastructure.
- Use cases implement `UseCase[Input, Output]`. Constructor uses the **hybrid pattern**: ports and the executor are optional args, defaulting to `ServiceLocator.find(<Port>.__name__)`. Tests pass deps explicitly; production calls the no-arg constructor.
- Commands AND queries are use cases through the same executor — `executor.execute(UseCase, input)`. There is no separate query-handler concept.
- Reads have their own ports (`InvoiceReader` vs `InvoiceRepository`) and return DTOs shaped for the consumer. They don't construct aggregates by default.
- Storage stays shared. Separate read stores / event sourcing are per-feature decisions when scale demands, not the default.
