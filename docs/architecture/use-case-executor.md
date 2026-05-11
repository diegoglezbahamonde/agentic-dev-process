# Use case executor

## The rule

Use cases are never instantiated and called directly by inbound adapters. Adapters invoke them through the executor, passing the **use case class** (not an instance) and the input:

```python
result = executor.execute(ListInvoicesUseCase, ListInvoicesInput(customer_id="cust-1"))
executor.execute(PayInvoiceUseCase, PayInvoiceCommand("inv-1", 10_000))
```

The executor:

1. Constructs the use case via its **no-arg constructor** — the [hybrid pattern](service-locator-injection.md) self-resolves the use case's dependencies from the `ServiceLocator`.
2. Wraps the call with cross-cutting concerns (telemetry, transactions, retries — added over time).
3. Returns the result.

The same executor handles commands AND queries. There is no separate query bus.

## Why

- Adding OpenTelemetry spans, transaction boundaries, or retry policies later means changing **one file**, not every use case.
- Tests can wrap or replace the executor to assert cross-cutting behavior (`each use case ran inside a transaction`, `every command emitted a span`) without touching use case code.
- Inbound adapters (HTTP routes, CLI, workers) only depend on the executor and the use case class for type-safety. They never import use case implementations or wire dependencies.

## Minimal shape

```python
# application/use_case_executor.py
from typing import Type, TypeVar

from application.use_case import UseCase

I = TypeVar("I")
O = TypeVar("O")


class UseCaseExecutor:
    def execute(self, use_case_class: Type[UseCase[I, O]], input: I) -> O:
        instance = use_case_class()  # hybrid pattern self-resolves deps
        # later: open span, begin transaction, retry on transient errors, etc.
        return instance.execute(input)
```

The executor itself is registered in the `ServiceLocator` at the composition root, so use cases that chain can resolve it via the hybrid pattern (`executor: UseCaseExecutor | None = None` in the constructor).

## Inbound-adapter usage

```python
# interfaces/http/invoice_routes.py
@router.post("/invoices/{id}/pay")
def pay_invoice(id: str, body: PayBody, executor: UseCaseExecutor = Depends(get_executor)):
    executor.execute(PayInvoiceUseCase, PayInvoiceCommand(id, body.amount_cents))


@router.get("/customers/{cid}/invoices")
def list_customer_invoices(cid: str, executor: UseCaseExecutor = Depends(get_executor)) -> list[InvoiceListItem]:
    return executor.execute(ListInvoicesUseCase, ListInvoicesInput(customer_id=cid))
```

Both use cases — command and query — are invoked the same way. The route never instantiates `PayInvoiceUseCase()` itself and never imports an adapter.

## Use cases composing other use cases

A use case that needs to call another use case does so via the injected executor — not by constructing the other use case directly:

```python
class CancelAndRefundInvoiceUseCase(UseCase[CancelAndRefundInput, None]):
    def __init__(
        self,
        invoices: InvoiceRepository | None = None,
        executor: UseCaseExecutor | None = None,
    ):
        if invoices is None:
            invoices = ServiceLocator.find(InvoiceRepository.__name__)
        if executor is None:
            executor = ServiceLocator.find(UseCaseExecutor.__name__)
        self.invoices = invoices
        self.executor = executor

    def execute(self, input: CancelAndRefundInput) -> None:
        self.executor.execute(CancelInvoiceUseCase, CancelInvoiceCommand(input.invoice_id))
        self.executor.execute(RefundInvoiceUseCase, RefundInvoiceCommand(input.invoice_id))
```

Each chained call goes through the same executor, picking up the same cross-cutting concerns (a single trace span covers the parent and both children, transactions can nest, retries propagate).

## Rules

- **HTTP routes, CLI commands, and workers all go through the executor.** They never call `UseCaseClass().execute(...)` directly.
- **Use cases that compose other use cases also go through the executor.** Don't `OtherUseCase().execute(...)` from inside another use case — `self.executor.execute(OtherUseCase, input)`.
- **The executor takes a `Type[UseCase]`, not an instance.** It does the construction. Callers don't pre-instantiate.
- **Do not put domain logic in the executor.** It's a runtime boundary, not a layer. Logging, tracing, transaction boundaries — yes. Validation, business rules — no.

## Related

- [Use case interface](use-case-interface.md)
- [ServiceLocator-style injection](service-locator-injection.md)
- [CQRS: read/write separation](cqrs-read-write-separation.md)
