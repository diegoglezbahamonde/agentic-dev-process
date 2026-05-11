#!/usr/bin/env bash
# block-secrets — PreToolUse hook on Write|Edit
#
# Refuses writes that contain obvious credential patterns. Strict by default
# (exit 2 blocks the tool call). Set BLOCK_SECRETS_DISABLE=1 in your env to
# turn the hook into a no-op, or place fixtures under fixtures/ or
# __fixtures__/ to allowlist them.
#
# Pattern set covers the high-signal cases. We deliberately do NOT match
# generic 40-char base64 (too many false positives); the structured prefixes
# (AKIA, ghp_, sk-, …) are what catch real leaks at write-time.

if [[ "${BLOCK_SECRETS_DISABLE:-0}" == "1" ]]; then
  exit 0
fi

input=$(cat)
tool=$(printf '%s' "$input" | jq -r '.tool_name // empty')

case "$tool" in
  Write) field='.tool_input.content' ;;
  Edit)  field='.tool_input.new_string' ;;
  *) exit 0 ;;
esac

content=$(printf '%s' "$input" | jq -r "$field // empty")
file_path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')

case "$file_path" in
  */fixtures/*|*/__fixtures__/*) exit 0 ;;
esac

patterns=(
  'AKIA[0-9A-Z]{16}'
  'ghp_[A-Za-z0-9]{36}'
  'github_pat_[A-Za-z0-9_]{82}'
  'gho_[A-Za-z0-9]{36}'
  'glpat-[A-Za-z0-9_-]{20}'
  'sk-ant-[A-Za-z0-9_-]{20,}'
  'sk-[A-Za-z0-9]{32,}'
  'xox[abpsr]-[A-Za-z0-9-]{10,}'
  '-----BEGIN [A-Z ]*PRIVATE KEY-----'
)

for pattern in "${patterns[@]}"; do
  if printf '%s' "$content" | grep -E -q -e "$pattern"; then
    cat >&2 <<EOF
block-secrets: refused write to ${file_path:-<unknown file>}
matched secret pattern: ${pattern}

If this is a false positive (test fixture, sample doc), either:
  - place the file under a fixtures/ or __fixtures__/ directory, or
  - set BLOCK_SECRETS_DISABLE=1 in your environment to bypass the hook.

Never commit real credentials. Rotate immediately if one was ever committed.
EOF
    exit 2
  fi
done

exit 0
