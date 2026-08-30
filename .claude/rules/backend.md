---
description: Hanami 2 API conventions for Fawlty
globs: backend/**/*.rb
---

# Backend rules — Hanami 2 + ROM

## Layering

`routes.rb` → action → repo → relation. An action that reaches past its repo
into a relation is a bug, even when it works.

Actions get dependencies by injection, never by constant lookup:

```ruby
include Deps["repos.room_repo"]
```

## Actions

One class per endpoint, at `app/actions/<resource>/<verb>.rb`, matching the
`to:` string in `routes.rb`. The whole body is `handle(request, response)`.

Every action:

- starts with `# frozen_string_literal: true`
- `slice`s the permitted attributes off `parsed_body(request)` — never passes
  the raw body to a repo
- returns JSON through the `json(response, ...)` helper in `app/action.rb`
- returns `201` on create, `204` on destroy, `422` on a rejected write, `404`
  when the record is missing

Rescue narrowly. `rescue => e` returning the raw `e.message` is the existing
pattern for writes; do not widen it further, and do not add it to reads.

## Repos

All query and write logic lives here. A repo method returns structs or hashes —
not relations, not ROM changesets. If two actions need the same query, it
belongs in the repo once, not copy-pasted.

## Routes

Add the route in the right resource block in `backend/config/routes.rb` and
keep the existing column alignment. Nested actions (`check_in`, `check_out`)
are `POST /<resource>/:id/<verb>`.

## Migrations

Under `backend/config/db/migrate/`. Never edit a migration that has run — add a
new one. Apply with `make db-migrate`.

## Secrets

`ENV.fetch("KEY")` — the fetch form, so a missing key fails at boot rather than
silently becoming `nil`. Declare it in `backend/.env`. A quoted literal secret
is blocked by the commit gate.

## Tests

RSpec via `make backend-test`, which runs against `fawlty_test` — never the
development database. Specs live in `backend/spec/` mirroring `app/`; request
specs go in `backend/spec/requests/<resource>_spec.rb`.

`spec_helper.rb` gives request specs `get` / `post_json(path, hash)` /
`last_response` / `json_body`. Follow `spec/requests/rooms_spec.rb`.

**Every new endpoint gets a spec.** At minimum: the success path and the
failure the action explicitly handles (the 404, or the 422). An endpoint
without a spec is not finished.

## Lint

`make lint-backend` runs rubocop. The config in `backend/.rubocop.yml` is
`DisabledByDefault`, so every enabled cop is one someone chose — a finding is
real, not style noise.

Fix the offense. Do not add an inline `rubocop:disable`, and do not turn a cop
off in `.rubocop.yml`, unless the user asked for it.
