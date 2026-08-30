#!/usr/bin/env bash
# Fawlty commit gate.
#
# Runs in two places, same contract:
#   - Claude Code PreToolUse hook on `Bash(git commit*)` — exit 2 blocks the
#     tool call and feeds stderr back to the agent as feedback.
#   - .git/hooks/pre-commit (via `make hooks`) — any nonzero blocks the commit.
#
# Checks staged content only. Fast, offline, no Docker, no network.
# ponytail: grep over the staged diff, not a real scanner. Swap in gitleaks
# if the secret rules ever need to be more than a handful of shapes.

set -uo pipefail

cd "${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel)}" || exit 2

FAILED=0

fail() { # label, detail blob (may be multiline), optional remedy
  FAILED=1
  printf 'BLOCKED  %s\n' "$1" >&2
  shift
  for blob in "$@"; do
    printf '%s\n' "$blob" | while IFS= read -r l; do
      printf '         %s\n' "$l" >&2
    done
  done
}

# Staged files. `git commit -a` stages nothing at hook time, so fall back to
# tracked-and-modified.
files=$(git diff --cached --name-only --diff-filter=ACM)
[ -z "$files" ] && files=$(git diff --name-only --diff-filter=ACM)
[ -z "$files" ] && exit 0

# Exempt from content scans: config that documents the very patterns being
# matched. .claude/ is the gate's own rules; the linter configs name the rules
# they ban, so eslint.config.js necessarily contains the string "no-debugger".
# Everything else is fair game.
scannable=$(printf '%s\n' "$files" \
  | grep -v '^\.claude/' \
  | grep -vE '(^|/)(eslint\.config\.(js|mjs|cjs)|\.eslintrc.*|\.rubocop\.yml)$' || true)

staged_content() {
  # Prefer the index; fall back to worktree for `git commit -a`.
  git show ":$1" 2>/dev/null || cat "$1" 2>/dev/null
}

hits() { # file, pattern, [grep flags]
  local out
  out=$(staged_content "$1" | grep -nE ${3:-} "$2" | grep -v 'gate:allow' || true)
  [ -n "$out" ] && printf '%s\n' "$out" | while IFS= read -r l; do
    printf '%s:%s\n' "$1" "$l"
  done
}

# ── 1. Secrets ───────────────────────────────────────────────────────────────
# Two passes: credential *shapes* are case-sensitive (AKIA, sk-, ghp_ are
# literal prefixes), but the keyword form is not — Ruby constants shout
# (API_KEY = "...") and JS does not (apiKey = "...").
SECRET_SHAPES='AKIA[0-9A-Z]{16}|sk-(ant-)?[A-Za-z0-9_-]{20,}|gh[pousr]_[A-Za-z0-9]{20,}|-----BEGIN [A-Z ]*PRIVATE KEY-----'
QUOTED='[[:space:]]*[:=][[:space:]]*["'"'"'][^"'"'"']{8,}["'"'"']'
SECRET_WORDS="(password|passwd|secret|api_?key|access_?token|auth_?token|authorization)$QUOTED|Bearer[[:space:]]+[A-Za-z0-9_.-]{16,}"
for f in $scannable; do
  found=$(printf '%s\n%s' "$(hits "$f" "$SECRET_SHAPES")" "$(hits "$f" "$SECRET_WORDS" -i)" | grep -v '^$' || true)
  [ -n "$found" ] && fail "hardcoded secret" "$found" \
    "Read it from ENV.fetch and add the key to backend/.env instead."
done

# ── 2. Debug leftovers ───────────────────────────────────────────────────────
for f in $scannable; do
  case "$f" in
    *.rb)             pat='binding\.(pry|irb)|byebug|\bdebugger\b' ;;
    *.js|*.svelte)    pat='console\.(log|debug)|\bdebugger\b' ;;
    *) continue ;;
  esac
  found=$(hits "$f" "$pat")
  [ -n "$found" ] && fail "debug statement left in" "$found" \
    "Remove it, or mark the line 'gate:allow' if it is deliberate."
done

# ── 3. Focused tests ─────────────────────────────────────────────────────────
for f in $scannable; do
  case "$f" in *_spec.rb) ;; *) continue ;; esac
  found=$(hits "$f" '\bfdescribe\b|\bfit\b|\bfcontext\b|:focus')
  [ -n "$found" ] && fail "focused test would skip the suite" "$found"
done

# ── 4. Environment files ─────────────────────────────────────────────────────
for f in $files; do
  case "$f" in
    *.env|.env|*/.env|*.env.local)
      fail "environment file staged: $f" "Add it to .gitignore." ;;
  esac
done

# ── 5. Ruby syntax ───────────────────────────────────────────────────────────
if command -v ruby >/dev/null 2>&1; then
  for f in $scannable; do
    case "$f" in *.rb) ;; *) continue ;; esac
    err=$(staged_content "$f" | ruby -c 2>&1 >/dev/null) || \
      fail "ruby syntax error in $f" "$err"
  done
fi

if [ "$FAILED" -ne 0 ]; then
  printf '\nCommit gate failed. Fix the findings above, restage, and retry.\n' >&2
  printf 'Run the gate yourself with: make gate\n' >&2
  exit 2
fi

exit 0
