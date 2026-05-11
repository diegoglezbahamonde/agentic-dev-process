# ServiceLocator-style injection

## The rule

Use cases do not receive their adapters via constructor injection. Instead, they receive a `ServiceLocator` (a typed registry) and resolve adapters at the point of use:

```python
repo = self.locator.find(InvoiceRepository)
```

The locator is constructed once at the composition root and threaded through the use case executor.

## Why

- Use case constructors stay empty — adding a new dependency mid-method doesn't ripple to call sites.
- The [use case executor](use-case-executor.md) can swap the locator per call (e.g. a transactional locator that yields a per-transaction repository).
- Tests build a locator with fakes once and reuse it across many use cases.

## Tradeoff

ServiceLocator hides dependencies from the constructor signature, which is a knock against discoverability. We accept that cost because executor-based composition matters more to us than constructor-as-documentation.

## Examples

### Good (Python)

```python
class PayInvoiceUseCase:
    def __init__(self, locator: ServiceLocator) -> None:
        self.locator = locator

    def execute(self, command: PayInvoiceCommand) -> None:
        invoices = self.locator.find(InvoiceRepository)
        clock = self.locator.find(Clock)
        invoice = invoices.get(command.invoice_id)
        invoice.pay(amount_cents=command.amount_cents, at=clock.now())
        invoices.save(invoice)
```

### Bad

```python
# Constructor injection — not our pattern.
class PayInvoiceUseCase:
    def __init__(self, invoices: InvoiceRepository, clock: Clock) -> None:
        ...
```

## Rules

- The locator is the only dependency in the constructor.
- Resolve each port once near the top of `execute`, then use it.
- Never store resolved adapters as instance state — resolve fresh each call so per-call locator swaps work.

## Related

- [Use case interface](use-case-interface.md)
- [Use case executor](use-case-executor.md)
