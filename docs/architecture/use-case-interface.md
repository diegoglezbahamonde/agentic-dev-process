# Use case interface

## The rule

Every use case in the application layer is a class that:

1. Inherits from `UseCase[Input, Output]` — a generic abstract base.
2. Has a single `execute(input: Input) -> Output` method.
3. Uses the [hybrid pattern](service-locator-injection.md) for dependencies.

The same interface covers commands AND queries — there is no separate "query handler" hierarchy. The output type is `None` for commands; a DTO or `list[DTO]` for queries.

## Why

- One interface means one [executor](use-case-executor.md) wrapping every use case — telemetry, transactions, retries are added in one place, not two.
- Generic typing (`UseCase[ApiInput, None]`, `UseCase[ListInput, list[Item]]`) lets static checkers verify input/output types end-to-end from the inbound adapter through the use case.
- The hybrid pattern keeps tests easy without making constructor signatures hide their deps.

## Definition

```python
# application/use_case.py
from abc import ABC, abstractmethod
from typing import Generic, TypeVar

I = TypeVar("I")
O = TypeVar("O")


class UseCase(ABC, Generic[I, O]):
    @abstractmethod
    def execute(self, input: I) -> O: ...
```

## Examples

### Good — command (output is `None`)

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

### Good — query (output is a DTO)

Same shape, just with a non-`None` return type. The DTO is defined next to the query, not in the domain.

```python
# application/use_cases/list_invoices.py
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
        return self.reader.list(customer_id=input.customer_id, month=input.month)
```

See [CQRS: read/write separation](cqrs-read-write-separation.md) for read-port and DTO-placement conventions.

### Bad

```python
# Plain class — no UseCase[Input, Output] base. Ad-hoc execute shape, no
# generic typing, the executor's contract is implicit.
class PayInvoiceUseCase:
    def execute(self, command):
        ...

# Separate "query handler" hierarchy. We don't do this — queries are use cases.
class ListInvoicesQuery:
    def handle(self, input):
        ...

# Mixing public methods on a use case. execute is the only entry point.
class PayInvoiceUseCase(UseCase[PayInvoiceCommand, None]):
    def execute(self, command): ...
    def reverse(self, command): ...   # ← this is a separate use case, not a method
```

## Rules

- **One use case = one class = one `execute` method.** No additional public methods. Reverse / cancel / etc. are their own use cases.
- **Inputs are `@dataclass(frozen=True, slots=True)`.** Same shape for both command inputs and query inputs.
- **Output is `None` for commands**, and a DTO (or `list[DTO]`, `Iterator[DTO]`) for queries. Query DTOs live next to the use case under `application/use_cases/`, never in the domain.
- **Class name ends in `UseCase`** — `PayInvoiceUseCase`, `ListInvoicesUseCase`. Don't mix `Query`, `Handler`, `Service` suffixes.
- **The constructor follows the [hybrid pattern](service-locator-injection.md).** Don't take a bare `ServiceLocator`; don't make all deps required either.

## Related

- [ServiceLocator-style injection](service-locator-injection.md)
- [Use case executor](use-case-executor.md)
- [CQRS: read/write separation](cqrs-read-write-separation.md)
