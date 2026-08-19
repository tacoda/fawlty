---
description: Add a new API endpoint across all four layers
argument-hint: <resource> <verb> [e.g. reservations cancel]
---

Add the endpoint `$ARGUMENTS` to the Fawlty API.

Read `.claude/rules/backend.md` and `.claude/rules/frontend.md` first.

Touch all four corners, in this order:

1. `backend/app/relations/` — only if a new column or table is needed (and then
   a migration under `backend/config/db/migrate/`, never an edit to an existing
   one).
2. `backend/app/repos/<resource>_repo.rb` — the query or write method.
3. `backend/app/actions/<resource>/<verb>.rb` — the action, injecting the repo
   via `Deps`, slicing permitted attributes, returning the right status code.
4. `backend/config/routes.rb` — the route, in the matching resource block, with
   the existing column alignment preserved.
5. `frontend/src/api.js` — the client function on the resource object, only if
   the SPA will call it.

Then run `make gate` and report the result. Do not commit unless asked.
