# Python conventions

Conventions specific to Python. Architecture rules ([hexagonal](../architecture/hexagonal-ports-adapters.md), [use cases](../architecture/use-case-interface.md)) and [testing rules](../testing/test-pyramid.md) apply equally and are not repeated here.

## Toolchain

- **Python 3.13+.** Use modern syntax (`X | None` over `Optional[X]`, `list[X]` over `List[X]`).
- **uv** for dependency and environment management (`uv add`, `uv run`, `uv sync`). No `pip install` directly into a venv; lockfiles are committed.
- **ruff** for both formatting and linting. The pre-edit/post-edit hook runs it; if it complains, fix the underlying issue rather than suppressing.
- **mypy --strict** as the type-check baseline. New code passes strict; legacy holes are tracked, not normalized.
- **pytest** for tests. No `unittest.TestCase` subclasses.

## Type hints

Required everywhere — every function parameter, every return, every public attribute.

```python
def pay_invoice(invoice: Invoice, amount_cents: int, at: datetime) -> None: ...
```

- Use `Protocol` for ports. Structural typing matches the [hexagonal](../architecture/hexagonal-ports-adapters.md) approach: adapters don't have to inherit, only conform.
- Prefer concrete types (`list[Invoice]`) over `Iterable[Invoice]` in domain APIs unless the function genuinely streams.
- `Any` is a bug. If you need it, write `# type: ignore[explanation]` with the reason.

## Data shapes

- **Commands and queries**: `@dataclass(frozen=True, slots=True)`. Frozen catches accidental mutation; slots keep them cheap.
- **Value objects**: same — frozen, slotted, value-equal by default.
- **Entities**: mutable, but mutate through methods (`invoice.pay(...)`), never by assignment from outside (`invoice.status = "paid"`). Make internal fields private with a leading underscore when the API is method-only.

```python
@dataclass(frozen=True, slots=True)
class PayInvoiceCommand:
    invoice_id: str
    amount_cents: int
```

## Construction

- No business logic in `__init__`. The constructor stores fields and validates the *shape* of inputs (type, range). Domain operations that produce an entity live in classmethods: `Invoice.create(...)`.
- No mutable default arguments. Ever.

```python
# Good
class Invoice:
    @classmethod
    def create(cls, customer_id: str, amount_cents: int, clock: Clock) -> "Invoice":
        if amount_cents <= 0:
            raise InvalidInvoiceAmount(amount_cents)
        return cls(id=new_id(), customer_id=customer_id, amount_cents=amount_cents,
                   created_at=clock.now(), status=InvoiceStatus.UNPAID, paid_at=None)
```

## Errors

- Use named domain exceptions (`InvalidInvoiceAmount`, `InvoiceAlreadyPaid`), not bare `ValueError`. Define them next to the aggregate they belong to.
- Never bare `except:`. Catch the narrowest type that makes sense.
- Don't swallow exceptions to keep a flow alive. If recovery is real, name it (`except StripeRateLimited: backoff_and_retry()`); otherwise let it propagate.
- Validation at the system boundary (HTTP body, CLI args). Internal code trusts its inputs.

## Imports

- Absolute imports only. ruff (isort) sorts them — don't fight it.
- Keep `__init__.py` empty. Re-exports hide the real source of an identifier and break grep.

## Async vs sync

Pick one per bounded context and keep it consistent. Mixing means every adapter has two implementations and every test has two harnesses. Default for HTTP-shaped services: async (FastAPI, asyncpg). Default for batch / CLI: sync. Document the choice in the bounded context's README if it differs from the project default.

## Logging

- Structured logs (key/value pairs), not f-strings into a message. Use `structlog` or stdlib with `extra=`.
- One log line per meaningful event, not one per line of code.
- Never log secrets, tokens, full request bodies, or PII. The pre-commit hook scans for the obvious offenders; don't rely on it.

## Naming

- `snake_case` for variables, functions, modules. `PascalCase` for classes. `UPPER_SNAKE` for module-level constants.
- Match the [ubiquitous language](../architecture/ddd-overview.md). If product says "invoice", code says `Invoice`, not `Bill`.
- Booleans read as predicates: `is_paid`, `has_overdue_charges`. Not `paid_status`.

## Related

- [Hexagonal (ports & adapters)](../architecture/hexagonal-ports-adapters.md)
- [Use case interface](../architecture/use-case-interface.md)
- [Test pyramid](../testing/test-pyramid.md)
