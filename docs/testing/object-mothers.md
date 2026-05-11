# Object mothers

## The rule

Test data is built through **object mothers** — named factory functions that produce entities and value objects in well-known states. One mother per aggregate root (and per value object that's painful to construct).

```python
InvoiceMother.unpaid(amount_cents=10_000)
InvoiceMother.paid(paid_at=AT)
InvoiceMother.overdue(days_late=14)
```

Mothers live in `tests/mothers/` (or alongside the type under test in `__tests__/`), never in production code.

## Why

- **Tests read like specifications.** `InvoiceMother.overdue()` says what the test cares about; `Invoice(id="x", customer_id="y", amount_cents=10000, status="unpaid", due_date=date(2025,1,1), ...)` does not.
- **Schema changes touch one place.** Add a required field to `Invoice`, update the mother, every test keeps passing.
- **Named scenarios become reusable vocabulary.** "An overdue invoice" is a domain concept; encoding it as `InvoiceMother.overdue()` lets every test reuse it consistently.
- Pairs with [full-entity asserts](full-entity-asserts.md): the **Given** and the expected **Then** are built the same way.

## Shape

A mother is a class (or namespace) with named constructors. Each constructor:

1. Has sensible defaults for every field.
2. Accepts overrides via keyword arguments for the fields the test cares about.
3. Returns a real domain object, not a dict or a stub.

### Python

```python
# tests/mothers/invoice_mother.py
from datetime import datetime
from domain.invoice import Invoice, InvoiceStatus

class InvoiceMother:
    @staticmethod
    def unpaid(
        *,
        id: str = "inv-1",
        customer_id: str = "cust-1",
        amount_cents: int = 1_000,
        due_date: datetime = datetime(2026, 1, 1),
    ) -> Invoice:
        return Invoice(
            id=id,
            customer_id=customer_id,
            amount_cents=amount_cents,
            due_date=due_date,
            status=InvoiceStatus.UNPAID,
            paid_at=None,
        )

    @staticmethod
    def paid(*, paid_at: datetime, **overrides) -> Invoice:
        invoice = InvoiceMother.unpaid(**overrides)
        return invoice.with_status(InvoiceStatus.PAID, paid_at=paid_at)
```

### TypeScript

```typescript
// tests/mothers/invoice-mother.ts
import { Invoice, InvoiceStatus } from "@/domain/invoice";

export const InvoiceMother = {
  unpaid(overrides: Partial<Invoice> = {}): Invoice {
    return new Invoice({
      id: "inv-1",
      customerId: "cust-1",
      amountCents: 1_000,
      dueDate: new Date("2026-01-01"),
      status: InvoiceStatus.Unpaid,
      paidAt: null,
      ...overrides,
    });
  },

  paid(overrides: Partial<Invoice> & { paidAt: Date }): Invoice {
    return InvoiceMother.unpaid(overrides).withStatus(InvoiceStatus.Paid, overrides.paidAt);
  },
};
```

## Rules

- **Named scenarios over flag-bag arguments.** Prefer `InvoiceMother.overdue()` over `InvoiceMother.invoice(overdue=True)`. The named version reads like the domain.
- **Defaults must produce a valid object.** A test that doesn't care about `customer_id` shouldn't have to provide one.
- **Override only what the test cares about.** Every value spelled in the test should matter to the assertion. Magic numbers that don't affect outcome are noise.
- **No randomness.** `InvoiceMother.unpaid()` returns the same invoice every time. Random data hides bugs and breaks `==`.
- **Mothers build domain objects, not DTOs or DB rows.** For test fixtures at the persistence layer, write a separate `InvoiceRowFixture` — don't overload the mother.
- **One mother per aggregate root.** Don't make a generic `Mother` that builds anything.

## Related

- [Given / When / Then](given-when-then.md)
- [Full-entity asserts](full-entity-asserts.md)
- [TDD workflow](tdd-workflow.md)
