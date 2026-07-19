#!/usr/bin/env bash
# Append one structured JSONL line per pipeline run (skill or agent invocation).
# This log is the source of truth for the README's AI-usage table (/sync-readme) —
# generated telemetry, never hand-curated. Committed on purpose.
#
# Usage: telemetry/record-run.sh <skill|agent> <name> "<task>" <PASS|FAIL|ADVISORY> [attempts] [notes]
set -euo pipefail

kind="${1:?usage: record-run.sh <skill|agent> <name> \"<task>\" <PASS|FAIL|ADVISORY> [attempts] [notes]}"
name="${2:?name required (e.g. tdd, swift-reviewer)}"
task="${3:?task required (one line, no quotes)}"
verdict="${4:?verdict (PASS|FAIL|ADVISORY) required}"
attempts="${5:-1}"
notes="${6:-}"

root="$(git rev-parse --show-toplevel)"
file="$root/telemetry/runs.jsonl"
mkdir -p "$root/telemetry"

head_sha="$(git rev-parse --short HEAD 2>/dev/null || echo 'no-head')"
printf '{"at":"%s","kind":"%s","name":"%s","task":"%s","verdict":"%s","attempts":%s,"head":"%s","notes":"%s"}\n' \
    "$(date -u +%FT%TZ)" "$kind" "$name" "$task" "$verdict" "$attempts" "$head_sha" "$notes" >> "$file"
echo "✓ telemetry: $kind/$name → $verdict (${attempts} attempt(s))"
