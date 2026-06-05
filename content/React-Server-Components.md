---
title: React Server Components
description: Mental model for RSC — what runs where, streaming, and when to reach for client components.
tags: [react, frontend]
maturity: budding
created: 2026-05-12
modified: 2026-06-06
confidence: 3
publish: true
---
# React Server Components

> **Maturity:** 🌿 budding — structure is forming, still pruning.
>
> **Confidence:** 3/5 — I'm comfortable shipping with this mental model in code review; less so when explaining it to a designer.

## What runs where

Server Components run **only on the server**. They can hit the database, read files, and import secrets — none of which the client ever sees. Their output is a serialized payload (not HTML, not JSON — a Flight stream) that React reconstructs on the client.

Client Components are the React you already know: hooks, state, effects, event handlers. They run on both the server (during prerender) and the client (during hydration).

The boundary is set by **`"use client";`** at the top of a file. Everything imported transitively by a client component becomes part of the client bundle.

## Streaming

RSC pairs with `<Suspense>` to stream payloads progressively. The server doesn't wait for slow data — it sends the shell, then streams resolved Suspense boundaries as they finish. The browser shows the page in pieces instead of holding a blank screen.

## When to reach for client components

- Anything stateful (`useState`, `useReducer`).
- Anything event-driven (`onClick`, `onChange`).
- Anything touching browser-only APIs (`window`, `IntersectionObserver`).

Default to server; opt into client at the leaves of the tree.

## Open questions
- How does React 19's `use()` hook change the cost/benefit of pure server rendering vs. streaming Promises into client components?
- What's the right abstraction for shared error UI across server and client boundaries?
