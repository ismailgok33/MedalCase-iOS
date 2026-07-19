# Module: DesignSystem

**Layer:** Design. **Depends on:** SwiftUI only (plus a guarded `UIKit` section for the nav-bar
appearance helper). Domain-agnostic — no `MedalDomain` import, no data types. Owns every hex/size/space
from the mock so **no magic value escapes this module** (CLAUDE.md rule 5).

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
  - `LoadingView`, `EmptyStateView(message:)`, `ErrorStateView(message:isRetryable:retry:)` — the three
    state surfaces (R2). `ErrorStateView` takes `message: LocalizedStringResource` + `isRetryable`
    (defaulted true; hides the Retry button when false) + the `retry` action, so the feature drives it
    from the `UserFacingError`'s fields.
  - `AchievementsGridSkeleton(cellCount:)` — the loading state: redacted placeholder cells, not a bare
    spinner; collapses to one "Loading" VoiceOver label.
- **Appearance helper:** `NavigationBarAppearance.medalCase(highContrast:)` — a `UINavigationBarAppearance`
  factory (teal background, white title) the App target applies. Guarded `UIKit` import; the only UIKit
  in the module.

## Behavior

- Components are stateless and Dynamic-Type + long-title safe (`Text` wraps, `lineLimit(nil)`, no
  truncation — R4.3).
- The ghosting modifier is a pure `ViewModifier` so the locked rendering is one reusable, snapshot-tested
  unit (ADR-0007).
- User-facing literals are `LocalizedStringKey`s (catalog-ready); the catalog is wired in M6.

## done = these tests

- `test_medalAsset_knownKey_returnsImage`, `test_medalAsset_unknownKey_returnsPlaceholder` (P5) — pure
  accessor logic via `swift test`.
- `test_sectionHeaderView_withProgress_showsCount`, `test_sectionHeaderView_noProgress_hidesCount` —
  component snapshots.
- `test_medalBadgeView_locked_isGhosted` — snapshot of the ghosting modifier (light + dark).
- Component snapshots: earned cell chrome, locked cell, section strip, grid skeleton, the three state
  surfaces — **at default + accessibility XXL, light + dark** (renderer-pinned, run on the simulator +
  pre-push, skipped in CI — ADR-0009).

## Test double

- Pure token/asset logic needs no doubles. Snapshot cases render real components with fixture-shaped
  inputs (primitives, not domain types — the module stays domain-agnostic).
