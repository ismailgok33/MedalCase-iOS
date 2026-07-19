# Module: MedalData

**Layer:** Data. **Depends on:** `MedalDomain` only (implements its protocols). **No UI imports.**
Foundation only (for `Bundle`/`JSONDecoder`). This is the seam a remote source would plug into
(ADR-0004) — nothing here reaches across the arrows.

## Public surface

- `struct DefaultAchievementsRepository: AchievementsRepository, Sendable` —
  `init(dataSource: AchievementsDataSource, mapper: AchievementMapper = .init())`,
  `func achievements() async throws -> AchievementsCase`. Reads the data source, maps DTO → domain,
  surfaces a typed `MedalError`. The one production `AchievementsRepository`.
- `protocol AchievementsDataSource: Sendable` — `func load() async throws -> AchievementsDocumentDTO`.
  The abstraction over "where bytes come from"; today only the bundle, tomorrow a network client.
- `struct BundledAchievementsDataSource: AchievementsDataSource, Sendable` —
  `init(bundle: Bundle = .module, resource: String = "achievements")`. Loads the packaged
  `achievements.json` resource, decodes to the DTO. Throws `MedalError.decoding` on malformed JSON,
  `MedalError.emptyData` on a missing resource.
- `struct AchievementMapper: Sendable` — `func map(_ dto: AchievementsDocumentDTO) throws ->
  AchievementsCase`. Applies every decode/mapping policy (P1–P8) and is where the landmines resolve.

## DTOs (internal — never leak past the mapper)

`AchievementsDocumentDTO`, `SectionDTO`, `MedalDTO`, `MedalValueDTO` — `Decodable` with **explicit
`CodingKeys`** (snake_case → camelCase; no `keyDecodingStrategy`). `MedalValueDTO` decodes the tagged
union (`kind` = `duration`/`elevation`, with `seconds`/`style`/`feet`). Structural violations throw at
decode; semantic policies apply in the mapper.

## Mapping policies (02-data-contract.md → behavior)

| # | Rule | Implementation |
|---|---|---|
| P1 | malformed / wrong shape | decode throws → `MedalError.decoding` |
| P2 | unknown `type` | pass through — `type` is an opaque `String`, never switched on |
| P3 | unknown `value.kind` | map to `earned(nil)` — keep the medal, drop the value line |
| P4 | unknown `status` | map to `.locked` (conservative) |
| P5 | unknown `assetKey` | pass through — DesignSystem resolves to placeholder, not the mapper's job |
| P6 | `locked` + value present | `.locked` (drop the value) |
| P7 | duplicate `id` (section or medal) | keep first, drop later — stable `Identifiable` |
| P8 | negative `seconds`/`feet` | clamp to 0 |

- Empty document (zero sections, or every section empty) maps to an `AchievementsCase` with no
  renderable medals → the feature shows the empty state (R2.3). The mapper does not throw on emptiness;
  emptiness is a valid state, not an error.

## Resources

The canonical `tech_specs/data/achievements.json` is copied into `Sources/MedalData/Resources/` and
declared as an SPM resource. A test asserts the packaged copy is byte-for-byte decodable and
content-identical to the canonical fixture, so the two never silently diverge.

## done = these tests

- `test_dto_decodesCanonicalFixture` — the real fixture decodes; section/medal counts + the 23:07 5K
  (1387 s, minutesSeconds) survive round-trip.
- `test_mapper_malformedStructure_throwsDecoding` (P1).
- `test_mapper_unknownType_keepsMedal` (P2).
- `test_mapper_unknownValueKind_mapsToEarnedNil` (P3).
- `test_mapper_unknownStatus_treatsAsLocked` (P4).
- `test_mapper_lockedWithValue_dropsValue` (P6).
- `test_mapper_duplicateIds_keepsFirst` (P7).
- `test_mapper_negativeValues_clampToZero` (P8).
- `test_mapper_emptyDocument_producesEmptyCaseWithoutThrowing` (R2.3).
- `test_repository_load_mapsBundledFixtureToDomain` — `DefaultAchievementsRepository` end-to-end over
  `BundledAchievementsDataSource`: "5 of 6" PRs, locked Marathon, 6 races.
- `test_repository_dataSourceThrows_surfacesMedalError` — via `MockAchievementsDataSource`.
- `test_bundledResource_matchesCanonicalFixture` — packaged copy ≡ `tech_specs/data/achievements.json`.

## Test doubles

- `MockAchievementsDataSource` (dedicated file, `Tests/MedalDataTests/Doubles/`) — stubbable
  DTO/throw, for repository tests without touching the bundle. The shared `MockAchievementsRepository`
  (domain-level) lives in `MedalTestSupport` for feature tests, not here.
