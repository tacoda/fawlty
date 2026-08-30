#!/usr/bin/env bash
# Self-check for the commit gate. Run with `make gate-test`.
# Uses a throwaway git repo so it never touches this project's index.

set -uo pipefail

GATE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fails=0

report() { # label, want, got
  if [ "$2" = "$3" ]; then
    echo "ok   $1"
  else
    echo "FAIL $1 (want exit $2, got $3)"; fails=$((fails + 1))
  fi
}

# ── commit-gate.sh: content rules ────────────────────────────────────────────
sandbox=$(mktemp -d)
trap 'rm -rf "$sandbox"' EXIT
git -C "$sandbox" init -q
git -C "$sandbox" config user.email t@t.t
git -C "$sandbox" config user.name t

gate_on() { # filename, content -> exit code
  printf '%s\n' "$2" > "$sandbox/$1"
  git -C "$sandbox" add "$1" >/dev/null 2>&1
  ( cd "$sandbox" && CLAUDE_PROJECT_DIR="$sandbox" "$GATE/commit-gate.sh" >/dev/null 2>&1 )
  local rc=$?
  git -C "$sandbox" rm -q --cached "$1" >/dev/null 2>&1
  rm -f "$sandbox/$1"
  return $rc
}

gate_on ok.js 'export const x = 1;'; report "clean file passes" 0 $?
gate_on s.js 'const api_key = "hk_live_9f3c1a77b2e48d05";'; report "quoted secret blocked" 2 $?
gate_on u.rb 'HOUSEKEEPING_API_KEY = "hk_live_9f3c1a77b2e48d05"'; report "uppercase constant secret blocked" 2 $?
gate_on c.js 'const apiKey = "hk_live_9f3c1a77b2e48d05";'; report "camelCase secret blocked" 2 $?
gate_on y.yml 'authorization: "Bearer hk_live_9f3c1a77b2e48"'; report "yaml bearer secret blocked" 2 $?
gate_on e.rb 'KEY = ENV.fetch("HOUSEKEEPING_API_KEY")'; report "ENV.fetch allowed" 0 $?
gate_on e.js 'const k = ENV_KEY;'; report "env lookup allowed" 0 $?
gate_on d.js 'console.log("hi");'; report "console.log blocked" 2 $?
gate_on a.js 'console.log("hi"); // gate:allow'; report "gate:allow honored" 0 $?
gate_on p.rb 'binding.pry'; report "binding.pry blocked" 2 $?
gate_on b.rb 'def x('; report "ruby syntax error blocked" 2 $?
gate_on g.rb 'def x; 1; end'; report "valid ruby passes" 0 $?
gate_on f_spec.rb 'fdescribe "x" do end'; report "focused spec blocked" 2 $?

# ── pre-commit-gate.sh: PreToolUse dispatch ──────────────────────────────────
C="git com""mit"; NV="--no-ver""ify"
hook_on() { printf '%s' "$1" | "$GATE/pre-commit-gate.sh" >/dev/null 2>&1; }

hook_on '{"tool_input":{"command":"ls -la"}}'; report "non-commit ignored" 0 $?
hook_on "{\"tool_input\":{\"command\":\"$C $NV -m x\"}}"; report "no-verify refused" 2 $?
hook_on "{\"input\":{\"command\":\"$C -m x\"}}"; report "legacy input field read" 0 $?
hook_on "garbage $C $NV"; report "unparseable payload fails closed" 2 $?

if [ "$fails" -eq 0 ]; then echo "ALL PASS"; else echo "$fails FAILED"; fi
exit "$fails"
