# Expected output shape — /scaffold-module MedalDomain

A passing scaffold produces (the judge scores the real generated module against this + the rubric):

- `Modules/MedalDomain/Package.swift` — `swift-tools-version: 6.0`, platforms iOS 17 + macOS 14 (host
  test loop), **zero dependencies**, one library target + one test target.
- One type per file under `Sources/MedalDomain/`: `AchievementsCase`, `AchievementSection`,
  `Achievement`, `AchievementStatus`, `MedalValue`, `DurationStyle`, `MedalError`,
  `AchievementsRepository`, `MedalValueFormatter`.
- **No `import` statements** anywhere in `Sources/` — the formatter zero-pads manually rather than using
  `String(format:)` (which would pull in Foundation).
- `Tests/MedalDomainTests/` with the `done =` tests, and a **local** `Doubles/StubAchievementsRepository`
  (NOT `MedalTestSupport`) — so no package cycle.
- Computed `earnedCount`/`totalCount`/`hasNoMedals`/`isEarned` — derived, never stored.
- `swift test --package-path Modules/MedalDomain` is green.

Anti-patterns that must lose points: any `import` in `Sources/`; `String(format:)`; wiring
`MedalTestSupport` into the domain test target (cycle); stored counts; force-unwraps; a public type with
no spec entry.
