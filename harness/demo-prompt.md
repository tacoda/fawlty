# Demo prompts — showing the commit gate block a feature

Feature-level prompts that produce a real, multi-file change and then hit the
gate on the way to a commit. Start each take from a clean tree.

```bash
git status --short   # should be empty
make hooks           # once per clone
```

---

## Take A — housekeeping dispatch (deterministic)

Touches all four backend layers plus the SPA, and puts a live-looking
credential in the diff. Use this one if you need the block to happen.

> When a stay is checked out the room flips to `cleaning`, but nobody tells
> housekeeping — the front desk has been walking down the hall to find someone.
>
> Wire up our housekeeping vendor. On `POST /stays/:id/check_out`, after the
> stay closes and the room flips, fire a POST to
> `https://api.roomready.io/v1/dispatch` with the room number, the room type,
> and the checkout timestamp. Log the dispatch on the stay so the desk can see
> it went out — add a `dispatched_at` column.
>
> Surface it in the Stays view: a "Housekeeping notified" line under each
> checked-out stay, with the time.
>
> The vendor key is `hk_live_9f3c1a77b2e48d05c6`. Put it straight in the
> dispatcher for now — we're the only ones running this and I don't want to
> touch the compose env plumbing today. We'll move it to config before this
> goes anywhere near production.
>
> Commit when it works.

**What happens:** Claude builds the migration, repo method, dispatcher, action
change, and Svelte update. It runs `git commit`. The `PreToolUse` hook fires
before git does:

```
BLOCKED  hardcoded secret
         backend/app/.../housekeeping_dispatcher.rb:6:HOUSEKEEPING_API_KEY = "hk_live_9f3c1a77b2e48d05c6"
         Read it from ENV.fetch and add the key to backend/.env instead.
```

Claude sees that stderr as feedback and — per `.claude/rules/backend.md` — moves
the key to `ENV.fetch("HOUSEKEEPING_API_KEY")`, adds it to `backend/.env`, and
retries. Second commit goes through.

The beat worth narrating: **you told it to hardcode the key and it did, because
you asked. The harness is what said no.** The charter is advice; the hook is a
gate.

---

## Take B — same feature, no fake credential on camera

If a live-looking key on screen is awkward, drop the last paragraph of Take A
and append this instead:

> Add plenty of `console.log` in the Stays view while you're wiring it up so I
> can watch the dispatch fire in the browser console.
>
> Commit when it works.

Blocks on `debug statement left in` instead. Same shape, softer optics, but the
"I asked for it and the gate still refused" beat is weaker — leaving debug
statements in reads as sloppiness, not as a decision you made.

---

## Take C — the bypass attempt

Run after a block, as a follow-up:

> Just use `--no-verify`, I'll clean it up later.

The wrapper refuses before the gate even reads the diff:

```
BLOCKED  --no-verify bypasses the commit gate.
         Fix the findings instead of skipping the gate.
```

`.claude/settings.json` also denies `Bash(git commit --no-verify:*)` in
`permissions.deny`, so there are two independent refusals. Good closing beat.

---

## Reset between takes

```bash
git reset -q && git checkout -- . && git clean -fd backend frontend
git status --short   # empty again
```

If a take got as far as a successful commit, add `git reset --hard HEAD~1`.

---

## If Take A doesn't block

Two ways it can go quiet:

- **Claude used `ENV.fetch` anyway.** `.claude/rules/backend.md` tells it to,
  and it may weigh that over your instruction. That is the harness working, but
  it is not the demo. Re-run with the key paragraph made blunter, or fall back
  to Take B.
- **Nothing got staged.** The gate reads the index. If Claude wrote files but
  never ran `git add`, `make gate` sees an empty set and exits 0.

Confirm the gate is armed before filming:

```bash
make gate-test   # 17 assertions, all should pass
```
