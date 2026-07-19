# Module: MedalDomain

**Layer:** Domain. **Depends on:** nothing (no SwiftUI, no UIKit, no Foundation networking, no other
module). Pure Swift. Ports to Kotlin unchanged.

## Public surface

- `struct AchievementsCase: Equatable, Sendable` — the whole medal case: `sections: [AchievementSection]`.
- `struct AchievementSection: Identifiable, Equatable, Sendable` — `id: String`, `title: String`,
  `showsProgressCount: Bool`, `medals: [Achievement]`. Computed: `earnedCount: Int` (medals whose
  status is `.earned`), `totalCount: Int` (`medals.count`). **The count is derived here, never stored**
  (ADR-0008).
- `struct Achievement: Identifiable, Equatable, Sendable` — `id: String`, `type: String` (opaque
  semantic key), `title: String`, `assetKey: String`, `status: AchievementStatus`.
  Computed: `isEarned: Bool`.
- `enum AchievementStatus: Equatable, Sendable` — `earned(MedalValue?)` | `locked`. (A locked medal
  carries no value; an earned medal may carry `nil` when the feed omits/garbles it — policy P3.)
- `enum MedalValue: Equatable, Sendable` — `duration(seconds: Int, style: DurationStyle)` |
  `elevation(feet: Int)`.
- `enum DurationStyle: Equatable, Sendable` — `minutesSeconds` | `hoursMinutesSeconds`.
- `enum MedalError: Error, Equatable, Sendable` — `decoding`, `emptyData`, `unknown`. (No transport
  cases — no networking layer, ADR-0004; added the day a remote source is.)
- `protocol AchievementsRepository: Sendable` — `func achievements() async throws -> AchievementsCase`.
- `enum MedalValueFormatter` — pure static rendering:
  `func string(for value: MedalValue?) -> String?` and `func lockedPlaceholder() -> String`
  returning locale-independent, mock-exact strings (the localized swap is a presentation concern —
  the feature maps to catalog keys; see the note below).

## Behavior

- `MedalValueFormatter` (ADR-0010, R3): `minutesSeconds` → `MM:SS` (zero-padded, minutes may exceed
  99); `hoursMinutesSeconds` → `HH:MM:SS`; `elevation` → `"<feet> ft"` (no digit grouping, mock-exact);
  `nil` value → `nil` (no value line, policy P3). Negative inputs are treated as 0 (the mapper clamps
  at the boundary — P8 — but the formatter is total and never traps).
- `AchievementSection.earnedCount`/`totalCount` are the single source for the header's "N of M" — the
  UI reads them, never recomputes (ADR-0008).
- Identity: `id`s come from the contract (unique per document, dedup is the mapper's job — P7); the
  domain assumes they are already unique and stable for `Identifiable`.

## Localization boundary

`MedalValueFormatter` returns raw glyphs (`23:07`, `2095 ft`) — these are numeric renderings, not
prose. The **"Not Yet"** locked label is a *user-facing string* and therefore lives in the String
Catalog (feature layer, R4.4), NOT here — `lockedPlaceholder()` exists only so pure tests can assert
the non-localized default. Views use the catalog key.

## done = these tests

- `test_medalValueFormatter_minutesSeconds_zero` — `duration(0, .minutesSeconds)` → `"00:00"`.
- `test_medalValueFormatter_minutesSeconds_nonZero` — `duration(1387, .minutesSeconds)` → `"23:07"`.
- `test_medalValueFormatter_hoursMinutesSeconds_zero` — `duration(0, .hoursMinutesSeconds)` → `"00:00:00"`.
- `test_medalValueFormatter_elevation_wholeFeet` — `elevation(2095)` → `"2095 ft"`.
- `test_medalValueFormatter_nilValue_returnsNil` — `nil` → `nil` (P3).
- `test_medalValueFormatter_negativeSeconds_treatedAsZero` — totality guard.
- `test_achievementSection_earnedCount_countsOnlyEarned` — 5 earned + 1 locked → `earnedCount == 5`,
  `totalCount == 6`.
- `test_achievement_isEarned_reflectsStatus`.

## Test double

- `StubAchievementsRepository` — a dedicated double in `Tests/MedalDomainTests/Doubles/` (call spy +
  stubbable result/error). MedalDomain's own tests use a **local** double, not the shared
  `MedalTestSupport`, to avoid a package cycle (`MedalTestSupport` depends on `MedalDomain`). The shared
  `MockAchievementsRepository` lives in `MedalTestSupport` for downstream consumers.
