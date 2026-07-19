# MedalCase — Engineering Constitution

> This file governs **all** work in this repository — human and AI. It is the single source of
> truth for *how* we build. Product intent and architecture live in [`tech_specs/`](tech_specs/);
> this file is the *rules*. If a rule here conflicts with a request, follow the rule and say so.

MedalCase is a native iOS (SwiftUI) app — the Runkeeper **Achievements medal case** screen
(2-column grid: Personal Records + Virtual Races) — built through a documented, **spec-driven
agentic pipeline** (see [The AI-DLC pipeline](#the-ai-dlc-pipeline)). Toolchain: **Swift 6
(Xcode 16+) · deployment iOS 17**, strict concurrency on. (Developed on Xcode 26.6; supports the
current OS + the two prior majors — ADR-0005.)

## Golden rules (non-negotiable)

1. **The dependency rule (inward-pointing).** Dependencies point inward toward the domain:
   `AchievementsFeature → MedalDomain ← MedalData`, `AchievementsFeature → DesignSystem`,
   `App → everything`.
   - `MedalDomain` imports **nothing** — no SwiftUI, no UIKit, no Foundation-networking, no other
     module. Pure Swift only.
   - **No feature imports another feature.** Cross-feature needs go through `MedalDomain`.
   - `MedalData` never imports UI; `DesignSystem` never imports domain or data.
   - Don't add a dependency that violates the arrows; boundaries are enforced by package structure.
2. **Spec-first (ADR-0002).** Any change to behavior, a public contract, or acceptance criteria
   **updates the relevant `tech_specs/` file in the same change**. Code never silently diverges
   from spec; new public API without a spec entry fails `/pre-commit-review`.
3. **One type per file.** One primary `struct`/`class`/`enum`/`protocol` per file; filename == type name.
4. **No force-unwrap, force-try, or implicitly-unwrapped optionals** in non-test code
   (`!`, `try!`, `as!`, `T!`). Use `guard let`/`if let`, typed `throws`, or `assertionFailure` with a
   safe fallback. Tests may use `#require`.
5. **No hardcoded user-facing strings or magic values.** User text → String Catalog
   (`Localizable.xcstrings`). Spacing/size/color/radius → DesignSystem tokens. **The mock's hex
   values (`#63C6D4` etc.) exist in exactly one place: DesignSystem.** No literal numbers in views
   beyond `0`/`1`.
6. **Constructor dependency injection.** Inject dependencies as protocols through initializers. No
   singletons or service-locators except the App-target composition root. ViewModels depend on
   domain *protocols*, never concrete data types.
7. **Swift 6 strict concurrency.** `@MainActor` on ViewModels and UI; `Sendable` across boundaries;
   no data races; no `@unchecked Sendable` without a written justification.
8. **Idle by default (the battery rule).** After its single data load, a screen does **no ongoing
   work** — no timers, no polling, no background tasks, no offscreen render effects on grid cells.
   Performance claims are measured in Instruments (M7), not asserted.

## Code quality

- **Naming:** intention-revealing; types `UpperCamelCase`, members `lowerCamelCase`; booleans read as
  assertions (`isEarned`, `hasValue`); no abbreviations.
- **No duplication.** Shared UI → `DesignSystem`; shared logic → `MedalDomain`.
- **Minimal surface area.** `public` only what a consumer needs; everything else `internal`/`private`.
- **Errors are values.** Decoding/mapping failures become a typed `MedalError`, then a
  `UserFacingError` with a localized message + retry affordance. Never surface a raw `Error`; no
  silent failure.
- **Accessibility is a default, not a pass.** Every medal cell is **one** accessibility element —
  "«title», «value»" or "«title», not yet earned". Section headers are VoiceOver headings. Dynamic
  Type to accessibility XXL without truncation ("Tokyo-Hakone Ekiden 2020" must never clip); the
  grid may reflow at accessibility sizes.

## State & UI

- Each async screen drives a `ViewState`: `loading / loaded(...) / empty / error(UserFacingError)`,
  with a **loading**, **empty**, and **error + Retry** surface. No silent failure; no infinite spinner.
- Views are declarative and dumb; logic lives in `@Observable @MainActor` ViewModels.
- Derived display (the "N of M" earned count, formatted values) is **computed from data** — never
  hardcoded to match the mock (ADR-0008).

## Testing

- **Swift Testing** (`import Testing`, `@Test`, `#expect`/`#require`) for unit tests.
- **Mocks live in dedicated files** in `MedalTestSupport` (e.g. `MockAchievementsRepository.swift`)
  — never inline in a test file. Fixtures are built from the **real** `achievements.json` fixture.
- Test behavior, not implementation; one reason to fail per test; name
  `test_subject_condition_expectation`.
- View snapshots via swift-snapshot-testing (light / dark / XXL / locked); the main flow via XCUITest.
- **Definition of done for a module = its spec's "done = these tests" list is green.**

## Git & PR workflow

- **Conventional Commits** (`feat:`, `fix:`, `test:`, `chore:`, `docs:`, `refactor:`).
- **One PR per milestone** (M0…M8 — see [`docs/EXECUTION_PLAN.md`](docs/EXECUTION_PLAN.md)).
- Enable local hooks once per clone: `git config core.hooksPath .githooks`.

### Review cadence (enforced, not optional)

Rules are requests; **hooks and CI are guarantees.** Each check runs at the cheapest boundary that
can enforce it, so "did the review run" is never a matter of memory:

| Check | When | Enforced by |
|---|---|---|
| format | every save | Claude `PostToolUse` hook |
| `swiftlint --strict` | every commit (staged Swift) | `.githooks/pre-commit` |
| **`/pre-commit-review`** | every commit that stages Swift | `.githooks/pre-commit` requires fresh evidence |
| **`/ios-review`** | before pushing a branch with Swift changes | `.githooks/pre-push` requires fresh evidence |
| build + test | every PR | CI |
| `/eval` | changes to `.claude/**`, `evals/**`, `CLAUDE.md`, or a model bump | CI, path-filtered (M7) |
| `/visual-eval` (advisory) | PRs touching UI or snapshot baselines | local, advisory — never blocks |

Review evidence is content-addressed (staged-diff hash / HEAD sha) and auto-expires when the code
changes. Bypass a gate only with `--no-verify`, and say why. (No `/security-review` gate: this app
has no networking/URL/WebView surface — see ADR-0004; it joins the cadence the day a remote source
does.)

### Telemetry (every pipeline run is logged)

Every skill/agent run appends one structured line to `telemetry/runs.jsonl` via
`telemetry/record-run.sh <skill|agent> <name> "<task>" <PASS|FAIL|ADVISORY> [attempts]`.
The README's AI-usage table is **generated from this log** by `/sync-readme` — never hand-curated.

## The AI-DLC pipeline

Govern → **Specify** (`tech_specs/`, human gate) → **Decompose** (module contracts) → **Construct**
(TDD per module) → **Verify** (`/eval` + reviews + CI) → **Document** (`/sync-readme`). Tooling lives
in `.claude/skills/`, `.claude/agents/`, `.claude/workflows/`, and golden evals in `evals/`. Specs
are authoritative; code is generated *from* them and kept coherent with them (rule 2). Only the
workflow is inherited from prior projects — architecture is justified by this brief alone
(`docs/EXECUTION_PLAN.md` §4).

## Build & test commands

```bash
# Regenerate the Xcode project after structural changes (project.yml is the source of truth — ADR-0001)
xcodegen generate

# Per package (fast inner loop)
swift test --package-path Modules/<Package>

# App: build + all tests on the simulator
xcodebuild test -scheme MedalCase \
  -destination 'platform=iOS Simulator,name=iPhone 17'

# Quality gates
swiftformat . && swiftlint --strict
```
