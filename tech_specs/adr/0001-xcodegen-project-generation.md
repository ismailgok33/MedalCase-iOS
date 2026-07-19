# ADR-0001 — XcodeGen project generation

**Status:** accepted (M0)

## Context
The take-home is reviewed by "unzip → open → Run". Hand-managed `.xcodeproj` files churn opaquely,
invite merge conflicts, and — as happened with the Xcode-template bootstrap — leave the scheme in
`xcuserdata`, invisible to CI and reviewers.

## Decision
`project.yml` is the source of truth; the generated `MedalCase.xcodeproj` (with **shared** schemes)
is committed. Contributors regenerate after structural changes with `xcodegen generate`; CI
regenerates on every run, so drift between the two is caught immediately.

## Consequences
Reviewers need no tooling. Project structure is reviewable as a ~60-line YAML diff instead of pbxproj
noise. Packages/test targets are added per milestone by editing one file. Cost: one dev-machine
dependency (`brew install xcodegen`), not needed to open or run the app.

**Freshness.** CI regenerates the project from `project.yml` on every run, so it always builds a fresh,
correct project — the committed `.xcodeproj` is a convenience for reviewers who open without XcodeGen.
Regenerate after any structural change (`xcodegen generate`) so the committed copy stays current.
(A local "Missing package product" after pulling is a *separate* Xcode SPM-cache issue — the project is
fine; Xcode's DerivedData resolution is stale. Full fix in the README's setup note.)

*Trade-off considered:* a CI drift-guard (fail if the committed project differs from a fresh generate)
was tried and removed — it couples the committed bytes to CI's exact XcodeGen version, so a routine
`brew` bump (2.45→2.46) breaks the build over cosmetic diffs. Regenerating fresh is simpler and robust.
