# Hexagonal (ports & adapters)

## The rule

The application talks to the outside world only through **ports** (interfaces it owns). Concrete code that speaks to a database, HTTP API, queue, or clock is an **adapter** that implements a port. The application layer never imports an adapter — it depends on the port.

Two flavors:

- **Inbound (driving) ports** — how the outside world drives the application. In this project, these are the [use case interfaces](use-case-interface.md). HTTP routes, CLI commands, and workers are inbound adapters that translate transport into use case calls (always via the [executor](use-case-executor.md)).
- **Outbound (driven) ports** — what the application needs from the outside (repositories, clocks, mailers, payment gateways). The application defines the interface; infrastructure provides the implementation.

## Why

- Swap Postgres for SQLite in tests, or Stripe for a fake gateway, with zero changes to use cases.
- The domain and use cases stay framework-free: no SQLAlchemy, no Flask, no `requests` imports leak inward.
- Adapters are the only place where the project depends on a vendor SDK. Replacing the vendor is a localized change.

## Folder layout

```
src/<bounded-context>/
├── domain/                      ← entities, value objects, aggregates, domain events
├── application/
│   ├── use_cases/               ← inbound ports (interfaces) + implementations
│   └── ports/                   ← outbound ports (e.g. InvoiceRepository, Clock, Mailer)
├── infrastructure/
│   ├── persistence/             ← outbound adapters (e.g. PostgresInvoiceRepository)
│   ├── http_clients/            ← outbound adapters (e.g. StripePaymentGateway)
│   └── system/                  ← outbound adapters (e.g. SystemClock)
└── interfaces/
    ├── http/                    ← inbound adapters (routes, controllers)
    ├── cli/                     ← inbound adapters (commands)
    └── workers/                 ← inbound adapters (queue consumers, schedulers)
```

Dependencies point inward: `interfaces → application → domain`, and `infrastructure → application` (to implement its ports). Domain depends on nothing.

## Examples

### Good (Python)

```python
# application/ports/invoice_repository.py
from typing import Protocol
from domain.invoice import Invoice

class InvoiceRepository(Protocol):
    def get(self, invoice_id: str) -> Invoice: ...
    def save(self, invoice: Invoice) -> None: ...
```

```python
# infrastructure/persistence/postgres_invoice_repository.py
from application.ports.invoice_repository import InvoiceRepository
from domain.invoice import Invoice

class PostgresInvoiceRepository(InvoiceRepository):
    def __init__(self, session) -> None:
        self.session = session

    def get(self, invoice_id: str) -> Invoice: ...
    def save(self, invoice: Invoice) -> None: ...
```

```python
# interfaces/http/invoice_routes.py — inbound adapter
@router.post("/invoices/{id}/pay")
def pay_invoice(id: str, body: PayBody, executor: UseCaseExecutor):
    executor.execute(PayInvoice, PayInvoiceCommand(id, body.amount_cents))
```

### Bad

```python
# application/use_cases/pay_invoice.py
import psycopg2  # ← infrastructure leaking into application
from stripe import Charge  # ← vendor SDK in the application layer
```

```python
# domain/invoice.py
from sqlalchemy.orm import declarative_base  # ← framework leaking into domain
```

## Rules

- Ports are interfaces, not classes with behavior. Outbound ports live in `application/ports/`; inbound ports are the use case interfaces.
- Adapters live in `infrastructure/` (outbound) or `interfaces/` (inbound). Never in `application/` or `domain/`.
- The application layer imports only `domain` and its own ports. The domain imports nothing outside `domain`.
- One adapter implements one port. Don't combine an HTTP client and a repository in the same class.
- Tests for use cases use fake adapters (in-memory implementations of the port). No mocking libraries needed.

## Related

- [DDD overview](ddd-overview.md)
- [Use case interface](use-case-interface.md)
- [ServiceLocator-style injection](service-locator-injection.md)
