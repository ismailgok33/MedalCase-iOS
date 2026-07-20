# Module: DesignSystem

**Layer:** Design. **Depends on:** SwiftUI only — the module is **UIKit-free** (the nav bar is styled
by the App via scoped SwiftUI toolbar modifiers, so no `UINavigationBarAppearance` helper lives here).
Domain-agnostic — no `MedalDomain` import, no data types. Owns every hex/size/space from the mock so
**no magic value escapes this module** (CLAUDE.md rule 5).

## Layout

Sources grouped by role: `Tokens/` (color, typography, spacing, radius), `Components/` (reusable views),
`States/` (loading / empty / error surfaces mirroring `ViewState`), `Assets/` (the medal asset catalog +
typed accessor). Subfolders are navigational only — SPM compiles `Sources/` as one module; the boundary
is the package.

## Public surface

- **Tokens** (the mock's annotations, single source — ADR mock p.3):
  - `SemanticColor`: `brandTeal` (`#63C6D4`), `brandTealHighContrast` (darkened teal clearing AA on
    white — accessibility.md), `navTitle` (`#FFFFFF`), `sectionTitle` (`#333333`), `sectionCount`
    (`#666666`), `medalTitle` (`#000000`), `medalValue` (`#666666`), `sectionStrip` (`#F7F7F7`),
    `surface` (`#FFFFFF`). All **adaptive** for light/dark (dark values in the asset catalog's
    colorset), so contrast holds in both modes.
  - `Typography`: `navTitle` (16), `sectionTitle` (14), `sectionCount` (14), `medalTitle` (12),
    `medalValue` (12) — `TypographyToken`s (size + `relativeTo` text style + weight) applied via the
    `.medalFont(_:)` modifier, which uses `@ScaledMetric` so the mock's exact px→pt sizes still scale
    with Dynamic Type (L8). No fixed sizes escape.
  - `Spacing`, `Radius` — grid gutter, cell padding, badge size, corner radii.
  - `Opacity` — `ghosted` (the locked-medal ghost opacity, tuned against the mock — ADR-0007).
  - `IconMetrics` (internal) — dot diameter/gap for the drawn vertical-ellipsis glyph.
- **Assets:**
  - `MedalAsset` — a typed accessor mapping the contract's `assetKey` → an `Image`. The only public
    member is `image(for:)`, which returns the catalog image or a placeholder SF Symbol for an unknown
    key (policy P5). A pure `internal` `resolution(for:) -> Resolution` (`.catalog(name)` | `.placeholder`)
    is the testable seam that `image(for:)` renders, and `internal knownKeys` is the catalog's source of
    truth (both `internal`, reached by tests via `@testable`). All 13 PDFs imported Single Scale +
    Preserve Vector Data (ADR-0006); the unused `race_virtual_marathon` ships but is unreferenced by the
    fixture (L4).
- **State:** `ViewState<Value>` (`loading`/`loaded(Value)`/`empty`/`error(UserFacingError)`) +
  `UserFacingError` (`message: LocalizedStringResource` + `isRetryable`). `LocalizedStringResource`,
  not `LocalizedStringKey`, because the error crosses the `@MainActor` ViewModel → View boundary inside
  `ViewState` and must be `Sendable`. Domain-agnostic; the feature maps `MedalError → UserFacingError`.
- **Components:**
  - `SectionHeaderView(title:progress:)` — the `#F7F7F7` strip: leading title, optional trailing
    "N of M" (`progress: (earned: Int, total: Int)?`, shown only when non-nil — R1.2). Carries the
    accessibility heading trait; announces "N of M earned" (R4.2).
  - `MedalBadgeView(assetKey:isLocked:)` — renders the badge via `MedalAsset`; when `isLocked`, applies
    the **ghosting modifier** (`saturation(0)` + reduced opacity — ADR-0007). Decorative
    (`accessibilityHidden`); the cell owns the label.
  - `LoadingView`, `EmptyStateView(message: Text)`, `ErrorStateView(message:isRetryable:retry:)` — the
    three state surfaces (R2). `EmptyStateView` takes a pre-resolved `Text` (the caller localizes
    against its own package catalog with `bundle: .module`; a bare key rendered here would resolve
    against the app's main bundle and miss every package table — ADR-0012). `ErrorStateView` takes
    `message: LocalizedStringResource` + `isRetryable`
    (defaulted true; hides the Retry button when false) + the `retry` action, so the feature drives it
    from the `UserFacingError`'s fields.
  - `AchievementsGridSkeleton(cellCount:)` — the loading state: redacted placeholder cells, not a bare
    spinner; collapses to one "Loading" VoiceOver label.
  - `VerticalEllipsisIcon()` — the mock's bare ⋮ drawn as three circles (SF has no bare vertical
    ellipsis; a rotated `ellipsis` symbol stalls at a single dot for ~1.2 s in iOS 26's menu-dismiss
    morph — probe-measured). Inherits the caller's `foregroundStyle`; `@ScaledMetric` dot geometry
    from `IconMetrics`; decorative (`accessibilityHidden`) — the consuming control owns the label.
    *done =* snapshot `test_verticalEllipsisIcon`.
- **Nav bar styling** uses SwiftUI's **scoped** `.toolbarBackground(SemanticColor.brandTeal, …)` +
  `.toolbarColorScheme(.dark, …)`, swapping to `brandTealHighContrast` under Increased Contrast — not a
  global `UINavigationBar.appearance()` mutation, and no UIKit appearance factory (the module is
  UIKit-free). DesignSystem exposes the teal *tokens*; the styling is applied by **`AchievementsFeature`**
  (`medalCaseNavigationBar()`), not the App target, so the App need not depend on DesignSystem directly
  (ADR-0011).

## Behavior

- Components are stateless and Dynamic-Type + long-title safe (`Text` wraps, `lineLimit(nil)`, no
  truncation — R4.3).
- The ghosting modifier is a pure `ViewModifier` so the locked rendering is one reusable, snapshot-tested
  unit (ADR-0007).
- User-facing text localizes via the module's own **EN + FR `.lproj` `.strings` tables**
  (`Resources/en.lproj`, `Resources/fr.lproj`; auto-detected by SwiftPM under `defaultLocalization`)
  with every lookup passing `bundle: .module`. Keys: `Retry`, `%lld of %lld` (the header count —
  "%lld sur %lld" in FR), `%@, %lld of %lld earned` (the header's combined VoiceOver label — R4.2),
  `Loading`. Per-locale `.strings` rather than an `.xcstrings` catalog
  because `swift build`/`swift test` copy String Catalogs verbatim without compiling them
  (ADR-0012); Xcode builds both formats fine, the CLI only the classic one.
  **Resource-form strings** (accessibility labels/formats that must exist as `LocalizedStringResource`
  values) live in the internal **`L10n`** namespace — the module-bundle plumbing exists once, and the
  shared `Loading` key is defined once (used by both loading surfaces). Single-use visual strings
  stay inline as `Text("…", bundle: .module)`, the platform idiom.

## done = these tests

- `test_medalAsset_knownKey_returnsImage`, `test_medalAsset_unknownKey_returnsPlaceholder` (P5) — pure
  accessor logic via `swift test`.
- `test_sectionHeaderView_withProgress_showsCount`, `test_sectionHeaderView_noProgress_hidesCount` —
  component snapshots.
- `test_medalBadgeView_locked_isGhosted` — snapshot of the ghosting modifier (light + dark).
- Localization (R4.4, ADR-0012): `test_localization_frenchCatalog_resolvesRetry`,
  `test_localization_frenchCatalog_resolvesProgressCountFormat`,
  `test_localization_frenchCatalog_resolvesHeaderEarnedFormat` (the combined header VoiceOver label);
  through the production `L10n` accessors: `test_l10n_loading_resolvesFrenchThroughProductionAccessor`,
  `test_l10n_sectionHeaderLabel_resolvesFrenchThroughProductionAccessor`.
- Component snapshots: earned cell chrome, locked cell, section strip, grid skeleton, the three state
  surfaces — **at default + accessibility XXL, light + dark** (renderer-pinned, run on the simulator +
  pre-push, skipped in CI — ADR-0009).

## Test double

- Pure token/asset logic needs no doubles. Snapshot cases render real components with fixture-shaped
  inputs (primitives, not domain types — the module stays domain-agnostic).
