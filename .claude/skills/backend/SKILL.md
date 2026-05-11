---
name: backend
description: Python conventions for this project — toolchain (3.13+, uv, ruff, mypy --strict, pytest), required type hints, frozen+slotted dataclasses for commands and value objects, Protocol for ports, no logic in __init__, named domain exceptions, structured logging, and naming that matches the ubiquitous language. Use this skill before writing or editing any Python file (.py). Skip for non-Python work.
---

# Backend (Python)

Use this skill whenever you create or modify a `.py` file. Architecture and testing rules are owned by their own skills — don't duplicate them; cross-link.

## Doc

- [Python conventions](../../../docs/backend/python-conventions.md) — toolchain, type hints, data shapes, construction, errors, imports, async/sync, logging, naming.

## Quick rules (without reading anything else)

- Type hints are required on every parameter, return, and public attribute. `Any` is a bug.
- Commands, queries, and value objects are `@dataclass(frozen=True, slots=True)`.
- Ports are `Protocol`. Adapters conform structurally — no inheritance required.
- No business logic in `__init__`. Use a `classmethod` like `Invoice.create(...)` for domain construction.
- Named domain exceptions (`InvoiceAlreadyPaid`), never bare `except:` or `ValueError` for business rules.
- Keep `__init__.py` empty. Absolute imports only.
- Never log secrets, tokens, or PII.

## Related skills

- [architecture](../architecture/SKILL.md) — for structural decisions (ports, use cases, layers).
- [testing](../testing/SKILL.md) — TDD-strict; the failing test comes first.
