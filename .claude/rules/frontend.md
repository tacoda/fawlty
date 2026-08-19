---
description: Svelte 4 + Vite conventions for the Fawlty SPA
globs: frontend/src/**
---

# Frontend rules — Svelte 4 + Vite

## The API boundary

`frontend/src/api.js` is the only file that calls `fetch`. A component that
calls `fetch` directly is wrong even if it works — add the call to the resource
object in `api.js` and import it.

Resource objects follow one shape:

```js
export const rooms = {
  list:   ()        => api.get("/rooms"),
  create: (data)    => api.post("/rooms", data),
  update: (id, d)   => api.patch(`/rooms/${id}`, d),
  remove: (id)      => api.del(`/rooms/${id}`)
};
```

Keep the column alignment. Nested verbs get a camelCase name mapping to the
snake_case route (`checkIn` → `/reservations/:id/check_in`).

`request()` already throws on a non-2xx and unwraps `{error}`. Do not
re-implement error parsing in a view.

## Views

One view per resource at `frontend/src/views/<Resource>.svelte`, registered in
`App.svelte`. Svelte 4 — `export let` props and stores, **not** runes.

Every async call gets a visible loading state and a visible error state. A
silent `catch {}` is worse than an unhandled rejection.

## Style

Global styles in `app.css`; anything component-specific goes in that
component's `<style>` block, which Svelte already scopes.

No new dependencies. Svelte and Vite cover it.

## Debugging

`console.log` is fine while you work and is blocked at commit time. Strip it
before staging.
