#!/usr/bin/env bash
# Record review evidence so the pre-commit / pre-push gates can confirm a review actually ran.
# Usage: .githooks/record-review.sh <pre-commit|ios-review> <PASS|FAIL> ["one-line summary"]
#
# Evidence is content-addressed — keyed to the staged diff (pre-commit) or HEAD sha (ios-review) —
# so it auto-expires the instant the reviewed content changes. Files live under .git/ (never committed).
set -euo pipefail

kind="${1:?usage: record-review.sh <pre-commit|ios-review> <PASS|FAIL> [summary]}"
verdict="${2:?verdict (PASS|FAIL) required}"
summary="${3:-}"

root="$(git rev-parse --show-toplevel)"
dir="$root/.git/review-evidence"
mkdir -p "$dir"

case "$kind" in
    pre-commit) key="$(git diff --cached | shasum -a 256 | awk '{print $1}')" ;;
    ios-review) key="$(git rev-parse HEAD)" ;;
    *) echo "unknown review kind: $kind (expected pre-commit|ios-review)" >&2; exit 1 ;;
esac

printf '{"kind":"%s","key":"%s","verdict":"%s","summary":"%s","at":"%s"}\n' \
    "$kind" "$key" "$verdict" "$summary" "$(date -u +%FT%TZ)" > "$dir/$kind-$key.json"
echo "✓ recorded $kind evidence ($verdict) for ${key:0:12}"
