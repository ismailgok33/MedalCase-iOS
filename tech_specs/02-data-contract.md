# 02 — Data Contract

The brief supplies a mock, not a feed. **We define the contract** — shaped as a server would send
it (Runkeeper's medal case is server-fed), bundled as a fixture, decoded through explicit DTOs and
mapped into domain types with typed policies. Canonical fixture:
[`data/achievements.json`](data/achievements.json) (mirrored into `MedalData` package resources in
M4 — a test asserts the bundled copy decodes identically).

## Shape

```jsonc
{
  "schemaVersion": 1,
  "sections": [
    {
      "id": "personal_records",          // stable, unique
      "title": "Personal Records",       // display string (server-localized in production)
      "shows_progress_count": true,      // header renders "N of M" (computed — ADR-0008)
      "medals": [
        {
          "id": "pr_fastest_5k",         // stable, unique across the document
          "type": "fastest_5k",          // semantic identity — opaque to rendering
          "title": "Fastest 5K",         // display string, verbatim (mock-exact, incl. plain "10K")
          "asset_key": "pr_fastest_5k",  // typed lookup into the DesignSystem medal catalog
          "status": "earned",            // "earned" | "locked"
          "value": {                     // ABSENT when locked
            "kind": "duration",          // "duration" | "elevation"
            "seconds": 0,                // duration only
            "style": "minutes_seconds",  // duration only: "minutes_seconds" | "hours_minutes_seconds"
            "feet": 2095                 // elevation only
          }
        }
      ]
    }
  ]
}
```

Display order = array order, both for sections and medals (R1.1/R1.3). JSON keys are snake_case
with explicit `CodingKeys` (no `keyDecodingStrategy` magic).

## Decode & mapping policies (each is a test)

| # | Condition | Policy | Rationale |
|---|---|---|---|
| P1 | Malformed JSON / wrong structural shape (missing `id`/`title`/`status`, non-array `sections`) | throw `MedalError.decoding` → error state (R2.2) | contract violation is a bug, not content |
| P2 | Unknown `type` string | **keep the medal** — `type` is opaque to rendering | forward compatibility: server ships new medal types; old clients must not break (the real Runkeeper concern) |
| P3 | Unknown `value.kind` | treat value as absent — earned cell renders without a value line, medal stays visible | degrade gracefully; never hide an earned medal over a formatting gap |
| P4 | Unknown `status` string | treat as `locked` | conservative: never celebrate an unearned medal |
| P5 | Unknown `asset_key` (no catalog match) | render the DesignSystem placeholder badge, keep the cell | a medal with title+value but generic art beats an absent medal |
| P6 | `status: "locked"` with a `value` present | ignore the value; render "Not Yet" | locked wins — status is authoritative |
| P7 | Duplicate `id` | keep first occurrence, drop later ones | stable `Identifiable` for SwiftUI diffing |
| P8 | Negative `seconds`/`feet` | clamp to 0 | display data, not math input |

## The landmine table (mock inconsistencies → normative resolutions)

| # | Landmine | Resolution |
|---|---|---|
| L1 | Header annotated **"4 of 6"**, but **5** PR cells render colored; only Marathon is ghosted | The two facts are mutually unsatisfiable. **Visual states win**: the fixture mirrors 5 earned + 1 locked, and the computed header renders **"5 of 6"** ([ADR-0008](adr/0008-data-driven-counts.md)). The count is never hardcoded — data saying 4 earned renders "4 of 6". Documented in the README as a found-and-resolved brief inconsistency |
| L2 | Mixed value formats: `00:00`, `00:00:00`, `23:07`, `2095 ft` | Typed `value` union + a data-carried duration `style`; one `MedalValueFormatter` renders mock-exact output ([ADR-0010](adr/0010-value-formatting.md)) |
| L3 | No locked-variant asset for Marathon | Locked rendering derived from the earned asset (desaturate + reduce opacity) — one asset, both states ([ADR-0007](adr/0007-locked-medal-rendering.md)) |
| L4 | 7 virtual-race assets supplied, 6 in the mock | Grid is data-driven; `virtual_marathon_race` stays in the catalog unreferenced by the fixture — proof cells aren't hardcoded |
| L5 | Asset filename chaos (`tokyo-hakone-ekiden-2020` hyphens vs snake_case; Android twin's `kakone` typo) | Catalog names normalized to `pr_*` / `race_*`; `asset_key` is the single mapping surface (P5) |
| L6 | The 10K cell is titled just "10K" (not "Fastest 10K") | Titles render verbatim from data — mock-exact |
| L7 | Back chevron + "⋮" on a single-screen app | Real chrome: `NavigationStack`, functional overflow demo menu (R1.6) |
| L8 | Mock fonts annotated in px | pt 1:1, exposed as Dynamic-Type-relative fonts (`relativeTo:`) — never fixed sizes |

## Content localization (ADR-0013)

Display text in the payload (`title` at both levels) is **content**, localized by the *server* in
production (the Accept-Language pattern) — never by client string tables, because content is unbounded
(new virtual races ship server-side without an app release) and often branded (Ekiden race names are
not translated at all). The bundled source demonstrates this: it ships **per-language document
variants** — `achievements.json` (EN, base) and `achievements-fr.json` — and selects by the requested
language (`fr*` → the FR document; anything else → base). Invariants:

- The variants are **structurally identical**: same section ids, medal ids/order, statuses, values,
  asset keys. Only display text may differ. Enforced by `test_fixtures_frenchMirrorsEnglishStructure`.
- Brand race names stay verbatim across languages (`test_fixtures_brandRaceNamesStayVerbatimInFrench`).
- The schema (including `schemaVersion`) is identical — a variant is a translation, never a fork.
- On an in-app language switch the client **re-fetches** (the analog of re-requesting with a new
  Accept-Language); ids stay stable so view identity survives the swap.

## Fixture content (mock-exact)

**personal_records** (`shows_progress_count: true`): Longest Run `00:00` (mm:ss) · Highest
Elevation `2095 ft` · Fastest 5K `00:00` (mm:ss) · 10K `00:00:00` (hh:mm:ss) · Half Marathon
`00:00` (mm:ss) · Marathon **locked**.
**virtual_races** (`shows_progress_count: false`): Virtual Half Marathon Race `00:00` (mm:ss) ·
Tokyo-Hakone Ekiden 2020 `00:00:00` · Virtual 10K Race `00:00:00` · Hakone Ekiden `00:00:00` ·
Mizuno Singapore Ekiden 2015 `00:00:00` · Virtual 5K Race `23:07` (mm:ss, 1387 s).

*done =* (implemented in M4 — see [`modules/medal-data.md`](modules/medal-data.md) for the authoritative
list) `test_dto_decodesCanonicalFixture`, `test_decode_malformedJSON_throwsDecoding` +
`test_decode_missingRequiredKey_throwsDecoding` (P1, at the decode step — the mapper is total),
`test_mapper_unknownType_keepsMedal` (P2), `test_mapper_unknownValueKind_mapsToEarnedNil` +
`test_mapper_durationMissingStyle_mapsToEarnedNil` (P3), `test_mapper_unknownStatus_treatsAsLocked` (P4),
`test_mapper_lockedWithValue_dropsValue` (P6), `test_mapper_duplicateIds_keepsFirst` +
`test_mapper_duplicateSectionIds_keepsFirst` (P7), `test_mapper_negativeValues_clampToZero` +
`test_mapper_negativeElevation_clampToZero` (P8), `test_bundledResource_matchesCanonicalFixture`.
