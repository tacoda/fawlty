#!/usr/bin/env bash
# Fawlty layer check.
#
# The rules in .claude/rules/ describe the layering. This makes them binding.
# Runs as a Claude Code PostToolUse hook on Write|Edit: the file is already on
# disk, and exit 2 hands stderr back to the agent so it fixes what it just
# wrote instead of carrying the violation into the next five files.
#
# Also runnable by hand:  ./.claude/hooks/layer-check.sh path [path...]
#
# ponytail: grep, not a parser. A Ruby AST pass would catch more and cost more.
# Swap it in if the false-negative rate ever matters.

set -uo pipefail

cd "${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel)}" || exit 0

FAILED=0

fail() { # rule, file, evidence blob, remedy
  FAILED=1
  printf 'LAYERING  %s\n' "$1" >&2
  printf '          in %s\n' "$2" >&2
  printf '%s\n' "$3" | while IFS= read -r l; do printf '          %s\n' "$l"; done >&2
  printf '          -> %s\n\n' "$4" >&2
}

hits() { grep -nE "$2" "$1" 2>/dev/null | grep -v 'gate:allow' || true; }

check() {
  local f="$1" found
  [ -f "$f" ] || return 0

  case "$f" in
    # ── Actions must not query. Repos own every relation call. ──────────────
    backend/app/actions/*)
      found=$(hits "$f" '(Sequel\.|\.by_pk\(|\.where\(|\.order\(|\.join\(|\.dataset\b|Backend::Relations|\["relations\.)')
      [ -n "$found" ] && fail \
        "action contains query logic" "$f" "$found" \
        "Move the query into app/repos/<name>_repo.rb and call it through Deps."
      ;;
  esac

  case "$f" in
    # ── api.js is the only place fetch is allowed. ──────────────────────────
    frontend/src/api.js) ;;
    frontend/src/*)
      found=$(hits "$f" '\bfetch\(')
      [ -n "$found" ] && fail \
        "fetch outside the API boundary" "$f" "$found" \
        "Add the call to the resource object in frontend/src/api.js and import it."
      ;;
  esac

  case "$f" in
    # ── House convention: every Ruby file declares frozen literals. ─────────
    backend/*.rb)
      head -3 "$f" | grep -q 'frozen_string_literal: true' || fail \
        "missing frozen_string_literal magic comment" "$f" "line 1" \
        "Add '# frozen_string_literal: true' to the top of the file."
      ;;
  esac
}

if [ "$#" -gt 0 ]; then
  for f in "$@"; do check "$f"; done
else
  # PostToolUse payload on stdin. An unparseable payload checks nothing rather
  # than blocking every edit.
  f=$(python3 -c '
import json, sys
try:
    d = json.loads(sys.stdin.read())
    print((d.get("tool_input") or d.get("input") or {}).get("file_path", ""))
except Exception:
    print("")
' 2>/dev/null) || exit 0
  [ -z "$f" ] && exit 0
  check "${f#"$PWD/"}"
fi

[ "$FAILED" -ne 0 ] && exit 2
exit 0
