# ADR-0010 — Value formatting policy (typed MedalValue)

**Status:** accepted (M1)

## Context
The mock mixes value renderings with no stated rule (L2): `00:00`, `00:00:00`, `23:07`, `2095 ft`,
"Not Yet". Inferring style from magnitude (e.g. "hours only when ≥ 1h") contradicts the mock —
zero-duration cells appear in *both* styles.

## Decision
`MedalValue` is a typed union — `duration(seconds:style:)` | `elevation(feet:)` — and the duration
**style is carried in the data** (`minutes_seconds` / `hours_minutes_seconds`), because display
style is a per-medal product decision, not derivable. One pure `MedalValueFormatter` in the domain
renders: MM:SS, HH:MM:SS, "«feet» ft" (mock-exact: no digit grouping), and the localized "Not Yet"
for locked. Unknown `kind` degrades to no value line (policy P3); negatives clamp to 0 (P8).

## Consequences
Formatting is exhaustively unit-testable and lives in one place; new value kinds (distance, pace,
calories) extend the union without touching views. Trade-off, named honestly: mock-exact output
beats locale-correct output here — production would move to `Measurement`/`Duration` formatting
with locale units (ft ↔ m) behind the same formatter seam, and the README's roadmap says so.
