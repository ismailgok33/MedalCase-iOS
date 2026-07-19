# 01 — Architecture

Multi-package local SPM with an **inward-pointing dependency rule enforced by the package graph**
([ADR-0003](adr/0003-multi-package-spm.md)). Only the AI workflow is inherited from prior work —
every structure here is justified by this brief + the Runkeeper context (pods own packages;
boundaries make cross-pod conflicts structural, not social).

## Module graph

```
                 ┌─────────────────────┐
                 │   MedalCase (App)   │   composition root; nav appearance; DI wiring
                 └────────┬────────────┘
                          │
              ┌───────────▼───────────┐
              │  AchievementsFeature  │   screen: ViewModel + views
              └─────┬───────────┬─────┘
                    │           │
          ┌─────────▼───┐   ┌───▼──────────┐
          │ MedalDomain │◄──│   MedalData  │   Data implements Domain's protocols
          └─────────────┘   └──────────────┘
                    ▲
          ┌─────────┴───┐   ┌──────────────────┐
          │ DesignSystem │   │ MedalTestSupport │   (test-only: mocks + fixtures)
          └─────────────┘   └──────────────────┘
```

Arrows = "may import". `MedalDomain` imports **nothing**. `AchievementsFeature` imports
`MedalDomain` + `DesignSystem` only. `MedalData` imports `MedalDomain` only. `DesignSystem`
imports SwiftUI only — never domain or data. The App target imports everything (it is the one
place allowed to see concretes: standard composition-root exemption).

## Package responsibilities

| Package | Contents | Key constraint |
|---|---|---|
| **MedalDomain** | `Achievement`, `AchievementSection`, `AchievementsCase`, `AchievementStatus`, `MedalValue`, `MedalValueFormatter`, `MedalError`, `AchievementsRepository` (protocol) | pure Swift; zero imports |
| **MedalData** | DTOs + explicit `CodingKeys`, `AchievementMapper` (contract policies → typed errors), `BundledAchievementsDataSource`, `DefaultAchievementsRepository` | implements domain protocols; no UI |
| **DesignSystem** | color/typography/spacing tokens (the mock's hexes live **only** here), `MedalAsset` typed catalog, `SectionHeaderView`, `ViewState` + state views, ghosted-badge modifier | no domain/data imports |
| **AchievementsFeature** | `AchievementsViewModel` (`@Observable @MainActor`, `ViewState<AchievementsCase>`), `AchievementsView` (ScrollView + `LazyVGrid`), `MedalCellView` | domain + design system only |
| **MedalTestSupport** | `MockAchievementsRepository` (spy + stubbable), `AchievementFixtures` from the real fixture JSON | test targets only |
| **App target** | `MedalCaseApp`, `RootView` composition root (repository injection + `NavigationStack`) | thin; no logic; depends on `MedalData` + `AchievementsFeature` (+ `MedalDomain`), **not `DesignSystem` directly** — ADR-0011 |

Per-module contracts (public surface, dependencies, edge cases, `done = these tests`) live in
[`modules/`](modules/): [medal-domain](modules/medal-domain.md) · [design-system](modules/design-system.md)
· [medal-data](modules/medal-data.md) · [achievements-feature](modules/achievements-feature.md) ·
[medal-test-support](modules/medal-test-support.md). They are the build order for M3–M5.

## Decisions that shape the graph

- **Async repository seam, no networking stack ([ADR-0004](adr/0004-bundled-data-repository-seam.md)).**
  `AchievementsRepository.achievements()` is `async throws` because that is the *real* contract —
  Runkeeper's medal case is server-fed. Today the only implementation reads the bundled fixture;
  a remote implementation would touch `MedalData` + the composition root and nothing else. No
  caching tiers, no HTTP client — this brief doesn't earn them.
- **No use-case layer.** The ViewModel depends on `AchievementsRepository` directly. With one read
  operation and no business orchestration, a use case would be a pass-through; the protocol *is*
  the seam. (A deliberate leanness lesson — add the layer when a second operation or a real policy
  appears, not before.)
- **ViewState pattern.** Every async screen drives `ViewState<T>`:
  `loading / loaded(T) / empty / error(UserFacingError)` — rendered by dumb state views from
  DesignSystem. `MedalError → UserFacingError` mapping happens in the feature (policy lives with
  the feature; rendering with the design system).
- **Concurrency model.** ViewModels and views are `@MainActor`; every crossing type is `Sendable`
  value semantics; the repository is an async boundary. No shared mutable state → no actors needed
  (and none added speculatively).
- **Observability seam.** The composition root is where MetricKit subscription + crash reporting
  would attach (release-monitoring — see [`performance-battery.md`](performance-battery.md)).
  Not implemented in the 8h scope; the seam is named so the wiring cost is one file.
