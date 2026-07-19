# MedalCase — Execution Plan (Spec-Driven AI-DLC)

> The build roadmap for the Runkeeper **Medal Case** take-home. This repo is built the same way
> [LocalSakeShop](../../..//LocalSakeShop) was: through a committed, spec-driven agentic pipeline —
> **Govern → Specify → Decompose → Construct → Verify → Document** — where `tech_specs/` are
> authoritative and code is generated *from* them. This document is the plan; once M0–M1 land,
> `CLAUDE.md` + `tech_specs/` take over as the source of truth.

---

## 1. The brief, decoded

**Task:** build the Runkeeper "Achievements" medal-case screen — a 2-column grid with two sections
(**Personal Records**, **Virtual Races**) under a teal navigation bar. iPhone → **Swift** required.
Vector **PDF assets** provided and must be used as vectors. Time cap: **≤ 8 hours**, with an explicit
invitation to document "what I'd do with more time." The deliverable feeds a technical interview.

**Grading signals (stated + implied):**

| Signal | Source | How we answer it |
|---|---|---|
| "Well written code… go the extra mile" | brief, verbatim | Constitution-governed code, modular SPM, tests, zero force-unwraps |
| "Points of discussion around technical choices" | brief, verbatim | ADRs + documented landmine decisions (§3) |
| Vector assets used *as vectors* | brief, verbatim | Asset catalog, Single Scale + Preserve Vector Data (ADR) |
| Mock fidelity (colors/fonts annotated) | mock p.3 | Design tokens matching the annotated hexes/sizes |
| It's Runkeeper's *real* feature | brief | Fitness-app lens: battery, units, accessibility, data-driven UI (§7) |

**Screen anatomy (from the mock):**

- Nav bar: back chevron · **"Achievements"** (white, 16) · overflow "⋮" — background `#63C6D4`.
- Section header strips (`#F7F7F7` background): left title ("Personal Records" / "Virtual Races"),
  right-aligned progress count on Personal Records only (**"4 of 6"**).
- 2-column grid of medal cells: vector badge on top, title (12, `#000000`), value line under it
  (gray). Personal-record badges are shields; virtual-race medals are Asics hexagons.
- One **locked** state: Marathon renders ghosted with value **"Not Yet"**.

**Design tokens (verify each against mock p.3 during M3):**

| Token | Value | Used for |
|---|---|---|
| `brandTeal` | `#63C6D4` | nav bar background |
| `navTitle` | `#FFFFFF`, 16 | "Achievements" |
| `sectionTitle` | `#333333`, 14 | "Personal Records", "Virtual Races" |
| `sectionCount` | `#666666`, 14 | "4 of 6" |
| `medalTitle` | `#000000`, 12 | cell title |
| `medalValue` | `#666666`, 12 | cell value ("00:00", "2095 ft", "Not Yet") |
| `sectionStrip` | `#F7F7F7` | section header background |
| `surface` | `#FFFFFF` | grid background |

Mock sizes are annotated in px → treat as pt 1:1, exposed as Dynamic-Type-relative fonts
(`.custom(_:size:relativeTo:)`), never fixed.

**Content (fixture data must reproduce this exactly):**

- Personal Records: Longest Run `00:00` · Highest Elevation `2095 ft` · Fastest 5K `00:00` ·
  10K `00:00:00` · Half Marathon `00:00` · Marathon `Not Yet` (locked).
- Virtual Races: Virtual Half Marathon Race `00:00` · Tokyo-Hakone Ekiden 2020 `00:00:00` ·
  Virtual 10K Race `00:00:00` · Hakone Ekiden `00:00:00` · Mizuno Singapore Ekiden 2015 `00:00:00` ·
  Virtual 5K Race `23:07`.

---

## 2. Asset inventory (iOS / PDF vectors)

`personal_records/`: fastest_5k, fastest_10k, fastest_half_marathon, fastest_marathon,
highest_elevation, longest_run — 6 assets ↔ 6 grid slots. ✔

`virtual_races/`: virtual_5k_race, virtual_10k_race, virtual_half_marathon_race,
**virtual_marathon_race**, hakone_ekiden, mizuno_singapore_ekiden, tokyo-hakone-ekiden-2020 —
**7 assets, mock shows 6** (virtual_marathon_race is unused by the mock).

Pipeline: import into `Assets.xcassets` inside the **DesignSystem** package (namespaced folder),
`Individual Scale → Single Scale`, **Preserve Vector Data ON** so badges stay crisp at large
Dynamic Type / iPad sizes. Asset names normalized to a single convention (`medal.pr.fastest5k`,
`medal.race.hakoneEkiden`, …) and referenced through a generated/typed accessor — never string
literals scattered in views.

---

## 3. Landmines in the brief (find → decide → document)

The mock contains deliberate (or sloppy) inconsistencies. Each one becomes a documented decision —
exactly the "points of discussion" the interview wants. Decisions get one line in the README and an
ADR where structural.

| # | Landmine | Decision (recommended) |
|---|---|---|
| L1 | Header says **"4 of 6"** but **5** PR cells render colored with values; only Marathon is "Not Yet" | The count is **computed from data, never hardcoded**. The mock is internally unsatisfiable (5 colored cells can't yield "4 of 6"), so **visual states win**: the fixture mirrors 5 earned + 1 locked and the header renders "5 of 6" (ADR-0008). If product data said 4 earned, it would render "4 of 6" |
| L2 | Value formats are inconsistent: `00:00` (mm:ss), `00:00:00` (hh:mm:ss), `23:07`, `2095 ft` | Model values as a **typed enum** (`duration`, `elevation`, `none`), render via a single `MedalValueFormatter` with an explicit per-medal display style carried in data — mock-exact output, unit-tested |
| L3 | No "locked" variant asset for Marathon | Derive locked rendering from the earned asset: `saturation(0)` + reduced opacity — one asset, both states (ADR) |
| L4 | 7 virtual-race assets vs 6 in mock | Grid is data-driven; the extra asset stays in the catalog unreferenced by fixture. Proves UI doesn't hardcode cells |
| L5 | Filename chaos: `tokyo-hakone-ekiden-2020` (hyphens) vs snake_case others; Android twin has a `kakone` typo | Normalized catalog names + one mapping table in the data layer |
| L6 | "10K" cell is titled just "10K" (not "Fastest 10K") | Titles come from fixture data verbatim — mock-exact |
| L7 | Back chevron + "⋮" on a single-screen app | Render real chrome: screen lives in a `NavigationStack`; overflow menu hosts a functional demo action (e.g. toggle earned states / reset) — shows the chrome is wired, not painted |
| L8 | Fonts annotated in px | pt 1:1 + Dynamic Type relative scaling (see tokens) |

---

## 4. Architecture

Decided on this project's merits — only the AI *workflow* is inherited from LocalSakeShop; no
architecture is carried over that this brief doesn't earn (no stale-while-revalidate, no caching
tiers, no networking stack). The shape: multi-package local SPM with an **inward-pointing
dependency rule enforced by the package graph** — modularity that maps directly to Runkeeper's pod
model (a pod can own a package; cross-pod conflict surface becomes structural, not social):

```
                    ┌────────────────────┐
                    │  MedalCase (App)   │  composition root; nav appearance
                    └───┬────────┬───────┘
                        │        │
        ┌───────────────▼──┐  ┌──▼──────────────┐
        │ AchievementsFeature│  │  (future feature)│   Features → Domain + DesignSystem
        └───┬───────────┬──┘  └─────────────────┘
            │           │
   ┌────────▼───┐   ┌───▼─────────┐
   │ MedalDomain │◄──│  MedalData  │   Data → Domain (implements its protocols)
   └─────────────┘   └─────────────┘
   pure Swift            DTO + mapper + bundled JSON
            ▲
   ┌────────┴────┐   ┌──────────────┐
   │ DesignSystem │   │ MedalTestSupport │  shared mocks/fixtures (test-only)
   └─────────────┘   └──────────────┘
```

**Packages:**

- **MedalDomain** (pure Swift, imports nothing): `Achievement`, `AchievementSection`,
  `AchievementStatus` (`earned(value)` / `locked`), `MedalValue` (typed: duration / elevation),
  `MedalValueFormatter`, `AchievementsCase` (sections + computed `earnedCount/totalCount`),
  `AchievementsRepository` protocol (the seam — deliberately **no** pass-through use-case layer;
  see `tech_specs/01-architecture.md`).
- **MedalData**: `AchievementDTO` + custom decoding, `AchievementMapper` (validation: unknown
  medal type, negative values, malformed durations → typed `MedalError`), `BundledAchievementsDataSource`
  (JSON as package resource), `DefaultAchievementsRepository` (async — the seam where a remote
  source would plug in; see D3).
- **DesignSystem**: color/typography/spacing tokens from §1, medal image catalog + typed accessors,
  `SectionHeaderView`, `ViewState` + state views (reused pattern), locked-medal modifier.
- **AchievementsFeature**: `AchievementsViewModel` (`@Observable @MainActor`,
  `ViewState<AchievementsCase>`), `AchievementsView` (ScrollView + `LazyVGrid`, 2 sections),
  `MedalCellView`. No feature imports another feature; nothing imports MedalData except App.
- **MedalTestSupport**: `MockAchievementsRepository`, `AchievementFixtures` built from the real
  fixture JSON — mocks in dedicated files, never inline.

**App target**: thin composition root (`RootView`) — wires `DefaultAchievementsRepository` into the
feature, hosts the `NavigationStack`, and styles the teal bar via scoped SwiftUI `.toolbarBackground`
(with a high-contrast swap) rather than a global `UINavigationBar.appearance()` mutation.

**Toolchain**: Swift 6, strict concurrency complete, deployment **iOS 17** (needs `@Observable`;
current-minus-two policy, same ADR rationale as LocalSakeShop). Runtime third-party deps: **none**.
Test-only: `swift-snapshot-testing`.

**Why async + ViewState for bundled JSON?** The repository contract is async and fallible because
that is the *real* contract (Runkeeper's medal case is server-fed). Loading/empty/error surfaces are
real code paths (malformed JSON → mapped domain error → error state with Retry), and swapping in a
remote data source later touches only MedalData + the composition root. This is the single best
"discussion point" in the app: production shape, zero speculative code.

**Data contract**: we define `achievements.json` (there is none in the brief — defining one is
itself a documented decision): two arrays (`personalRecords`, `virtualRaces`), each item
`{ id, type, title, asset, status, value? }` with `value` a tagged union. Spec'd in
`tech_specs/02-data-contract.md` with every L1–L6 edge case listed.

---

## 5. The AI-DLC pipeline for this repo

Port the proven LocalSakeShop tooling, retargeted; improve where its known gaps were
(telemetry, golden-set size). **The workflow is the only thing inherited from LocalSakeShop** —
architecture is decided fresh in §4. Phases: **Govern → Specify → Decompose → Construct → Verify →
Document**.

| Artifact | Action | Notes |
|---|---|---|
| `CLAUDE.md` constitution | **Adapt** | Same golden rules (dependency rule, spec-first, one type per file, no force-unwrap, no hardcoded strings/magic values, constructor DI, strict concurrency); module names + medal-case specifics |
| `.claude/skills/` × 8 (`/spec`, `/scaffold-module`, `/tdd`, `/ios-review`, `/pre-commit-review`, `/eval`, `/visual-eval`, `/sync-readme`) | **Port** | Same typed I/O-contract structure; retarget spec references |
| `.claude/agents/` × 5 (`ios-architect`, `swift-module-builder`, `swiftui-component-builder`, `test-author`, `swift-reviewer`) | **Port** | Keep the load-bearing tool scoping: reviewer read-only; test-author separate from builders |
| `.claude/workflows/build-modules.mjs` orchestrator | **Adapt** | New tier map: T1 `MedalDomain ∥ DesignSystem` → T2 `MedalData` → T3 `AchievementsFeature`; same VERDICT_SCHEMA-gated repair loop (MAX_REPAIRS = 2), deterministic routing |
| `evals/` (rubric, thresholds, schema, goldens) | **Adapt + grow** | Goldens: `scaffold-module`(MedalDomain) + visual set (cell, locked cell, XXL, dark, section header) **+ 1 adversarial bad case** — closes the "n=1 golden" gap |
| **Telemetry (NEW)** | **Add** | `telemetry/runs.jsonl` — one structured line per skill/agent run (task, model, duration, verdict, retries). Closes LocalSakeShop's #1 named gap; README table becomes *generated*, not hand-curated |
| `.githooks/` (pre-commit, pre-push, record-review, swiftformat) + `.swiftlint.yml`/`.swiftformat` | **Port** | Content-addressed, auto-expiring review evidence — unchanged |
| `.github/workflows/ci.yml` (+ dormant Claude jobs) | **Port** | build + test + lint unconditional; Claude eval/review jobs behind `CLAUDE_CI` flag as before |
| `mcp/validate-achievements-payload` | **Stretch** | Adapt the sake validator to the new contract (typed I/O schemas, never throws) — only if time remains (§8) |

**tech_specs/ tree to author (M1–M2):** `00-product-requirements.md` (EARS + acceptance +
"done = these tests"), `01-architecture.md`, `02-data-contract.md`, `accessibility.md`,
`performance-battery.md` (**new**, §7), `adr/0001…` (project generation, bundled-data + repository
seam, multi-package SPM, testing strategy, deployment target, SDD coherence, **vector-asset
pipeline**, **locked-medal rendering**, **mock-fidelity vs data-driven counts**), and
`modules/*.md` contract per package.

---

## 6. Milestones & time budget (8h cap)

One PR per milestone, Conventional Commits, hooks on (`git config core.hooksPath .githooks`).

| M | Phase | Work | Exit criteria | Budget |
|---|---|---|---|---|
| **M0** | Govern | `.gitignore` ✅ · port `.claude/` + hooks + lint/format configs + CI · CLAUDE.md · adopt **XcodeGen** (also fixes the unshared-scheme problem — the scheme lived in `xcuserdata`, invisible to CI/reviewers) · telemetry recorder | repo opens clean; hooks fire; scheme shared; app builds | 0.5h |
| **M1** | Specify | product requirements (EARS), data contract (+ landmine table), accessibility, performance-battery specs; ADRs; fixture `achievements.json` | specs self-contained; a builder needs no further questions | 0.75h |
| **M2** | Decompose | 5 module contracts (`modules/*.md`) with public API, deps, edge cases, "done = these tests" | contracts obey the dependency rule | 0.5h |
| **M3** | Construct T1 | `MedalDomain` ∥ `DesignSystem` via orchestrator (TDD: test-author → builder → reviewer loop); asset import (§2) | package tests green; tokens verified against mock | 1.25h |
| **M4** | Construct T2 | `MedalData`: DTO/mapper/bundled source/repository (+ `MedalTestSupport`) | mapper edge-case tests green (L1–L6 encoded as tests) | 0.75h |
| **M5** | Construct T3 | `AchievementsFeature`: ViewModel states + grid UI + locked rendering + "N of M" computed count | VM tests green; UI matches mock side-by-side | 1.5h |
| **M6** | Integrate & polish | App composition root, teal nav appearance, chrome (L7), dark mode (D4), Dynamic Type reflow, VoiceOver labels ("Marathon, not yet earned") | runs on simulator; XXL + VoiceOver pass | 1.0h |
| **M7** | Verify | snapshot baselines (light/dark/XXL/locked), `/eval` run + telemetry, `/ios-review`, Instruments sanity pass (§7), CI green | all gates green; eval score ≥ threshold recorded | 0.75h |
| **M8** | Document | README (see §9), screenshots/GIF, "If I had more time", AI-pipeline section with *generated* telemetry table | README complete; repo reviewable by unzip → open → Run | 1.0h |
| | | | **Total** | **8.0h** |

Stretch items (only if under budget — otherwise they go in "If I had more time"): remote data source
behind the existing seam · MCP payload validator · EN+JA localization · medal detail/share sheet ·
`/visual-eval` advisory run.

---

## 7. Runkeeper lens — performance, battery, fitness-app care

Gets its own spec (`tech_specs/performance-battery.md`) and README section, because this is the
team's daily bread. Two altitudes:

**In this screen (implemented + verifiable):**
- **Zero ongoing work**: no timers, no polling, no background tasks; data loads once, then the
  screen is inert. The cheapest battery strategy is absence of work.
- **`LazyVGrid`** in a `ScrollView` — offscreen cells never materialize.
- **Vector assets, decoded once**: PDF → asset catalog rasterization at fixed cell size; no runtime
  PDF re-rasterization, no oversized decodes (the LocalSakeShop image-downsampling lesson applied
  by construction).
- **Flat compositing**: the mock is flat — no shadows/blurs/offscreen passes on 12 cells.
- **Observation-scoped invalidation**: `@Observable` means only views reading changed properties
  re-render; stable `Identifiable` ids prevent diff churn.
- **Dark mode** with adaptive tokens (OLED battery + expected of a modern fitness app).
- **Verification, not vibes** (M7): Instruments Time Profiler + SwiftUI template + Animation
  Hitches on the grid scroll; report numbers in the README.
- MetricKit noted as the production telemetry hook.

**Beyond this screen (README/interview talking points — how this thinking scales to live tracking):**
GPS duty-cycling (`desiredAccuracy` tiers, `distanceFilter`, pausing), `HKWorkoutSession` for
tracking, batched/deferred writes, coalesced networking on background `URLSession`, offline-first
sync for achievements earned mid-run. Signals we know the domain without gold-plating a grid screen.

**Fitness-app product care in scope:** imperial units formatted through `Measurement`/locale-aware
formatting (mock's `2095 ft`), duration styles (L2), earned-vs-locked motivational affordance,
accessibility as a default (headers as VoiceOver headings, per-cell combined labels, Dynamic Type
XXL reflow — grid drops to adaptive columns, CJK-safe truncation rules for "Tokyo-Hakone Ekiden 2020").

---

## 8. Role alignment — the job description, mapped

The JD for this Mobile Developer (Runkeeper) role describes what the reviewers live day-to-day.
Each signal gets deliberate evidence in this repo:

| JD signal | Evidence in this project |
|---|---|
| "Document technical decisions and approaches" | ADR set + `tech_specs/` + this plan — decisions written *before* code |
| Code reviews "reviewed in a timely manner"; PR discipline | Evidence-gated review pipeline (content-addressed `/pre-commit-review` + `/ios-review`); one reviewable PR per milestone |
| "Minimal tech debt … quality of code meets the standards" | The constitution + `swiftlint --strict` + zero force-unwraps + the spec↔code coherence gate |
| Release ownership: RC, regression triage, store release, "post release monitoring for crashes", hotfixes | Shared scheme + CI from M0; error taxonomy with no silent failures; MetricKit/crash-reporting seam named in `performance-battery.md`; release-readiness checklist in the README |
| "Participate in the response to emergency production issues" | Deterministic fixtures + explicit loading/empty/error states make failure modes reproducible on demand |
| "Work with QA … to test new features" | Testability as a feature: dedicated mocks, snapshot baselines, fixture-driven UI states QA can force |
| "Write user stories for the product backlog" | EARS requirements with Given/When/Then acceptance — Jira-story-shaped by construction |
| "Keep current on new technologies … reduce friction in the development process" | The AI-DLC pipeline itself: versioned prompts, orchestrated TDD, LLM-judge evals, telemetry |
| Pods; "raising awareness … of possible merge conflicts, duplicated efforts, or rework" | Package-per-concern boundaries map to pod ownership; small, isolated conflict surface by design |
| "Conducting demos to internal and external stakeholders" | README as a demo script + screenshots/GIF; `#Preview` per state for live walkthroughs |

## 9. Resolved decisions (accepted 2026-07-18)

All recommendations below were accepted, with one governing principle added: **inherit only the AI
workflow from LocalSakeShop — every architecture choice must be justified by this project and the
Runkeeper context alone.**

| # | Decision | Resolution |
|---|---|---|
| D1 | "4 of 6" vs 5 colored medals (L1) | Data-driven count; visual states win (5 earned + 1 locked → "5 of 6"); the unsatisfiable annotation documented in README + ADR-0008 |
| D2 | Keep hand-made `.xcodeproj` vs **adopt XcodeGen** | **XcodeGen** (`project.yml` source of truth, generated project still committed → reviewer needs no tool; fixes scheme-sharing structurally; proven in LocalSakeShop, ~20 min) |
| D3 | Networking layer in scope? | **No** — brief has no data feed; ship bundled JSON behind the async repository seam; remote is a stretch/`more-time` item. Avoids speculative code in an 8h cap |
| D4 | Dark mode | **Yes** — adaptive tokens from day one; mock parity verified in light |
| D5 | Locked rendering | Derived (saturation 0 + opacity) per L3 |
| D6 | Overflow "⋮" behavior | Functional demo menu (toggle earned/reset fixture) per L7 |

---

## 10. README strategy (M8 — the reviewer's front door)

Modeled on LocalSakeShop's README, tuned for Runkeeper:

1. **Hero**: one-line pitch + screenshot table (light / dark / XXL / VoiceOver) + toolchain line +
   "open → Run, zero setup".
2. **Brief → code matrix**: every mock element and stated requirement mapped to the type that
   satisfies it (the grading checklist, pre-filled) — plus the JD-alignment table (§8).
3. **Architecture**: package graph + dependency rule + the async-repository rationale.
4. **The landmine table** (§3): found → decided → where documented. Interview ammunition, front and
   center.
5. **Performance & battery** (§7) with measured Instruments numbers.
6. **Testing**: counts by layer, how to run, snapshot policy.
7. **The AI pipeline**: phases, artifacts, *generated* telemetry table, eval scores, honest-gaps
   section (same candor that worked before).
8. **If I had more time**: remote source, MCP validator, localization, medal detail/share, visual
   eval promotion, wider golden set.

---

## 11. Definition of done

- [ ] Grid matches mock side-by-side (light mode) at standard Dynamic Type; tokens exact.
- [ ] All six landmines have a decided, documented, tested answer.
- [ ] Every module's "done = these tests" list is green; zero force-unwraps; SwiftLint strict clean.
- [ ] VoiceOver: sections are headings; each cell reads title + value/"not yet earned" as one label.
- [ ] XXL Dynamic Type: no truncation, grid reflows.
- [ ] CI green on a clean checkout; scheme shared; hooks enabled documented in README.
- [ ] Telemetry JSONL committed with ≥ 1 line per pipeline run; eval results committed.
- [ ] README complete per §9; total time spent honestly reported ≤ 8h.
