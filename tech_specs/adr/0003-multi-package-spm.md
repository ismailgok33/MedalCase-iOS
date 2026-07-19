# ADR-0003 — Multi-package SPM architecture

**Status:** accepted (M1)

## Context
A single-target app enforces layering only by convention. This project's grading centers on "well
written code" and feeds an architecture discussion; Runkeeper itself is a large multi-pod codebase
where ownership boundaries matter.

## Decision
Five local SPM packages (`MedalDomain`, `MedalData`, `DesignSystem`, `AchievementsFeature`,
`MedalTestSupport`) with an inward-pointing dependency rule **enforced by the package graph** — an
illegal import fails to compile, not code review. The App target is a thin composition root.

## Consequences
Boundaries are structural; `swift test --package-path` gives a fast per-package inner loop; the
layout maps to pod ownership (JD) and mirrors how the screen would slot into a real modular app.
Cost: more manifests than a folder layout — accepted as the point, not overhead. Scaled to five
packages the brief earns; no speculative extras (no Networking package — ADR-0004).
