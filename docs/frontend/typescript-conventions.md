# TypeScript conventions

Conventions specific to TypeScript. Architecture rules ([hexagonal](../architecture/hexagonal-ports-adapters.md), [use cases](../architecture/use-case-interface.md)) and [testing rules](../testing/test-pyramid.md) apply equally and are not repeated here.

## Toolchain

- **TypeScript 5.x**, ESM only. No CommonJS, no `require`.
- **Node 22+ LTS** as the runtime baseline.
- **pnpm** for dependencies. Lockfile is committed.
- **biome** for both formatting and linting. Pre-edit/post-edit hooks run it; fix the issue rather than disabling the rule.
- **vitest** for tests.

## tsconfig

Non-negotiable flags:

```jsonc
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitOverride": true,
    "exactOptionalPropertyTypes": true,
    "verbatimModuleSyntax": true,
    "moduleResolution": "Bundler",
    "target": "ES2023"
  }
}
```

`strict` alone isn't enough — the extras above catch the bugs that `strict` misses (array access without bounds checks, `undefined` vs missing properties).

## Types

- **`any` is a bug.** Use `unknown` at boundaries (parsed JSON, `catch` clauses) and narrow before use.
- **`interface` for object shapes you might extend; `type` for unions, intersections, and aliases.** Don't agonize — pick by intent, not style.
- **Discriminated unions for variants.** No "stringly-typed" status fields with optional sibling properties.

```typescript
type InvoiceState =
  | { kind: "unpaid"; dueDate: Date }
  | { kind: "paid"; paidAt: Date }
  | { kind: "cancelled"; cancelledAt: Date; reason: string };
```

- **`readonly` aggressively** for value objects and command shapes. Prefer `ReadonlyArray<T>` (`readonly T[]`) on public APIs.
- **`as const`** for literal data that should narrow to its specific values.
- **Don't `as` your way out.** A cast is an admission that the type system can't prove what you know. Prefer a type guard or a parser at the boundary.

## Modules

- **Named exports only.** No `export default`. Default exports rename silently across files and break refactors.
- **`import type` for type-only imports.** Required by `verbatimModuleSyntax`.
- **`.js` extensions in import specifiers** (ESM requirement). The toolchain rewrites them; the source has them.
- **Absolute imports** via `paths` mapping (e.g. `@/domain/invoice`). No `../../../` chains.

## Commands, queries, value objects

```typescript
export type PayInvoiceCommand = Readonly<{
  invoiceId: string;
  amountCents: number;
}>;

export interface PayInvoice {
  execute(command: PayInvoiceCommand): Promise<void>;
}
```

- All async work returns `Promise<T>`. No `.then()` chains in application code — `await` everywhere.
- Never `void`-ignore a Promise. If you don't await, you've lost the error.

## Errors

- Throw named error classes (`class InvoiceAlreadyPaid extends Error`), not strings or generic `Error`.
- `catch (e: unknown)` then narrow. Never `catch (e: any)`.
- At the boundary (HTTP handler, message consumer), translate exceptions to typed responses. Inside the application, let them propagate.
- Validation at the boundary uses a parser (zod, valibot). The application trusts its inputs.

## Naming

- `camelCase` for variables and functions; `PascalCase` for types and classes; `SCREAMING_SNAKE` for module-level constants.
- File names: `kebab-case.ts` for modules; `PascalCase.tsx` only for files whose primary export is a React component.
- Match the [ubiquitous language](../architecture/ddd-overview.md). Product's "invoice" is code's `Invoice`, not `Bill`.
- Booleans read as predicates: `isPaid`, `hasOverdueCharges`. Not `paidStatus`.

## React (when applicable)

- Function components only. No `class` components.
- Server components or props-driven children for composition; avoid `useContext` for things that aren't truly global.
- One component per file. Co-locate its tests as `component.test.tsx`.
- Don't fetch data in components — call use cases (via the [executor](../architecture/use-case-executor.md)) from a query/loader and pass the result down.

## Logging

- Structured logs (object with a `msg` and fields), not interpolated strings.
- Never log secrets, tokens, full request bodies, or PII.

## Related

- [Hexagonal (ports & adapters)](../architecture/hexagonal-ports-adapters.md)
- [Use case interface](../architecture/use-case-interface.md)
- [Test pyramid](../testing/test-pyramid.md)
