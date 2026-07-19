# ADR-0007 — Locked medals are derived, not separate assets

**Status:** accepted (M1)

## Context
The mock shows the locked Marathon as a ghosted version of its badge with "Not Yet". The asset kit
provides **no** locked variant — one colored PDF per medal.

## Decision
Derive the locked appearance in the DesignSystem: the earned asset rendered through a ghosting
modifier (`saturation(0)` + reduced opacity, tuned against the mock). `status` alone drives the
treatment; a locked medal with a stray `value` still renders locked (policy P6).

## Consequences
Every current and future medal gets a locked state for free — no second asset to design, ship, or
drift. The treatment is one modifier, snapshot-tested (`medal-cell-locked`). Cost: we approximate
the mock's ghost rather than pixel-copy an asset that doesn't exist; the snapshot baseline is the
agreed rendering.
