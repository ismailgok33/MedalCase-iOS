# Module: MedalData

**Layer:** Data. **Depends on:** `MedalDomain` only (implements its protocols). **No UI imports.**
Foundation only (for `Bundle`/`JSONDecoder`). This is the seam a remote source would plug into
(ADR-0004) — nothing here reaches across the arrows.

## Public surface

**Only `DefaultAchievementsRepository` is public** — minimal surface area (CLAUDE.md). The App injects
it as an `any AchievementsRepository`; everything else (the data source, mapper, and DTOs) is `internal`
plumbing, so a DTO can never leak past the module boundary by construction.

- `public struct DefaultAchievementsRepository: AchievementsRepository` —
  `public init(languageCode: @escaping @Sendable () -> String = { "en" })` wires the production
  defaults (bundled fixture + mapper). The provider is read **per call** and selects the per-language
  payload variant (ADR-0013) — the composition root passes the in-app language, so a language switch
  followed by a re-fetch serves the new language's document. An **internal** `init(dataSource:mapper:)`
  is the DI seam for tests (`@testable`) and a future remote source.
  `func achievements() async throws -> AchievementsCase` reads the data source, maps DTO → domain, and
  surfaces a typed `MedalError`.

Internal collaborators (reached by tests via `@testable`):
- `protocol AchievementsDataSource: Sendable` — `func load() async throws -> AchievementsDocumentDTO`.
  The abstraction over "where bytes come from"; a remote client would be added inside this package.
- `struct BundledAchievementsDataSource: AchievementsDataSource` —
  `init(bundle: Bundle = .module, resource: String = "achievements")`; `load()` reads the packaged
  document (→ `MedalError.emptyData` if missing) and calls the pure `static decode(_:)`, which maps
  any `DecodingError` → `MedalError.decoding` (P1). A second `init(bundle:languageCode:)` selects the
  payload variant via the pure `static resourceName(forLanguageCode:)` — any `fr*` tag →
  `achievements-fr`, anything else the base `achievements` (ADR-0013).
- `struct AchievementMapper: Sendable` — `func map(_ dto:) -> AchievementsCase` (**non-throwing**: every
  semantic policy P2–P8 degrades gracefully; the only failure, P1, is a *decode* concern handled before
  the mapper ever runs). Where the landmines resolve.

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

The canonical `tech_specs/data/achievements.json` **and its French variant `achievements-fr.json`**
(ADR-0013) are copied into `Sources/MedalData/Resources/` and declared as SPM resources
(`.process("Resources")`). `test_bundledResource_matchesCanonicalFixture` decodes the packaged copy
and asserts the canonical content (2 sections, 6+6 medals, the locked Marathon, the 1387 s 5K);
`test_fixtures_frenchMirrorsEnglishStructure` holds the two variants structurally identical (section
ids, medal ids/order, types, statuses, values, asset keys — only display text may differ), so a
language switch can never change *what* is shown, only *how it reads*;
`test_bundledFrenchResource_matchesCanonicalFixture` pins the packaged FR copy to the canonical
content the same way the EN pin does. Brand race names (the Ekidens) stay verbatim in FR —
`test_fixtures_brandRaceNamesStayVerbatimInFrench`.

## done = these tests

- `test_dto_decodesCanonicalFixture` — the fixture shape decodes; snake_case keys (`shows_progress_count`,
  `asset_key`) and the 23:07 value (1387 s, minutesSeconds) survive round-trip.
- `test_decode_malformedJSON_throwsDecoding` (P1) — garbage bytes → `MedalError.decoding`, not raw
  `DecodingError`. (P1 lives at the *decode* step, not the mapper — the mapper only sees valid DTOs.)
- `test_decode_missingRequiredKey_throwsDecoding` (P1) — structurally wrong JSON (no `sections`).
- `test_mapper_unknownType_keepsMedal` (P2).
- `test_mapper_unknownValueKind_mapsToEarnedNil` + `test_mapper_durationMissingStyle_mapsToEarnedNil` (P3).
- `test_mapper_unknownStatus_treatsAsLocked` (P4).
- `test_mapper_lockedWithValue_dropsValue` (P6).
- `test_mapper_duplicateIds_keepsFirst` + `test_mapper_duplicateSectionIds_keepsFirst` (P7).
- `test_mapper_negativeValues_clampToZero` + `test_mapper_negativeElevation_clampToZero` (P8).
- `test_mapper_emptyDocument_producesEmptyCaseWithoutThrowing` (R2.3).
- `test_repository_load_mapsBundledFixtureToDomain` — `DefaultAchievementsRepository` end-to-end over
  `BundledAchievementsDataSource`: "5 of 6" PRs, locked Marathon, 6 races.
- `test_repository_dataSourceThrows_surfacesMedalError` — via `MockAchievementsDataSource`.
- `test_bundledResource_matchesCanonicalFixture` — packaged copy decodes to the canonical content.
- `test_resourceName_frenchTags_selectFrenchVariant` + `test_resourceName_otherTags_fallBackToBaseDocument`
  (ADR-0013) — the pure payload-variant selection rule.
- `test_repository_frenchLanguage_servesFrenchTitles` + `test_repository_unsupportedLanguage_servesEnglishTitles`
  (ADR-0013) — end-to-end language selection through the public init.
- `test_fixtures_frenchMirrorsEnglishStructure` + `test_fixtures_brandRaceNamesStayVerbatimInFrench`
  (ADR-0013) — the FR variant's structural-parity (ids, types, statuses, values, asset keys) and
  brand-name invariants.
- `test_bundledFrenchResource_matchesCanonicalFixture` (ADR-0013) — the FR analog of the EN
  canonical pin: the packaged French copy matches the canonical fixture's content.

## Test doubles

- `MockAchievementsDataSource` (dedicated file, `Tests/MedalDataTests/Doubles/`) — stubbable
  DTO/throw, for repository tests without touching the bundle. The shared `MockAchievementsRepository`
  (domain-level) lives in `MedalTestSupport` for feature tests, not here.
