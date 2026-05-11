# CQRS: read/write separation

## The rule

Commands and queries take different paths.

- **Commands** (writes) go through use cases, the domain, and aggregate save operations. They protect invariants.
- **Queries** (reads) bypass the domain. They project from the database (or a read model) directly into DTOs and return them. No aggregate construction.

## Why

- Building an aggregate to render a list is expensive and pointless.
- Read shapes diverge from write shapes (lists, joins, search filters). Forcing them through the domain twists the model.
- Independent scaling: reads can hit replicas or projections; writes hit the primary.

## Examples

### Good (Python)

```python
# Write side — domain + use case
class CreateInvoiceUseCase:
    def execute(self, command: CreateInvoiceCommand) -> None:
        invoice = Invoice.create(...)   # invariants enforced in the aggregate
        self.locator.find(InvoiceRepository).save(invoice)

# Read side — direct projection to a DTO
class ListInvoicesQuery:
    def execute(self, params: ListInvoicesParams) -> list[InvoiceListItem]:
        rows = self.locator.find(InvoiceReader).list(params)
        return [InvoiceListItem(**row) for row in rows]
```

### Bad

```python
# Loading aggregates only to flatten them into a list response.
def list_invoices() -> list[InvoiceListItem]:
    invoices = repo.find_all()                          # builds N full aggregates
    return [InvoiceListItem.from_aggregate(i) for i in invoices]
```

## Rules

- Read models have their own port (`InvoiceReader`) and adapter.
- Read DTOs live next to the query, not in the domain.
- Reads never mutate. If a "read" needs to write (cache warming, last-seen), it's a command.

## Related

- [Hexagonal (ports & adapters)](hexagonal-ports-adapters.md)
- [Use case interface](use-case-interface.md)
