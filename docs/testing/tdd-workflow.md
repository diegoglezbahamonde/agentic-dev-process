# TDD workflow

## The rule

No production code is written without a failing test that motivates it. The loop is **red → green → refactor**, one test at a time.

1. **Red** — write the smallest failing test that captures the next behavior. Run it. See it fail for the *right reason* (not import errors, not typos).
2. **Green** — write the minimum production code that makes the test pass. Resist the urge to generalize.
3. **Refactor** — with the suite green, clean up duplication, improve names, extract collaborators. Tests must stay green throughout.

Repeat. Commits happen at green points.

## Why

- The test specifies the behavior in the language of the domain *before* implementation bias creeps in.
- "Smallest failing test" forces small steps; small steps mean small mistakes.
- The refactor step is non-negotiable — it's the only thing that prevents TDD from producing low-quality code that "happens to pass".
- A green suite at every commit means `git bisect` actually works.

## Examples

### Good — one behavior per cycle

```
red:    test_pay_invoice_marks_it_paid          → fails (Invoice has no .pay)
green:  add Invoice.pay() that sets status      → passes
refactor: rename internal field, suite still green
red:    test_pay_invoice_rejects_overpayment    → fails
green:  add the guard                            → passes
```

### Bad — writing four tests, then implementing

```
# Writes test_pay, test_overpay, test_double_pay, test_partial_pay
# All fail. Spends 40 minutes implementing. Three pass, one fails for an
# unrelated reason. Now debugging in the dark.
```

### Bad — writing the implementation first, then a test that "covers" it

```
# Implementation works, test passes on the first run.
# You learn nothing — the test never proved it could fail.
```

## Rules

- **One failing test at a time.** Never two reds simultaneously.
- **See the red.** A test that has never been red is not a test — it's a wish.
- **Green commits only.** If you have to interrupt mid-red, stash; don't commit.
- **Refactor on green, never on red.** Mixing the two means you can't tell whether the refactor or the new behavior broke things.
- The test goes at the [lowest layer of the pyramid](test-pyramid.md) that can express the behavior. Reach for higher layers only when the lower ones can't.

## Hooks

This project ships an `enforce-tdd` hook that warns (or blocks, when `TDD_HOOK_STRICT=1`) on production-code edits without a recently modified test file. The hook is a backstop, not a substitute for the discipline.

## Related

- [Test pyramid](test-pyramid.md)
- [Given / When / Then](given-when-then.md)
- [Object mothers](object-mothers.md)
