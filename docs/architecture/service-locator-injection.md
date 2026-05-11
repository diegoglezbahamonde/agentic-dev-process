# ServiceLocator-style injection (hybrid)

## The rule

Use cases use a **hybrid pattern**: every port (and the executor) is an *optional* constructor argument. If the caller passes it, that wins. If not, the constructor falls back to `ServiceLocator.find(<Port>.__name__)`.

```python
class PayInvoiceUseCase(UseCase[PayInvoiceCommand, None]):
    def __init__(
        self,
        invoices: InvoiceRepository | None = None,
        clock: Clock | None = None,
        executor: UseCaseExecutor | None = None,
    ):
        if invoices is None:
            invoices = ServiceLocator.find(InvoiceRepository.__name__)
        if clock is None:
            clock = ServiceLocator.find(Clock.__name__)
        if executor is None:
            executor = ServiceLocator.find(UseCaseExecutor.__name__)
        self.invoices = invoices
        self.clock = clock
        self.executor = executor
```

Production calls `PayInvoiceUseCase()` — every dep resolves from the locator. Tests call `PayInvoiceUseCase(invoices=fake_repo, clock=FixedClock(AT))` — explicit, isolated, no locator setup needed.

## Why hybrid (and not pure constructor injection or pure locator)

- **Pure constructor injection** (deps as required args) means every callsite that constructs a use case needs the full dep list. Adding a new dep ripples through every test fixture and every composition-root entry. We had this; it was painful.
- **Pure ServiceLocator** (only the locator in the constructor; every dep resolved at point-of-use inside `execute`) hides the dep list entirely. Constructor-as-documentation disappears, and tests have to set up the locator even for the simplest unit test.
- **Hybrid** keeps the dep list visible in the signature (constructor-as-documentation), keeps tests easy (pass the deps you want, omit the rest), and keeps adding-a-dep cheap (only the use case constructor changes; the locator picks it up at runtime without rippling to call sites).

## ServiceLocator interface

`ServiceLocator` is a process-wide registry, populated at the composition root.

```python
# infrastructure/service_locator.py
class ServiceLocator:
    _registry: dict[str, object] = {}

    @classmethod
    def register(cls, name: str, instance: object) -> None:
        cls._registry[name] = instance

    @classmethod
    def find(cls, name: str) -> object:
        if name not in cls._registry:
            raise KeyError(f"No registration for {name}")
        return cls._registry[name]

    @classmethod
    def reset(cls) -> None:
        cls._registry.clear()
```

The lookup key is the type name (`InvoiceRepository.__name__`). One registered adapter per port at any given time.

### Composition root

```python
# infrastructure/composition.py
def compose() -> None:
    session = make_db_session()
    ServiceLocator.register(InvoiceRepository.__name__, PostgresInvoiceRepository(session))
    ServiceLocator.register(InvoiceReader.__name__, PostgresInvoiceReader(session))
    ServiceLocator.register(Clock.__name__, SystemClock())
    ServiceLocator.register(UseCaseExecutor.__name__, UseCaseExecutor())
```

Run `compose()` once at process start.

## Tests

```python
def test_paying_an_invoice_in_full_marks_it_paid():
    # Given
    repo = InMemoryInvoiceRepository(seed=[InvoiceMother.unpaid(amount_cents=10_000)])
    clock = FixedClock(AT)
    use_case = PayInvoiceUseCase(invoices=repo, clock=clock)

    # When
    use_case.execute(PayInvoiceCommand(invoice_id="inv-1", amount_cents=10_000))

    # Then
    assert repo.get("inv-1") == InvoiceMother.paid(amount_cents=10_000, paid_at=AT)
```

`executor=` is omitted because this use case doesn't chain into others. If it did, the test would pass an executor (a real one with a test ServiceLocator, or a fake).

Don't call `ServiceLocator.register(...)` from unit tests — direct constructor injection is cleaner. The locator is for production composition.

## Bad

```python
# All-required constructor injection — adding a Clock dep means changing every
# call site and every test fixture.
class PayInvoiceUseCase(UseCase[PayInvoiceCommand, None]):
    def __init__(self, invoices: InvoiceRepository, clock: Clock) -> None:
        ...

# Pure locator — dep list is invisible from the signature; resolution scattered
# inside execute; tests must populate the locator for every use case.
class PayInvoiceUseCase(UseCase[PayInvoiceCommand, None]):
    def __init__(self, locator: ServiceLocator) -> None:
        self.locator = locator

    def execute(self, command):
        invoices = self.locator.find(InvoiceRepository.__name__)  # discoverable only by reading execute
        clock = self.locator.find(Clock.__name__)
        ...
```

## Rules

- **Every port the use case uses is an optional constructor arg** with `None` default + `ServiceLocator.find(<Port>.__name__)` fallback. No `ServiceLocator.find(...)` calls inside `execute`.
- **The executor is one of those args** so the use case can chain into other use cases via `self.executor.execute(OtherUseCase, input)`.
- **Lookup key is the type name string** (`InvoiceRepository.__name__`), not the class object. Keep it consistent across registrations and lookups.
- **Tests construct directly with fakes**, omitting `executor=` unless the use case chains. Don't go through the locator in unit tests.
- **The composition root is the only place that calls `ServiceLocator.register`.** Inbound adapters (HTTP routes, CLI, workers) call `executor.execute(UseCaseClass, input)` and never touch the locator directly.

## Related

- [Use case interface](use-case-interface.md)
- [Use case executor](use-case-executor.md)
- [CQRS: read/write separation](cqrs-read-write-separation.md)
