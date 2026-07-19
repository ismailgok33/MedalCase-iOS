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

**Drift guard.** Because the generated `.xcodeproj` is committed *and* CI regenerates it, a stale commit
could pass CI while a reviewer who opens the committed project gets something different. CI therefore
runs `xcodegen generate` and **fails if the committed `.xcodeproj` differs** — so the two can never
silently diverge. (A local "Missing package product" after pulling is a separate Xcode SPM-cache issue,
not project drift — see the README's setup note.)
