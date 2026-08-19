---
description: Commit, branch, and PR conventions for Fawlty
globs:
---

# Commits and PRs

## Before committing

Run `make gate`. It is the same check the hook runs, so a clean `make gate`
means the commit will go through.

Commit only what the task asked for. If you noticed unrelated dead code, say so
in your reply — do not sweep it into the diff.

## Message format

Conventional Commits. Subject in the imperative, ≤50 characters, no trailing
period.

```
feat(reservations): add cancel endpoint

Guests cancel from the front desk more often than they no-show, and
the only way to undo a booking was deleting the row.
```

Scopes: `rooms`, `guests`, `reservations`, `stays`, `db`, `frontend`,
`backend`, `harness`, `deps`.

Body only when the *why* is not obvious from the subject. Skip it for typos and
mechanical renames.

## Never

- `--no-verify`. The gate is refused, not bypassed. Fix the finding.
- AI attribution: no `Co-Authored-By: Claude`, no "generated with" footer, no
  mention of an agent or tool in commit messages, PR titles, PR bodies, issues,
  or changelogs.
- Committing on `main` when the change is more than a one-line fix — branch
  first.
- Staging `backend/.env` or any `*.env.local`.

## PRs

Title uses the same Conventional Commit format as the subject line. Body says
what changed and how it was verified. If the verification was "I ran `make
gate` and it passed", say exactly that — do not imply a test suite ran.
