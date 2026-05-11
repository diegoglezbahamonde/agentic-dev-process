---
name: testing
description: Testing conventions for this project — TDD-strict (red-green-refactor, test before code), the test pyramid (unit > integration > API > E2E), Given/When/Then structure, full-entity asserts, and object mothers for test data. Use this skill before writing or modifying any test, before writing production code (TDD requires the failing test first), and when adding test fixtures or choosing which layer of the pyramid a test belongs at. Skip for trivial doc-only or rename-only changes.
---

# Testing

Use this skill whenever you write a test, modify a test, or are about to write production code (TDD requires the test first). Read only the docs relevant to the task.

## Doc map

- [Test pyramid](../../../docs/testing/test-pyramid.md) — which layer this test belongs at. Read when choosing where to add a test.
- [TDD workflow](../../../docs/testing/tdd-workflow.md) — red-green-refactor, one test at a time. Read before writing any production code.
- [Given / When / Then](../../../docs/testing/given-when-then.md) — test structure and naming. Read when authoring a test.
- [Full-entity asserts](../../../docs/testing/full-entity-asserts.md) — assert against expected entities, not picked fields. Read when writing the **Then** of a test.
- [Object mothers](../../../docs/testing/object-mothers.md) — named factories for test data. Read when constructing test fixtures or adding a new aggregate.

## Quick rules (without reading anything else)

- No production code without a failing test that motivates it. See the red before writing the green.
- One **When** per test. Sections labelled **Given / When / Then**.
- Test name describes the **Then** in domain language (`paying_in_full_marks_invoice_paid`), not the function called.
- Assert the full entity against an expected one (`assert invoice == InvoiceMother.paid(...)`), not field by field.
- Build test data through object mothers (`InvoiceMother.overdue()`), not inline construction.
- A bug fix lands with a regression test at the **lowest layer** that reproduces it.
