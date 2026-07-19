# ADR-0008 — Data-driven counts vs mock fidelity ("4 of 6")

**Status:** accepted (M1)

## Context
The mock's Personal Records header reads **"4 of 6"**, but its cells show **5** colored medals and
one ghosted "Not Yet". No interpretation reconciles them (counting non-zero values yields 1, not
4). The two annotations are mutually unsatisfiable — a landmine (L1) that forces a documented
choice.

## Decision
The header count is **always computed from data**: `earned / total` per section, never a literal.
Where the mock conflicts with itself, **visual medal states win**: the fixture mirrors 5 earned +
1 locked, so the header renders **"5 of 6"**. A fixture with 4 earned would render "4 of 6" —
matching the annotation is a data change, not a code change.

## Consequences
The UI cannot drift from its data; the discrepancy is surfaced in the README as found-and-resolved
rather than silently copied. Trade-off: we knowingly diverge from one annotation character to keep
the screen internally consistent — the defensible side of an impossible constraint.
