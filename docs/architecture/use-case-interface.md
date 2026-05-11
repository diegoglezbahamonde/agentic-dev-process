# Use case interface

## The rule

Every use case in the application layer is defined by an interface. The interface declares a single `execute` method that takes a command (or query) and returns a result (or `None` for commands). Implementations live alongside the interface in the application layer.

## Why

- Callers (HTTP routes, schedulers, tests) depend on the interface, not the implementation.
- The [use case executor](use-case-executor.md) wraps the interface to add cross-cutting concerns later.
- Swapping implementations in tests is trivial.

## Examples

### Good (Python)

```python
# application/use_cases/pay_invoice.py
from dataclasses import dataclass
from typing import Protocol

@dataclass(frozen=True)
class PayInvoiceCommand:
    invoice_id: str
    amount_cents: int

class PayInvoice(Protocol):
    def execute(self, command: PayInvoiceCommand) -> None: ...

class PayInvoiceUseCase:
    def execute(self, command: PayInvoiceCommand) -> None:
        # resolve dependencies via the locator, mutate aggregate, save
        ...
```

### Good (TypeScript)

```typescript
// application/use-cases/pay-invoice.ts
export type PayInvoiceCommand = { invoiceId: string; amountCents: number };

export interface PayInvoice {
  execute(command: PayInvoiceCommand): Promise<void>;
}

export class PayInvoiceUseCase implements PayInvoice {
  async execute(command: PayInvoiceCommand): Promise<void> { /* ... */ }
}
```

### Bad

```python
# Use case has no interface — callers depend on the concrete class.
class PayInvoiceUseCase:
    def execute(self, ...): ...
```

## Rules

- One use case = one interface = one implementation (per bounded context).
- The command/query is a frozen/readonly data class — no behavior.
- `execute` is the only public method.

## Related

- [ServiceLocator-style injection](service-locator-injection.md)
- [Use case executor](use-case-executor.md)
