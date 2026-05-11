# No business logic in defaults

## The rule

Column defaults, generated columns, and triggers do not encode business rules. The domain decides values; the database stores what the domain wrote.

```sql
-- Bad: business logic in the schema
status         TEXT NOT NULL DEFAULT 'unpaid',
created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
display_name   TEXT GENERATED ALWAYS AS (first_name || ' ' || last_name) STORED,

-- Bad: trigger that "helps"
CREATE TRIGGER auto_overdue
BEFORE UPDATE ON invoices
FOR EACH ROW
EXECUTE FUNCTION mark_overdue_if_past_due();

-- Good: every value comes from the domain
status         TEXT NOT NULL,
created_at     TIMESTAMPTZ NOT NULL,
display_name   TEXT NOT NULL,
```

## Why

- **There are now two places that decide.** The domain says one thing; the database says another. When they disagree, you find out in production.
- **Tests pass with fakes that don't have your trigger.** Unit tests use an in-memory repository or SQLite; the Postgres trigger doesn't exist there. The behavior the trigger creates is invisible until staging.
- **Schema-as-logic is invisible to the agent and the reviewer.** A use case test specifying "creating an invoice sets status=unpaid" passes whether or not the use case sets it — because the default fills it in. The behavior isn't really tested.
- **Migrations become risky.** Changing a default or a generated expression silently changes the meaning of every row written after the migration; old rows keep the old behavior. Two regimes in one table.
- **Triggers are remote action at a distance.** A bug shows up on row N, but the cause is a trigger defined elsewhere that nothing imports. Grepping the application doesn't find it.

## What defaults are still fine

- **Tombstones / audit columns the application doesn't own**: `inserted_at TIMESTAMPTZ NOT NULL DEFAULT now()` purely for ops/forensics, never read by the domain. If the domain reads `created_at`, the domain sets it.
- **Surrogate primary keys**: `id UUID NOT NULL DEFAULT gen_random_uuid()` is fine *if* the domain doesn't depend on the ID being generated DB-side. Often the domain wants the ID before insert (for events, references) — generate in the application then.
- **Constraints, not defaults**: `CHECK (amount_cents > 0)` is a guardrail (refuses bad data) — it doesn't *invent* values. Constraints are good. Defaults that fill in business meaning are not.

## Patterns to refuse

- **`DEFAULT 'pending'` on a status column.** The use case that creates the row knows what status the row starts in. Make it pass it.
- **Generated columns for derived business data.** Compute in the domain or in a query. The aggregate owns its invariants.
- **Triggers that mutate other rows** (cascade flags, denormalized counters). Move to the application layer; expose as a use case if needed.
- **`updated_at` updated by a trigger.** Looks innocent, but couples the domain to "I always set updated_at by writing." Set it explicitly.

## Related

- [NOT NULL fields](not-null-fields.md)
- [DDD overview](../architecture/ddd-overview.md)
- [Hexagonal (ports & adapters)](../architecture/hexagonal-ports-adapters.md)
