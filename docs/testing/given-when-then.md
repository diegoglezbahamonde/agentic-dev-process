# Given / When / Then

## The rule

Every test has three sections, in this order, visually separated:

- **Given** — the state of the world before the action (setup, fixtures, prior events).
- **When** — the single action under test.
- **Then** — the observable outcome (return value, state change, emitted event).

Mark them with blank lines, comments, or both. One **When** per test.

## Why

- A reader can scan the test and understand *what behavior is being specified* in seconds.
- One **When** per test means one failure = one diagnosis. Tests with multiple actions hide which step broke.
- The **Given** section forces you to name preconditions explicitly. If setup is enormous, the design is screaming at you.

## Examples

### Good (Python)

```python
def test_paying_an_invoice_in_full_marks_it_paid():
    # Given
    invoice = InvoiceMother.unpaid(amount_cents=10_000)

    # When
    invoice.pay(amount_cents=10_000, at=A_FIXED_TIME)

    # Then
    assert invoice == InvoiceMother.paid(
        amount_cents=10_000,
        paid_at=A_FIXED_TIME,
    )
```

### Good (TypeScript)

```typescript
test("paying an invoice in full marks it paid", () => {
  // Given
  const invoice = InvoiceMother.unpaid({ amountCents: 10_000 });

  // When
  invoice.pay({ amountCents: 10_000, at: A_FIXED_TIME });

  // Then
  expect(invoice).toEqual(
    InvoiceMother.paid({ amountCents: 10_000, paidAt: A_FIXED_TIME }),
  );
});
```

### Bad — multiple Whens

```python
def test_invoice_lifecycle():
    invoice = InvoiceMother.unpaid()
    invoice.pay(...)            # When 1
    assert invoice.is_paid
    invoice.refund(...)         # When 2
    assert invoice.is_refunded
```

Split this into `test_paying_marks_it_paid` and `test_refunding_a_paid_invoice_marks_it_refunded` (the latter's **Given** is a paid invoice).

### Bad — no visual separation

```python
def test_pay():
    invoice = InvoiceMother.unpaid(amount_cents=10_000)
    invoice.pay(amount_cents=10_000, at=A_FIXED_TIME)
    assert invoice.status == "paid"
```

Works, but the reader has to parse the lines to find the action. Add the blank lines and the `# Given / When / Then` comments.

## Rules

- One **When** per test. If you need a second action, that action's preconditions become the next test's **Given**.
- Test names describe the **Then** in domain language (`paying_an_invoice_in_full_marks_it_paid`), not the function being called (`test_pay`).
- Use [object mothers](object-mothers.md) in **Given**, not inline construction with magic numbers.
- Prefer [full-entity asserts](full-entity-asserts.md) in **Then** over plucking individual fields.

## Related

- [TDD workflow](tdd-workflow.md)
- [Object mothers](object-mothers.md)
- [Full-entity asserts](full-entity-asserts.md)
