# Module: AchievementsFeature

**Layer:** Feature. **Depends on:** `MedalDomain` + `DesignSystem` only. **No `MedalData` import** (the
App injects a concrete repository); no other feature. This is a leaf in the graph.

## Public surface

- `@Observable @MainActor final class AchievementsViewModel` —
  `init(repository: AchievementsRepository)`; `private(set) var state: ViewState<AchievementsCase>`;
  `func load() async`; `func retry() async`; `func toggleMarathonDemo()` / `func reset()` (the
  overflow-menu demo actions, R1.6 — operate on in-memory state only, no persistence).
- `struct AchievementsView: View` — `init(viewModel: AchievementsViewModel)`. A dumb `switch` over
  `state`: loading → `AchievementsGridSkeleton`, loaded → the grid, empty → `EmptyStateView`, error →
  `ErrorStateView(retry:)`.
- `struct MedalCellView: View` — one grid cell (badge + title + value line); the atom the grid repeats.

Internal testable seams (reached via `@testable`, so the logic behind the views is unit-tested without
rendering):
- `enum SectionProgress` — `value(for:) -> (earned, total)?`, returning the count only when the section
  declares it (R1.2, ADR-0008). The grid renders whatever this returns; it never counts inline.
- `enum MedalAccessibility` — `label(for:) -> LocalizedStringResource`, the cell's single VoiceOver
  label ("«title», «value»" / "«title», not yet earned" / just the title). `LocalizedStringResource`
  so the phrase localizes and tests can resolve it via `String(localized:)`.
- `AchievementsViewModel.marathonDemoID` — the id (`"pr_marathon"`) the demo toggle targets.

SwiftUI `#Preview`s (loading/loaded/empty/error) use an **inline** DEBUG-only repository + sample data,
so the production target never depends on `MedalTestSupport` (that stays a test-target dependency).

## Behavior

- `load()` flips `state` to `.loading`, awaits `repository.achievements()`, then sets `.loaded` (has
  renderable medals) or `.empty` (none — R2.3); on `throws`, maps `MedalError → UserFacingError` and
  sets `.error` (R2.2). No raw error text; no silent failure; no infinite spinner.
- `retry()` re-runs the `load()` path (R2.2).
- The grid: a `ScrollView` of sections; each section = `SectionHeaderView(title:progress:)` +
  `LazyVGrid` (2 fixed columns, `MedalCellView` per medal, data order — R1.1/R1.3). `progress` is
  `(section.earnedCount, section.totalCount)` **only when** `section.showsProgressCount` (R1.2, ADR-0008)
  — the ViewModel/section supplies it, the view never counts.
- `MedalCellView`: `MedalBadgeView(assetKey:isLocked:)` + title (`medalTitle` token) + value line.
  Value = `MedalValueFormatter.string(for:)` for earned; the localized **"Not Yet"** catalog string for
  locked (R1.5, R3.4). The whole cell is **one** accessibility element: "«title», «value»" earned /
  "«title», not yet earned" locked (R4.1).
- **Battery rule (CLAUDE.md 8):** the ViewModel loads once and goes inert — no timers/polling/tasks;
  `LazyVGrid` materializes cells on demand (R5.1/R5.2); stable `Achievement.id` → no diff churn.
- A `#Preview` per state (loading/loaded/empty/error) driven by `MockAchievementsRepository`.

## done = these tests

- `test_achievementsViewModel_loadSuccess_setsLoaded` — mock returns the fixture case → `.loaded`.
- `test_achievementsViewModel_loadSuccess_preservesSectionAndMedalOrder` (R1.1/R1.3).
- `test_achievementsViewModel_loadEmpty_setsEmpty` — mock returns an empty case → `.empty` (R2.3).
- `test_achievementsViewModel_loadFailure_setsErrorWithRetry` — mock throws → `.error`, `isRetryable`.
- `test_achievementsViewModel_retry_reloadsAfterFailure` — fail then succeed → `.loaded`; spy shows 2
  calls.
- `test_achievementsViewModel_toggleMarathonDemo_flipsStatus` — demo action mutates in-memory state.
- `test_medalCell_accessibilityLabel_earned`, `test_medalCell_accessibilityLabel_locked` (R4.1).
- `test_sectionHeader_progress_shownOnlyWhenDeclared` — PRs show "5 of 6"; races show no count (R1.2).
- Snapshots: `achievements-grid-light`, `-dark`, `-xxl`, plus `medal-cell-earned` / `medal-cell-locked`
  (simulator + pre-push; ADR-0009).

## Test double

- Consumes the shared `MockAchievementsRepository` from `MedalTestSupport` (spy + stubbable
  case/error). Fixtures come from `AchievementFixtures` (also in `MedalTestSupport`) built from the real
  `achievements.json` — never inline.
