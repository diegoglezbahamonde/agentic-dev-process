---
name: database
description: Database conventions for this project — every column NOT NULL unless absence is a real domain state, and no business logic in column defaults, generated columns, or triggers (the domain owns values, the database stores them). Use this skill before writing or modifying a migration, schema definition, ORM model, or DDL. Skip for read-only queries and pure indexing changes.
---

# Database

Use this skill whenever you write a migration, define a schema, edit an ORM model, or add a constraint/trigger. Read only the doc(s) relevant to the change.

## Doc map

- [NOT NULL fields](../../../docs/database/not-null-fields.md) — `NOT NULL` is the default; `NULL` requires a domain justification. Read when adding or changing a column's nullability.
- [No business logic in defaults](../../../docs/database/no-business-logic-in-defaults.md) — defaults, generated columns, and triggers do not encode business rules. Read when tempted to put a `DEFAULT`, `GENERATED`, or trigger on something the domain reads.

## Quick rules (without reading anything else)

- Default to `NOT NULL`. Make `NULL` only when the absence is a named domain state (e.g. `paid_at` on an unpaid invoice).
- No `DEFAULT` for columns the domain reads. The use case sets the value; the database stores it.
- No `GENERATED ALWAYS AS` for derived business data. Compute in the domain or in a query.
- No triggers that mutate rows for business reasons. Move to the application; expose as a use case if needed.
- `CHECK` constraints are fine — they refuse bad data, they don't invent it.
- Adding `NOT NULL` to a populated column on a large table requires backfill first, then the constraint. No long-locking single-statement migrations.
