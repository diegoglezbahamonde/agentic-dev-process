#!/usr/bin/env bash
# enforce-tdd — PreToolUse hook on Write|Edit
#
# When the agent is about to edit production code, check that a test file was
# also touched in the recent past (10 minutes). Warn-only by default; set
# TDD_HOOK_STRICT=1 in your env to make it block (exit 2). The warn-only
# default matches the QUICKSTART's "calibration period" guidance — a strict
# hook on day one fights the agent more than it teaches it.
#
# See docs/testing/tdd-workflow.md for the discipline this hook backstops.

input=$(cat)
file_path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')

if [[ -z "$file_path" ]]; then
  exit 0
fi

# Only consider source-code extensions
case "$file_path" in
  *.py|*.ts|*.tsx|*.js|*.jsx) ;;
  *) exit 0 ;;
esac

# The test file itself, scaffolding, and non-app paths don't trigger
case "$file_path" in
  *test_*.py|*_test.py|*/tests/*|*/__tests__/*|*/__test__/*|*.test.ts|*.test.tsx|*.test.js|*.test.jsx|*.spec.ts|*.spec.tsx|*.spec.js|*.spec.jsx)
    exit 0 ;;
  */docs/*|*/.claude/*|*/scripts/*|*/migrations/*|*/node_modules/*|*/.venv/*|*/dist/*|*/build/*)
    exit 0 ;;
esac

# Look for any test file modified in the last 10 minutes
recent_test=$(find . \
  \( -path '*/node_modules' -o -path '*/.venv' -o -path '*/.git' -o -path '*/dist' -o -path '*/build' \) -prune -o \
  -type f \( -name 'test_*.py' -o -name '*_test.py' -o -name '*.test.ts' -o -name '*.test.tsx' -o -name '*.test.js' -o -name '*.spec.ts' -o -name '*.spec.tsx' -o -name '*.spec.js' \) \
  -newermt '10 minutes ago' -print 2>/dev/null | head -1)

if [[ -n "$recent_test" ]]; then
  exit 0
fi

msg="enforce-tdd: about to edit ${file_path} but no test file was modified in the last 10 minutes.
TDD says the failing test comes first. See docs/testing/tdd-workflow.md.
(Set TDD_HOOK_STRICT=1 to make this hook blocking.)"

if [[ "${TDD_HOOK_STRICT:-0}" == "1" ]]; then
  echo "$msg" >&2
  exit 2
fi

echo "$msg" >&2
exit 0
