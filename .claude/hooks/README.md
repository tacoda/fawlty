# Commit gate

Two scripts, one rule set.

| File | Role |
| --- | --- |
| `commit-gate.sh` | The rules. Scans staged content. Exit 2 = blocked. |
| `pre-commit-gate.sh` | `PreToolUse` adapter — reads the hook payload, delegates on `git commit`. |
| `gate-selftest.sh` | 13 assertions over both. `make gate-test`. |

## Where it runs

**Agent layer** — `.claude/settings.json` registers `pre-commit-gate.sh` as a
`PreToolUse` hook on `Bash`. The matcher only sees the tool *name*, so the
wrapper reads the payload from stdin and checks `tool_input.command` itself
(falling back to `input.command`, then to raw text if the shape changes). Exit 2
blocks the tool call and hands stderr back to the agent as feedback.

**Git layer** — `make hooks` symlinks `commit-gate.sh` to
`.git/hooks/pre-commit`, so a human typing `git commit` hits the same rules.
`.git/hooks/` is not versioned; every clone runs `make hooks` once.

`--no-verify` is refused by the wrapper rather than honored, and denied again in
`settings.json` permissions.

## Rules

| Check | Blocks on |
| --- | --- |
| Secrets | AWS keys, `sk-`/`sk-ant-` keys, `gh*_` tokens, PEM private keys, quoted literal after `password`/`secret`/`api_key`/`access_token`/`auth_token` |
| Debug leftovers | `binding.pry`, `binding.irb`, `byebug`, `debugger` in `.rb`; `console.log`, `console.debug`, `debugger` in `.js`/`.svelte` |
| Focused tests | `fdescribe`, `fit`, `fcontext`, `:focus` in `*_spec.rb` |
| Env files | any staged `.env` / `*.env.local` |
| Ruby syntax | `ruby -c` on staged `.rb`, when `ruby` is on PATH |

Files under `.claude/` are exempt from *content* scans — they document the very
patterns being matched. Staged `.env` files are checked everywhere.

A single line can opt out with a trailing `gate:allow` comment. That is for
reviewed exceptions, not for getting past a real finding.

## Demo: a change that gets blocked

```bash
# 1. plant a secret in real code
printf 'const auth_token = "hk_live_9f3c1a77b2e48d05c6";\n' >> frontend/src/api.js
git add frontend/src/api.js

# 2. ask Claude to commit it — the PreToolUse hook blocks before git runs
#    or reproduce by hand:
make gate        # exit 2, names the file and line

# 3. clean up
git checkout frontend/src/api.js
```

Expected output:

```
BLOCKED  hardcoded secret
         frontend/src/api.js:52:const auth_token = "hk_live_9f3c1a77b2e48d05c6";
         Read it from ENV and add the key to backend/.env instead.

Commit gate failed. Fix the findings above, restage, and retry.
Run the gate yourself with: make gate
```

A `console.log` left in a `.svelte` view blocks the same way, and is the softer
demo if a fake credential on screen is awkward.
