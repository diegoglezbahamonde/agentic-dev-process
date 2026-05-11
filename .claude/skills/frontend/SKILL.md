---
name: frontend
description: TypeScript conventions for this project — toolchain (TS 5.x ESM, Node 22+, pnpm, biome, vitest), strict tsconfig with noUncheckedIndexedAccess and exactOptionalPropertyTypes, no `any` (use `unknown` and narrow), discriminated unions for variants, named exports only, readonly value objects, named error classes, and React function-component rules. Use this skill before writing or editing any TypeScript file (.ts / .tsx). Skip for non-TypeScript work.
---

# Frontend (TypeScript)

Use this skill whenever you create or modify a `.ts` or `.tsx` file. Architecture and testing rules are owned by their own skills — don't duplicate them; cross-link.

## Doc

- [TypeScript conventions](../../../docs/frontend/typescript-conventions.md) — toolchain, tsconfig, types, modules, async, errors, naming, React.

## Quick rules (without reading anything else)

- `tsconfig` has `strict`, `noUncheckedIndexedAccess`, `exactOptionalPropertyTypes`, `verbatimModuleSyntax`. Don't loosen them.
- `any` is a bug. Use `unknown` at boundaries and narrow.
- Discriminated unions for variants — never stringly-typed status with optional siblings.
- Named exports only. No `export default`.
- `import type` for type-only imports; `.js` extensions in import specifiers.
- All async work returns `Promise<T>`. Always `await`; never ignore a Promise.
- Throw named error classes. `catch (e: unknown)` then narrow.
- React: function components only, one per file, don't fetch in components.

## Related skills

- [architecture](../architecture/SKILL.md) — for structural decisions (ports, use cases, layers).
- [testing](../testing/SKILL.md) — TDD-strict; the failing test comes first.
