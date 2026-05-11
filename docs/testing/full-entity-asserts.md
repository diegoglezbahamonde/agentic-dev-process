# Full-entity asserts

## The rule

When asserting the state of an entity or value object after an action, assert the **entire object** against an expected instance — not a handful of cherry-picked fields.

```python
assert invoice == InvoiceMother.paid(amount_cents=10_000, paid_at=AT)
```

Not:

```python
assert invoice.status == "paid"
assert invoice.amount_cents == 10_000
```

## Why

- **Catches accidental field changes.** If `pay()` silently flips `cancelled_at`, a field-by-field assert misses it. A full-entity assert fails loudly.
- **The diff tells you everything.** When the test fails, pytest/jest prints the full expected-vs-actual object — you see all deltas at once instead of fixing one field, rerunning, fixing the next.
- **The expected object is documentation.** A reader sees the complete post-state of the action without reconstructing it from scattered asserts.
- Pairs naturally with [object mothers](object-mothers.md): the expected side is built the same way as the **Given** side, so changes to the schema only have to be made in the mother.

## Examples

### Good (Python)

```python
def test_paying_an_invoice_in_full_marks_it_paid():
    # Given
    invoice = InvoiceMother.unpaid(amount_cents=10_000)

    # When
    invoice.pay(amount_cents=10_000, at=AT)

    # Then
    assert invoice == InvoiceMother.paid(amount_cents=10_000, paid_at=AT)
```

### Good — collections too

```python
assert invoices == [
    InvoiceMother.paid(id="inv-1"),
    InvoiceMother.unpaid(id="inv-2"),
]
```

### Bad — field-by-field

```python
assert invoice.status == "paid"
assert invoice.paid_at == AT
assert invoice.amount_cents == 10_000
# Misses: invoice.cancelled_at silently set to AT by the new code path.
```

### Bad — asserting only the field that changed

```python
def test_pay_sets_status():
    invoice = InvoiceMother.unpaid()
    invoice.pay(...)
    assert invoice.status == "paid"   # everything else could be wrong
```

## Requirements on the entity

For full-entity asserts to work cleanly, entities and value objects need value-based equality. In Python, use `@dataclass(eq=True)` (the default) or override `__eq__`. In TypeScript, use a deep-equality matcher (`toEqual`, not `toBe`) and avoid identity-based comparisons.

If equality has to ignore something (e.g. `created_at` on a record where the test doesn't control the clock), inject the clock as a port and pin it — don't loosen the assert.

## When the rule bends

- **Large aggregates with many fields irrelevant to the test.** Prefer to test a smaller subject (a child entity, a value object). If you genuinely must, assert against a mother variant that captures the full expected state.
- **Snapshot tests** are the same idea, automated. Acceptable for stable shapes (HTTP responses); avoid for domain objects, where the explicit expected reads better.
- **Side-effect-only actions** (logging, metrics) — assert the side effect, not the entity.

## Related

- [Object mothers](object-mothers.md)
- [Given / When / Then](given-when-then.md)
