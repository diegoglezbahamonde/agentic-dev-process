# User story

## The shape

Every story has these sections, in this order:

1. **Title** — action-oriented, in domain language (`Allow finance to export paid invoices as CSV`).
2. **Story** — one paragraph: *"As a `<role>`, I want `<goal>`, so that `<reason>`."*
3. **Domain — acceptance criteria** — concrete scenarios in **Given / When / Then**.
4. **Technical notes** — bounded context, aggregates, ports/adapters, read vs write.
5. **Open questions** — anything not resolved yet, named explicitly.

## Why

- The domain section gives the implementer **testable behaviors** (one per scenario), in the team's language. Acceptance criteria become the first failing tests in the [TDD loop](../testing/tdd-workflow.md).
- The technical section forces an early architectural read — we don't discover the wrong bounded context mid-implementation.
- The open-questions section makes assumptions visible. The worst stories are the ones whose author silently picked an interpretation.

## Example

```
### Title
Allow finance to export paid invoices as CSV

### Story
As a finance analyst, I want to export the paid invoices for a given month
as a CSV, so that I don't have to copy them by hand into the monthly report.

### Domain — acceptance criteria

**Scenario 1: exporting a month with paid invoices**
- Given there are 14 paid invoices in May 2026
- When I request the May 2026 export
- Then the CSV contains 14 rows plus header `id,customer_id,amount_cents,paid_at`

**Scenario 2: a month with no paid invoices**
- Given there are 0 paid invoices in June 2026
- When I request the June 2026 export
- Then the CSV contains only the header row (no error)

**Scenario 3: cancelled invoices are excluded**
- Given an invoice was paid in May and cancelled in June
- When I request the May 2026 export
- Then the cancelled-but-paid invoice does not appear in the CSV

### Technical notes
- **Bounded context**: `billing`
- **Read or write**: read (CQRS query — bypass the domain).
- **Outbound ports**: `InvoiceReader` (new), `Clock` (existing).
- **Inbound**: new HTTP route `GET /exports/paid-invoices?month=YYYY-MM` returning `text/csv`.
- **Performance**: exports of up to 100k rows must complete in <2s on a single replica.
- **Testing**: unit tests for the projection; API test for the route + CSV shape.

### Open questions
1. Is "May 2026" closed-month-at-request-time or always the calendar month? Affects caching.
2. Should the export include refunded-after-paid invoices? (Currently the domain treats refund as a separate state.)
3. Authn/Authz: who can hit this endpoint — any authenticated user, or finance role only?
```

## Rules

- **Acceptance criteria are scenarios, not bullet lists.** "Should handle empty months" is not a scenario; "Given 0 invoices, When I request X, Then the CSV contains only the header" is.
- **Use the [ubiquitous language](../architecture/ddd-overview.md).** If the product calls it `invoice`, the story says `invoice`, not `bill`.
- **Every scenario maps to at least one test.** Often a unit test for the rule + an API/integration test for the wire.
- **Technical notes name the bounded context first.** The implementer needs to know which directory to open before anything else.
- **Classify read vs write up front** ([CQRS](../architecture/cqrs-read-write-separation.md)). The two paths look very different.
- **Never zero open questions if you have any.** "Pretending to know" produces stories that look ready and aren't. Three honest questions beats a confident-sounding draft.

## When to skip the structure

For a true tiny ticket — typo fix, config bump, one-line doc edit — a one-sentence ticket is fine. The structure is for any story that takes more than ~an hour to implement.

## Related

- [TDD workflow](../testing/tdd-workflow.md) — acceptance criteria become the first failing tests.
- [Hexagonal (ports & adapters)](../architecture/hexagonal-ports-adapters.md) — the Technical section names the ports and adapters touched.
- [CQRS: read/write separation](../architecture/cqrs-read-write-separation.md) — classify each story as command or query early.
- [Given / When / Then](../testing/given-when-then.md) — same structure as the test layer; write the scenarios in the same shape.
