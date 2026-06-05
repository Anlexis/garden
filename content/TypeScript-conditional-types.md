---
title: TypeScript conditional types
description: "When the type system needs to branch — `T extends U ? A : B`, distributivity gotchas, and where `infer` earns its keep."
tags: [typescript, types]
maturity: seedling
created: 2026-06-02
modified: 2026-06-06
confidence: 2
publish: true
---
# TypeScript conditional types

> **Maturity:** 🌱 seedling — I keep reaching for these and getting bitten by distributivity.
>
> **Confidence:** 2/5 — I trust the pattern; I don't yet trust myself to predict the output without writing a test.

## The shape

```ts
type IfString<T> = T extends string ? "yes" : "no";
type A = IfString<"hello">;  // "yes"
type B = IfString<42>;       // "no"
```

Reads exactly like an `if`. The interesting part is what the type system does when `T` is a union.

## Distributivity — the foot-gun

When the *checked* type is a "naked" generic, conditional types **distribute over unions**:

```ts
type IfString<T> = T extends string ? "yes" : "no";
type C = IfString<"hello" | 42>;
// → ("hello" extends string ? "yes" : "no") | (42 extends string ? "yes" : "no")
// → "yes" | "no"
```

That's usually what you want. When it isn't, **wrap the type parameter in a tuple** to suppress distribution:

```ts
type IfStringNonDist<T> = [T] extends [string] ? "yes" : "no";
type D = IfStringNonDist<"hello" | 42>;  // "no"
```

This bites you mostly when you're trying to write "is this type assignable to X *as a whole*."

## `infer` — pattern-matching inside the condition

```ts
type ReturnTypeOf<F> = F extends (...args: any[]) => infer R ? R : never;
type E = ReturnTypeOf<() => number>;  // number
```

`infer R` says "name whatever sits in this slot R, then I can use it on the right side." I reach for it most often to pull a generic out of a wrapping type (`Promise<X>`, `Array<X>`, `Result<X, E>`).

## Where this earns the complexity

- Library-level type ergonomics — the kind of thing inside `@tanstack/react-query` or `zod`.
- "Smart" prop typing where one prop's value determines another's allowed type (discriminated-union refinements).

In app code, I default to the simpler `T extends U` direct check and only reach for `infer` when there's a concrete payoff. Otherwise the read-cost outweighs the type-precision benefit.

## Open
- I should write a test harness that uses `Equals<A, B>` to assert exact type equality, so I can catch distributivity regressions when I refactor.
