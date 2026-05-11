# Use case executor

## The rule

Use cases are never called directly. Callers invoke them through the executor:

```python
result = executor.execute(PayInvoice, command)
```

The executor:

1. Resolves the use case implementation from the locator.
2. Wraps the call with cross-cutting concerns (telemetry, transactions, retries — added over time).
3. Returns the result.

## Why

- Adding OpenTelemetry spans, transaction boundaries, or retry policies later means changing **one file**, not every use case.
- Tests can wrap the executor with assertions ("each use case ran inside a transaction") without touching use case code.
- The composition root has one place to wire the locator.

## Minimal shape

```python
# application/executor.py
from typing import Type, TypeVar

UC = TypeVar("UC")

class UseCaseExecutor:
    def __init__(self, locator: ServiceLocator) -> None:
        self.locator = locator

    def execute(self, use_case: Type[UC], command):
        instance = self.locator.find(use_case)
        # later: open span, begin transaction, etc.
        return instance.execute(command)
```

## Rules

- HTTP routes, CLI commands, and workers all go through the executor.
- The executor is the only thing that resolves use cases from the locator. Other code resolves ports, not use cases.
- Do not put domain logic in the executor. It is a runtime boundary, not a layer.

## Related

- [Use case interface](use-case-interface.md)
- [ServiceLocator-style injection](service-locator-injection.md)
