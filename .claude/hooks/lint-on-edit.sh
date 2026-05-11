#!/usr/bin/env bash
# lint-on-edit — PostToolUse hook on Write|Edit
#
# Runs the project's linter against the file just touched. Strict: if the
# linter is installed and reports issues, the hook exits 2 (blocking) so the
# agent must fix them before continuing. If the linter isn't installed, the
# hook exits 0 with a one-line note — a fresh clone shouldn't be unable to
# edit.
#
# Adapt the per-extension commands below to your project's actual toolchain.

input=$(cat)
file_path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')

if [[ -z "$file_path" || ! -f "$file_path" ]]; then
  exit 0
fi

case "$file_path" in
  *.py)
    if ! command -v ruff >/dev/null 2>&1; then
      echo "lint-on-edit: ruff not installed; skipping ${file_path}" >&2
      exit 0
    fi
    if ! ruff check --quiet "$file_path"; then
      echo "lint-on-edit: ruff reported issues in ${file_path}" >&2
      exit 2
    fi
    if ! ruff format --check --quiet "$file_path"; then
      echo "lint-on-edit: ${file_path} is not formatted (run: ruff format ${file_path})" >&2
      exit 2
    fi
    ;;
  *.ts|*.tsx|*.js|*.jsx|*.mts|*.cts)
    if ! command -v biome >/dev/null 2>&1; then
      echo "lint-on-edit: biome not installed; skipping ${file_path}" >&2
      exit 0
    fi
    if ! biome check --no-errors-on-unmatched "$file_path"; then
      echo "lint-on-edit: biome reported issues in ${file_path}" >&2
      exit 2
    fi
    ;;
esac

exit 0
