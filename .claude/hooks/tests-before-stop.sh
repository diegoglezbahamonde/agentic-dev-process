#!/usr/bin/env bash
# tests-before-stop — Stop hook
#
# Warn-only by default (just prints a reminder). Set TESTS_BEFORE_STOP=1 in
# your env to make it actually run the test suite and block (exit 2) if tests
# fail. Matches the QUICKSTART's gradual-rollout guidance — opt in once the
# suite is fast and reliable enough that blocking won't trap you.
#
# Adapt the runner commands to your project's actual toolchain.

if [[ "${TESTS_BEFORE_STOP:-0}" != "1" ]]; then
  cat >&2 <<EOF
tests-before-stop: reminder — run the test suite before handing back.
(Set TESTS_BEFORE_STOP=1 to make this hook block on test failures.)
EOF
  exit 0
fi

ran=""

if [[ -f pyproject.toml ]]; then
  if command -v uv >/dev/null 2>&1; then
    echo "tests-before-stop: uv run pytest -q" >&2
    if ! uv run pytest -q; then
      echo "tests-before-stop: pytest failed; refusing to stop." >&2
      exit 2
    fi
    ran="pytest"
  elif command -v pytest >/dev/null 2>&1; then
    echo "tests-before-stop: pytest -q" >&2
    if ! pytest -q; then
      echo "tests-before-stop: pytest failed; refusing to stop." >&2
      exit 2
    fi
    ran="pytest"
  fi
fi

if [[ -f package.json ]]; then
  if command -v pnpm >/dev/null 2>&1 && jq -e '.scripts.test' package.json >/dev/null 2>&1; then
    echo "tests-before-stop: pnpm test" >&2
    if ! pnpm test; then
      echo "tests-before-stop: pnpm test failed; refusing to stop." >&2
      exit 2
    fi
    ran="${ran:+$ran, }pnpm test"
  fi
fi

if [[ -z "$ran" ]]; then
  echo "tests-before-stop: no recognized test runner; passing." >&2
fi

exit 0
