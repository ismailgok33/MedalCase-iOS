# Module: AchievementsFeature

**Layer:** Feature. **Depends on:** `MedalDomain` + `DesignSystem` only. **No `MedalData` import** (the
App injects a concrete repository); no other feature. This is a leaf in the graph.

## Public surface

- `@Observable @MainActor final class AchievementsViewModel` —
  `init(repository: AchievementsRepository)`; `private(set) var state: ViewState<AchievementsCase>`;
  `func load() async`; `func retry() async`; `func refreshContent() async` (the ADR-0013
  language-change re-fetch: replaces loaded content in place with no `.loading` flip, keeps current
  content on failure, degrades to `load()` from non-loaded states — `AchievementsView` calls it from
  `.onChange(of: appLanguage)`); `func toggleMarathonDemo()` / `func reset()` (the
  overflow-menu demo actions, R1.6 — operate on in-memory state only, no persistence). The overflow
  glyph matches the mock's bare white **vertical** ⋮: SF Symbols has no bare vertical ellipsis, so it
  is `ellipsis` rotated 90° (named `verticalEllipsisAngle` constant), tinted `navTitle`, with iOS 26's
  Liquid Glass capsule hidden via `sharedBackgroundVisibility(.hidden)` (bare glyph pre-26 already).
  The menu's first entry is the EN/FR **language switcher** (ADR-0012): a "Language" submenu of
  buttons with a checkmark on the current selection, each row carrying a stable
  `accessibilityIdentifier` (`language-en`/`language-fr`; the menu itself `overflow-menu` /
  `language-menu`) so UI tests address them language-independently. `AppLanguage` (**public** enum:
  `en`/`fr`, `storageKey`, `systemDefault`, verbatim self-named `displayName` — public because the
  composition root reads the same stored value for the repository's language provider, ADR-0013)
  backs it; `AchievementsView` persists the choice via `AppStorage` and applies
  `.environment(\.locale, …)` outermost plus `.id(appLanguage)` so the whole subtree — including
  UIKit-bridged toolbar content — re-creates on switch, and re-fetches content via `refreshContent()`.
- **The bar title is a `principal` toolbar item, not `navigationTitle`** — a navigationTitle Text is
  hoisted into the UIKit bar and resolves against the app's system language, escaping the SwiftUI
  locale environment (it would ignore the in-app switch; ADR-0012). The principal item re-resolves
  live and takes the mock's exact `navTitle` 16px token + header accessibility trait.
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

- `medalCaseNavigationBar()` (View extension) — applies the mock's teal nav bar (inline title,
  `toolbarBackground` + high-contrast swap), iOS-guarded. Lives here (not the App target) so the App
  needn't depend on the resource-bearing `DesignSystem` package directly (ADR-0011). `AchievementsView`
  applies it.

## Behavior

- `load()` flips `state` to `.loading`, awaits `repository.achievements()`, then sets `.loaded` (has
  renderable medals) or `.empty` (none — R2.3); on `throws`, maps `MedalError → UserFacingError` and
  sets `.error` (R2.2). No raw error text; no silent failure; no infinite spinner.
- `retry()` re-runs the `load()` path (R2.2).
- The grid: a `ScrollView` of sections; each section = `SectionHeaderView(title:progress:)` +
  `LazyVGrid` (2 columns normally — matching the mock — reflowing to **1 column at accessibility text
  sizes** via `dynamicTypeSize.isAccessibilitySize`, so cells grow instead of cramping; R4.3.
  `MedalCellView` per medal, data order — R1.1/R1.3). `progress` is
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
- Localization (R4.4, ADR-0012): `test_localization_frenchCatalog_resolvesNotYet`,
  `test_localization_frenchCatalog_resolvesTitle`,
  `test_localization_frenchCatalog_resolvesLockedAccessibilityFormat`,
  `test_appLanguage_coversEnglishAndFrench`, `test_appLanguage_default_frenchSystem_isFrench`,
  `test_appLanguage_default_englishSystem_isEnglish`,
  `test_appLanguage_default_unsupportedSystem_fallsBackToEnglish`.
- Content refresh (ADR-0013): `test_refreshContent_loaded_replacesContentInPlace`,
  `test_refreshContent_failure_keepsCurrentContent`, `test_refreshContent_fromErrorState_performsFullLoad`.
- Snapshots: `achievements-grid-light`, `-dark`, `-xxl`, plus `medal-cell-earned` / `medal-cell-locked`
  / `test_medalCell_locked_fr` (simulator + pre-push; ADR-0009). UI:
  `test_languageSwitcher_switchesChromeAndContentToFrench` (round-trip, identifier-addressed; also
  asserts the ADR-0013 content refresh via the French payload titles).

## Known corner

- The `UserFacingError` message is a `LocalizedStringResource` created at load-failure time, but it is
  *rendered* by `ErrorStateView` through SwiftUI `Text` inside the `\.locale` environment — the same
  mechanism the switcher UI test proved re-resolves resources per the in-app language (the combined
  header label; see `accessibility.md`). The expectation is therefore that the error surface follows
  the switcher too. Flagged rather than asserted: the error path isn't exercised by the switcher test
  (it would need failure injection into the composed app), so this corner is mechanism-verified, not
  UI-test-pinned. *(An earlier revision claimed the opposite — device-language resolution — from the
  resource's `.current` capture; the probe disproved that model.)*

## Test double

- Consumes the shared `MockAchievementsRepository` from `MedalTestSupport` (spy + stubbable
  case/error). Fixtures come from `AchievementFixtures` (also in `MedalTestSupport`) built from the real
  `achievements.json` — never inline.
