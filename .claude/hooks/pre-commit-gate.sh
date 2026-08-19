#!/usr/bin/env bash
# PreToolUse adapter for the commit gate.
#
# settings.json matches on tool NAME only ("Bash"), so this wrapper reads the
# hook payload from stdin, decides whether the command is a commit, and
# delegates to commit-gate.sh. Exit 2 blocks the tool call and returns stderr
# to the agent as feedback.

set -uo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

payload=$(cat)

# Field name has moved between Claude Code versions; accept either. A payload
# we cannot parse falls back to the raw text, so a shape change degrades into
# over-matching rather than silently disabling the gate.
cmd=$(printf '%s' "$payload" | python3 -c '
import json, sys
raw = sys.stdin.read()
try:
    d = json.loads(raw)
    ti = d.get("tool_input") or d.get("input") or {}
    print(ti.get("command", ""))
except Exception:
    print(raw)
' 2>/dev/null) || cmd="$payload"

# Not a commit? Nothing to gate.
case "$cmd" in
  *"git commit"*) ;;
  *) exit 0 ;;
esac

# --no-verify skips the git hook, so refuse it outright here.
case "$cmd" in
  *--no-verify*|*" -n "*)
    printf 'BLOCKED  --no-verify bypasses the commit gate.\n' >&2
    printf '         Fix the findings instead of skipping the gate.\n' >&2
    exit 2
    ;;
esac

exec "$DIR/commit-gate.sh"
