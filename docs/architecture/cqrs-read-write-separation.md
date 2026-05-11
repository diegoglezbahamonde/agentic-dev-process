# CQRS: read/write separation

## The rule

Lightweight separation between commands (writes) and queries (reads). Both go through the [use case executor](use-case-executor.md) using the same `UseCase[Input, Output]` interface — there is no separate "query handler" concept.

The split is:

- **Commands** (writes) load aggregates, mutate them, and persist via a write port (`InvoiceRepository`).
- **Queries** (reads) project from storage into DTOs shaped for the consumer via a read port (`InvoiceReader`). They do not construct aggregates by default. They never mutate.
- **Storage stays shared.** Eventually-consistent projections, separate read databases, and event sourcing are explicitly **out of scope** as a default — they are a per-feature decision when scale demands it, not a blanket commitment.

## Why

- Building an aggregate to render a list is expensive and pointless.
- Read shapes diverge from write shapes (lists, joins, search filters, projections). Forcing them through the aggregate twists the domain model to fit the screen.
- Separate ports keep the write model honest: when a read shape stops fitting the aggregate, you don't widen the aggregate — you add a reader.
- Treating queries as use cases (not a parallel "query handler" hierarchy) means one executor, one interface, one place to add cross-cutting concerns (telemetry, transactions, retries) — no parallel infrastructure to maintain.

## What this is NOT

- **Not event sourcing.** Writes mutate aggregates in place against the shared store.
- **Not separate read databases by default.** A read replica or a materialized view is a per-feature optimization later; it isn't the architecture.
- **Not "queries bypass the domain entirely."** Queries can compute and shape data in code (sorting, formatting, filtering), and if a read genuinely needs domain logic, that's allowed — but it must be justified, since the easy path is "load the aggregate" and that's what we're avoiding.

## Examples

### Good — write side (command)

A command loads the aggregate, mutates it, persists. Constructor uses the **hybrid pattern**: ports and the executor are optional constructor args, defaulting to `ServiceLocator.find(...)`.

```python
# application/use_cases/pay_invoice.py
from dataclasses import dataclass

from application.use_case import UseCase
from application.use_case_executor import UseCaseExecutor
from application.ports.invoice_repository import InvoiceRepository
from application.ports.clock import Clock
from infrastructure.service_locator import ServiceLocator


@dataclass(frozen=True, slots=True)
class PayInvoiceCommand:
    invoice_id: str
    amount_cents: int


class PayInvoiceUseCase(UseCase[PayInvoiceCommand, None]):
    def __init__(
        self,
        invoices: InvoiceRepository | None = None,
        clock: Clock | None = None,
        executor: UseCaseExecutor | None = None,
    ):
        if invoices is None:
            invoices = ServiceLocator.find(InvoiceRepository.__name__)
        if clock is None:
            clock = ServiceLocator.find(Clock.__name__)
        if executor is None:
            executor = ServiceLocator.find(UseCaseExecutor.__name__)
        self.invoices = invoices
        self.clock = clock
        self.executor = executor

    def execute(self, command: PayInvoiceCommand) -> None:
        invoice = self.invoices.get(command.invoice_id)
        invoice.pay(amount_cents=command.amount_cents, at=self.clock.now())
        self.invoices.save(invoice)
```

### Good — read side (query)

A query is a use case too. It calls a **read port** that returns DTOs shaped for the consumer. The DTO lives **next to the query**, not in the domain.

```python
# application/use_cases/list_invoices.py
from dataclasses import dataclass
from datetime import date, datetime

from application.use_case import UseCase
from application.use_case_executor import UseCaseExecutor
from application.ports.invoice_reader import InvoiceReader
from infrastructure.service_locator import ServiceLocator


@dataclass(frozen=True, slots=True)
class ListInvoicesInput:
    customer_id: str
    month: date | None = None


@dataclass(frozen=True, slots=True)
class InvoiceListItem:
    id: str
    customer_id: str
    amount_cents: int
    paid_at: datetime | None


class ListInvoicesUseCase(UseCase[ListInvoicesInput, list[InvoiceListItem]]):
    def __init__(
        self,
        reader: InvoiceReader | None = None,
        executor: UseCaseExecutor | None = None,
    ):
        if reader is None:
            reader = ServiceLocator.find(InvoiceReader.__name__)
        if executor is None:
            executor = ServiceLocator.find(UseCaseExecutor.__name__)
        self.reader = reader
        self.executor = executor

    def execute(self, input: ListInvoicesInput) -> list[InvoiceListItem]:
        return self.reader.list(
            customer_id=input.customer_id,
            month=input.month,
        )
```

The reader returns `list[InvoiceListItem]` directly — a thin projection from the shared store, not aggregates being flattened.

Both are invoked the same way:

```python
executor.execute(PayInvoiceUseCase, PayInvoiceCommand(invoice_id="inv-1", amount_cents=10_000))
executor.execute(ListInvoicesUseCase, ListInvoicesInput(customer_id="cust-1"))
```

### Bad — query loading aggregates to flatten them

```python
# application/use_cases/list_invoices.py
class ListInvoicesUseCase(UseCase[ListInvoicesInput, list[InvoiceListItem]]):
    def __init__(
        self,
        invoices: InvoiceRepository | None = None,   # ← write port reused for reads
        executor: UseCaseExecutor | None = None,
    ):
        if invoices is None:
            invoices = ServiceLocator.find(InvoiceRepository.__name__)
        if executor is None:
            executor = ServiceLocator.find(UseCaseExecutor.__name__)
        self.invoices = invoices
        self.executor = executor

    def execute(self, input: ListInvoicesInput) -> list[InvoiceListItem]:
        invoices = self.invoices.find_all(customer_id=input.customer_id)  # builds N aggregates
        return [
            InvoiceListItem(
                id=i.id,
                customer_id=i.customer_id,
                amount_cents=i.amount_cents,
                paid_at=i.paid_at,
            )
            for i in invoices
        ]
```

Same use case shell as the Good read-side example. The difference is the body: this one constructs `N` aggregates only to project each one away on the next line. Pay the construction cost once per row, multiplied by `N`. The `InvoiceReader` path produces the same DTOs without ever building an aggregate.

## Rules

- Read ports (`InvoiceReader`) are separate from write ports (`InvoiceRepository`) and return DTOs, not aggregates. Adapters live alongside write adapters in `infrastructure/persistence/`; storage is shared.
- Read DTOs (`InvoiceListItem`, `InvoiceSummary`, etc.) live **next to the query** under `application/use_cases/`, not in the domain. They are `@dataclass(frozen=True, slots=True)`.
- Queries go through `executor.execute(ListInvoicesUseCase, input)` — same as commands. No separate query bus, no parallel handler hierarchy.
- Reads never mutate. If a "read" needs to write (cache warming, last-seen, hit-count), it's a command — name it as one and split.
- If a read genuinely needs domain logic (e.g., reapplying a pricing rule across rows in code), justify it in the use case docstring or the ticket. The default is "no aggregates"; deviations are reviewed.
- Separate read stores, projections, and event sourcing are **per-feature opt-ins** justified by scale or query shape. They are not the default architecture and require their own ADR-level decision.

## Related

- [Hexagonal (ports & adapters)](hexagonal-ports-adapters.md)
- [Use case interface](use-case-interface.md)
- [ServiceLocator-style injection](service-locator-injection.md)
- [Use case executor](use-case-executor.md)
