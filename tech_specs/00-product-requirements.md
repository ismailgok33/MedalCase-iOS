# 00 — Product Requirements

MedalCase renders the Runkeeper **Achievements medal case**: a sectioned 2-column grid of earned
and locked medals. Requirements use **EARS** (Easy Approach to Requirements Syntax); each has
acceptance criteria and the tests that prove it. Platform-agnostic — iOS is one rendering; the
contract ports to Kotlin/Compose unchanged.

## Actors & data

- **User** — views their achievements. No editing; the overflow menu offers demo-only actions.
- **Achievements data** — a JSON document *we* define (the brief supplies only a mock — defining
  the contract is itself a documented decision, [ADR-0004](adr/0004-bundled-data-repository-seam.md)),
  shaped as a server would send it: ordered sections of medals. Bundled as a fixture; the async
  repository seam is where a remote source would plug in. Canonical fixture:
  [`data/achievements.json`](data/achievements.json), contract:
  [`02-data-contract.md`](02-data-contract.md).

## Requirements

### R1 — Achievements grid

- **R1.1 (Ubiquitous)** The system shall display every section from the data source, in data order.
- **R1.2 (Ubiquitous)** Each section shall render a header strip with its title; a section that
  declares a progress count shall show right-aligned "N of M", where **N = earned medals and
  M = all medals in that section, both computed from data** ([ADR-0008](adr/0008-data-driven-counts.md)).
- **R1.3 (Ubiquitous)** Each section's medals shall render in a two-column grid, preserving data order.
- **R1.4 (Ubiquitous)** Each medal cell shall show its vector badge, title, and value line
  ([ADR-0006](adr/0006-vector-asset-pipeline.md)).
- **R1.5 (State)** While a medal is locked, its cell shall render the badge ghosted (derived from
  the earned asset — [ADR-0007](adr/0007-locked-medal-rendering.md)) with the localized value
  "Not Yet".
- **R1.6 (Ubiquitous)** The screen shall render Runkeeper-style chrome: a teal navigation bar
  titled "Achievements", a back affordance, and an overflow menu hosting demo actions
  (toggle the Marathon medal's earned state; reset fixture data) so the chrome is functional,
  not painted.

*Acceptance (R1.2):* Given the fixture (5 earned + 1 locked personal records), when the grid
renders, then the Personal Records header reads "5 of 6"; given data with 4 earned, it reads
"4 of 6". *(The mock's own "4 of 6" annotation is unsatisfiable against its 5 colored cells —
see the landmine table in [`02-data-contract.md`](02-data-contract.md) and ADR-0008.)*
*Acceptance (R1.5):* Given the locked Marathon, when the grid renders, then its badge is
desaturated/ghosted and its value line reads "Not Yet".

*done =* `test_achievementsViewModel_loadSuccess_preservesSectionAndMedalOrder`,
`test_achievementsSection_progressCount_countsOnlyEarned`,
`test_achievementsSection_progressCount_hiddenWhenNotDeclared`,
`test_medalCell_locked_showsNotYet` (unit + snapshot), snapshot `achievements-grid-light`.

### R2 — Screen states

- **R2.1 (State)** While achievements are loading, the system shall show a loading state.
- **R2.2 (Unwanted)** If the load fails, the system shall show an error state with a localized
  message and a Retry action that re-runs the load. No raw error text; no silent failure.
- **R2.3 (Unwanted)** If the data source returns zero sections (or only empty sections), the
  system shall show an empty state.
- **R2.4 (Event)** When the load succeeds with content, the system shall show the grid (R1).

*done =* `test_achievementsViewModel_loadSuccess_setsLoaded`,
`test_achievementsViewModel_loadFailure_setsErrorWithRetry`,
`test_achievementsViewModel_loadEmpty_setsEmpty`,
`test_achievementsViewModel_retry_reloadsAfterFailure`.

### R3 — Value formatting ([ADR-0010](adr/0010-value-formatting.md))

- **R3.1 (Ubiquitous)** A duration with style `minutes_seconds` shall format as `MM:SS`
  (0 → "00:00"; 1387 s → "23:07").
- **R3.2 (Ubiquitous)** A duration with style `hours_minutes_seconds` shall format as `HH:MM:SS`
  (0 → "00:00:00").
- **R3.3 (Ubiquitous)** An elevation shall format as whole feet + localized unit ("2095 ft" —
  mock-exact, no digit grouping; the production-localization trade-off is documented in ADR-0010).
- **R3.4 (Ubiquitous)** A locked medal's value line shall be the localized "Not Yet".

*done =* `test_medalValueFormatter_minutesSeconds_zero`,
`test_medalValueFormatter_minutesSeconds_nonZero`,
`test_medalValueFormatter_hoursMinutesSeconds_zero`,
`test_medalValueFormatter_elevation_wholeFeet`, `test_medalValueFormatter_locked_notYet`.

### R4 — Accessibility ([`accessibility.md`](accessibility.md))

- **R4.1 (Ubiquitous)** Each medal cell shall be **one** accessibility element labeled
  "«title», «value»" (earned) or "«title», not yet earned" (locked).
- **R4.2 (Ubiquitous)** Section headers shall carry the VoiceOver heading trait; a progress count
  shall be announced as "N of M earned".
- **R4.3 (Ubiquitous)** All UI shall support Dynamic Type to accessibility XXL without truncation
  (including "Tokyo-Hakone Ekiden 2020"); the grid may reflow to fewer columns at accessibility sizes.
- **R4.4 (Ubiquitous)** All user-facing *chrome/state* strings shall come from the String Catalog;
  medal titles/section titles come from data (server-localized in production — noted in
  [`02-data-contract.md`](02-data-contract.md)).

*done =* `test_medalCell_accessibilityLabel_earned`, `test_medalCell_accessibilityLabel_locked`,
`test_sectionHeader_isAccessibilityHeading`, snapshot `achievements-grid-xxl`.

### R5 — Performance & battery ([`performance-battery.md`](performance-battery.md); CLAUDE.md rule 8)

- **R5.1 (Ubiquitous)** After its single load, the screen shall perform no ongoing work — no
  timers, polling, or background tasks.
- **R5.2 (Ubiquitous)** Grid cells shall materialize lazily (offscreen cells are not built).
- **R5.3 (Ubiquitous)** Badges shall be decoded once at display size via the asset catalog — no
  runtime PDF re-rasterization, no oversized decodes.

*done =* `/ios-review` performance checklist (every PR) + the M7 Instruments pass recorded in the
README with measured numbers.

## Grading-coverage matrix

| Brief criterion | Satisfied by | Where |
|---|---|---|
| Grid-view medal case matching the mock | sectioned `LazyVGrid` + tokens from the annotated mock | R1 · DesignSystem |
| Vector assets used as vectors | asset catalog, Single Scale + Preserve Vector Data | ADR-0006 |
| Colors/fonts per annotation | DesignSystem tokens (single source) | `01-architecture.md` |
| "Well written code … extra mile" | constitution + modular SPM + TDD + gates | CLAUDE.md |
| "Points of discussion" | ADR set + landmine resolutions | `adr/` · `02-data-contract.md` |
| ≤ 8h + "what I'd do with more time" | milestone budget + README roadmap | `docs/EXECUTION_PLAN.md` |
| Fitness-app care (Runkeeper team) | battery rule, units, a11y, server-shaped data | R3–R5 |
