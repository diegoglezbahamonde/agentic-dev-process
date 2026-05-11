# NOT NULL fields

## The rule

Every column is `NOT NULL` unless the absence of a value is itself a meaningful domain state. "We don't have it yet" or "we forgot to set it" are not domain states.

```sql
-- Good
amount_cents       BIGINT      NOT NULL,
created_at         TIMESTAMPTZ NOT NULL,
status             TEXT        NOT NULL,
paid_at            TIMESTAMPTZ NULL,    -- legitimately optional: unpaid invoices have no paid_at

-- Bad
customer_id        TEXT        NULL,    -- an invoice without a customer is nonsense
amount_cents       BIGINT      NULL,    -- the invoice's amount is part of its identity
status             TEXT        NULL,    -- "no status" isn't a thing
```

## Why

- **`NULL` is three-valued logic.** `WHERE status = 'paid'` silently excludes nulls. `WHERE status != 'paid'` *also* silently excludes them. Most queries that look right are wrong when nulls are around.
- **Unique constraints behave surprisingly.** `(customer_id, external_ref)` with `external_ref NULL` allows multiple rows in most databases — usually not what was intended.
- **`NULL` lets bugs persist.** A row written without a required field stays in the table forever, breaking downstream code one query at a time. `NOT NULL` fails the bug at write time.
- **Domain alignment.** If the domain object's field is `int`, the column should be `NOT NULL`. If the domain field is `int | None`, the column is nullable — and the `None` is a real, named state, not "missing".
- **Index size and query plans.** Nullable indexed columns sometimes change planner choices and bloat indexes with sentinel rows. Avoid the surprise.

## When `NULL` is the right choice

- The field is **genuinely optional in the domain**: `paid_at` on an invoice that may never be paid; `cancelled_at` on a subscription.
- The absence has a name in the ubiquitous language: an invoice is *unpaid* (paid_at IS NULL) or *paid* (paid_at IS NOT NULL). The state, not just the lack, is meaningful.

If the absence has no domain name, it's not a domain state — pick a default and make the column `NOT NULL`.

## Patterns

- **No `default ''` to dodge `NOT NULL`.** Empty strings and zero are not "absent"; they're valid values that mean "empty" or "zero" — usually a different bug.
- **Booleans are `NOT NULL` with a default.** A nullable boolean is three states pretending to be two.
- **For "we'll add this later" columns**: backfill before adding the constraint, or model the optional nature explicitly in the domain. Don't ship a nullable column "for now".

## Migrations

Adding `NOT NULL` to an existing nullable column on a large table requires a backfill + constraint validation in two steps to avoid a long lock. The two-step pattern (backfill, then `SET NOT NULL`) is fine; the shortcut (just `ALTER COLUMN ... SET NOT NULL` on a billion-row table) is not.

## Related

- [No business logic in defaults](no-business-logic-in-defaults.md)
- [DDD overview](../architecture/ddd-overview.md)
