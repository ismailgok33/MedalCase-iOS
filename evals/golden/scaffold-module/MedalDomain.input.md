# Golden input — /scaffold-module MedalDomain

This is the spec the skill receives (the real `tech_specs/modules/medal-domain.md` contract). The
expected output shape is in `MedalDomain.expected.md`; the judge scores the generated module against
the rubric.

## Module: MedalDomain
Pure-Swift domain layer. **Depends on: nothing** — no SwiftUI, no UIKit, no Foundation, no other module.
Must render to Kotlin unchanged.

### Public surface
- `struct AchievementsCase: Equatable, Sendable` — `sections: [AchievementSection]`, computed `hasNoMedals`.
- `struct AchievementSection: Identifiable, Equatable, Sendable` — `id`, `title`, `showsProgressCount`,
  `medals`, computed `earnedCount` / `totalCount` (never stored — ADR-0008).
- `struct Achievement: Identifiable, Equatable, Sendable` — `id`, `type`, `title`, `assetKey`, `status`,
  computed `isEarned`.
- `enum AchievementStatus: Equatable, Sendable` — `earned(MedalValue?)` | `locked`.
- `enum MedalValue: Equatable, Sendable` — `duration(seconds:style:)` | `elevation(feet:)`.
- `enum DurationStyle` — `minutesSeconds` | `hoursMinutesSeconds`.
- `enum MedalError: Error, Equatable, Sendable` — `decoding`, `emptyData`, `unknown`.
- `protocol AchievementsRepository: Sendable` — `func achievements() async throws -> AchievementsCase`.
- `enum MedalValueFormatter` — pure `string(for:) -> String?` (mock-exact; **no Foundation** — manual pad).

### done = these tests
- `test_medalValueFormatter_minutesSeconds_zero` / `_nonZero` / `_hoursMinutesSeconds_zero` /
  `_elevation_wholeFeet` / `_nilValue_returnsNil` / `_negativeSeconds_treatedAsZero`
- `test_achievementSection_earnedCount_countsOnlyEarned`
- `test_achievement_isEarned_reflectsStatus`
- `test_achievementsCase_hasNoMedals_reflectsEmptiness`

### Constraint that makes this discriminating
`MedalDomain`'s own tests must use a **local** double (in `Tests/MedalDomainTests/Doubles/`), NOT the
shared `MedalTestSupport` mock — because `MedalTestSupport` depends on `MedalDomain`, so importing it
into the domain's test target would create a `MedalDomain ↔ MedalTestSupport` package cycle. A scaffold
that wires `MedalTestSupport` into the domain test target must be penalized on the dependency rule.
