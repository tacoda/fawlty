# Fawlty — project charter

Hotel-staff web app: **rooms**, **guests**, **reservations**, **stays**, with
check-in and check-out flows.

- `backend/` — Hanami 2.3 JSON API (Ruby, ROM via `hanami-db`, PostgreSQL 16, Puma)
- `frontend/` — Svelte 4 + Vite 5 SPA
- Orchestration: Docker Compose. Task runner: GNU Make.

Everything runs in containers. Prefer `make` targets over raw `docker compose`
or bare `bundle`/`npm` — the targets already wrap `compose exec`.

## Commands

| Task | Command |
| --- | --- |
| Boot the stack | `make up` |
| Stop | `make down` |
| **Everything (lint + tests + gate)** | `make check` |
| Lint (rubocop + eslint) | `make lint` · autofix: `make lint-fix` |
| Backend tests | `make backend-test` |
| Backend console | `make backend-console` |
| Migrate / seed | `make db-migrate` / `make db-seed` |
| Test database | `make db-test-prepare` |
| Frontend build | `make frontend-build` |
| **Commit gate** | `make gate` |
| Install git hook | `make hooks` |

**Work is not done until `make check` passes.** Do not report a change as
complete on the strength of having written it.

Frontend: <http://localhost:5173> · API: <http://localhost:2300/api/rooms>

Ports come from the root `.env` (`DB_PORT`, `API_PORT`, `WEB_PORT`), defaulting
to 5432 / 2300 / 5173. Copy `.env.example` to `.env` and change the numbers to
run a second checkout alongside this one.

## Architecture

Requests flow **route → action → repo → relation**. Nothing skips a layer.

- `backend/config/routes.rb` — every endpoint under the `api` scope.
- `backend/app/actions/<resource>/<verb>.rb` — one class per endpoint. Gets its
  repo through `include Deps["repos.<name>_repo"]`. Talks JSON only.
- `backend/app/repos/` — all query and write logic. Actions never touch a
  relation directly.
- `backend/app/relations/` — ROM table definitions.
- `frontend/src/api.js` — the *only* place `fetch` is called. Views import the
  named resource objects (`rooms`, `guests`, `reservations`, `stays`).
- `frontend/src/views/*.svelte` — one view per resource.

Adding an endpoint means touching all four backend layers plus `api.js`. If a
change only touches one, question whether it belongs there.

## Rules

Load the rule file that matches what you are touching:

- [`.claude/rules/backend.md`](.claude/rules/backend.md) — `backend/**/*.rb`
- [`.claude/rules/frontend.md`](.claude/rules/frontend.md) — `frontend/src/**`
- [`.claude/rules/commits.md`](.claude/rules/commits.md) — any commit or PR

## The layer check

Every `Write` and `Edit` runs `.claude/hooks/layer-check.sh` as a `PostToolUse`
hook. The file is already on disk by then, so the hook does not prevent the
write — it hands the finding straight back and expects the fix before the next
file. It blocks on three things:

- an action under `backend/app/actions/` containing query logic (`Sequel.`,
  `.by_pk(`, `.where(`, `.order(`, `.join(`, a `Backend::Relations` reference)
- `fetch(` anywhere under `frontend/src/` other than `api.js`
- a `backend/**/*.rb` file missing `# frozen_string_literal: true`

Scan the whole tree with `make layer-check`. The rules in `.claude/rules/`
already said all three; the hook is what makes them binding.

## The commit gate

`git commit` is gated. `.claude/hooks/commit-gate.sh` scans staged content and
**blocks** on: hardcoded secrets, leftover debug statements, focused tests,
staged `.env` files, and Ruby syntax errors.

It runs in two places — as a Claude Code `PreToolUse` hook (blocks the agent's
`git commit`) and, after `make hooks`, as `.git/hooks/pre-commit` (blocks a
human's). `--no-verify` is refused, not honored.

When the gate blocks you: **fix the finding.** Do not weaken the gate, do not
add a `gate:allow` marker to get past it, and do not reach for `--no-verify`.
`gate:allow` is for deliberate, reviewed exceptions the user has asked for.

Run it yourself any time with `make gate`, and self-check its rules with `make
gate-test`. Rules table and demo walkthrough:
[`.claude/hooks/README.md`](.claude/hooks/README.md) and
[`.claude/demo-prompt.md`](.claude/demo-prompt.md).

## Conventions

- Ruby files start with `# frozen_string_literal: true`.
- Two-space indent in Ruby, two-space in Svelte/JS. No semicolon crusade —
  match the file you are in.
- No new dependencies without asking. The Gemfile and `package.json` are short
  on purpose.
- Secrets come from `ENV`, declared in `backend/.env`. Never a literal.
- No AI attribution anywhere: no `Co-Authored-By`, no "generated with" footer,
  in commits, PRs, or issues.
