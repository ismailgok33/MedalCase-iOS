#!/usr/bin/env bash
# PostToolUse hook — auto-format edited Swift files with SwiftFormat.
# No-op (exit 0) when the file isn't Swift or SwiftFormat isn't installed,
# so the repo stays portable across machines.
input="$(cat)"
file_path="$(printf '%s' "$input" | python3 -c 'import sys, json
try:
    print(json.load(sys.stdin).get("tool_input", {}).get("file_path", ""))
except Exception:
    print("")' 2>/dev/null)"
[ -n "$file_path" ] || exit 0
case "$file_path" in
  *.swift) ;;
  *) exit 0 ;;
esac
if command -v swiftformat >/dev/null 2>&1 && [ -f "$file_path" ]; then
  swiftformat "$file_path" --quiet >/dev/null 2>&1 || true
fi
exit 0
