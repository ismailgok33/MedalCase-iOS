# Performance & Battery

Runkeeper is an app people take on multi-hour runs — battery discipline is a feature. This screen
is static, so the strategy is **absence of work** (CLAUDE.md rule 8), and the claims are
**measured in Instruments (M7)**, not asserted.

## The contract for this screen

| Rule | Mechanism | Verified by |
|---|---|---|
| Zero ongoing work after load | no timers, no polling, no `Task` loops, no background tasks; the ViewModel loads once and goes inert | `/ios-review` checklist (every PR) |
| Offscreen cells are never built | `LazyVGrid` inside `ScrollView` | view inspection + Instruments SwiftUI template |
| Badges decode once, at display size | PDF vectors in the asset catalog (ADR-0006); fixed cell image frame; no runtime PDF rasterization | Instruments allocations — no repeated image decodes while scrolling |
| Minimal invalidation | `@Observable` (Observation) — views re-render only on properties they read; stable `Identifiable` ids → no diff churn | code review + SwiftUI Instruments (update counts) |
| Cheap compositing | flat cells per the mock — no shadows, blurs, or `drawingGroup` offscreen passes | scroll hitch check |
| Dark mode | adaptive tokens (OLED savings; expected of a fitness app) | snapshots |

## M7 verification protocol (results → README)

1. **Time Profiler** — cold open to rendered grid; confirm render work happens once (no per-frame
   work while idle).
2. **SwiftUI template** — scroll the grid top↔bottom; record view-update counts and any hitches
   (target: none on a 12-cell grid).
3. **Allocations** — confirm badge images decode once each; total footprint reported.
4. Numbers land in the README's performance section; anything unmeasured is not claimed.

### M7 results (measured)

| Metric | Result | How |
|---|---|---|
| **Cold launch → first frame** | **0.79 s** average (5 runs, RSD 1.3%) | `XCTApplicationLaunchMetric` (`MedalCaseUITests.test_launchPerformance`) — a signpost-backed, reproducible metric, run on iPhone 17 simulator |
| **Ongoing work after load** | **none** | Code review each milestone (`/ios-review` battery checklist): grep confirms no `Timer`/`Task {}` loop/polling/`onReceive` after the single `.task { load() }`; the ViewModel goes inert |
| **Offscreen cell materialization** | lazy | `LazyVStack` + `LazyVGrid` by construction; only visible cells build |
| **Badge decode** | once each, at display size | asset catalog + fixed `Spacing.badgeSize` frame; no runtime PDF re-rasterization |

**Honest scope:** the launch number is a real Instruments-grade signpost metric. The scroll-hitch and
allocations claims are verified **by construction + code review**, not yet captured from the Instruments
GUI templates (Time Profiler / SwiftUI / Allocations) — those remain the deeper pass and are listed in
the README's "what I'd do next". For a static 12-cell grid with no animations or background work, the
dominant battery lever is the *absence of work*, which is inspectable; the launch metric guards against
a regression that adds startup cost.

**Production seam (release-monitoring — JD):** the composition root is where `MXMetricManager`
(MetricKit: battery/hitch/launch metrics in the field) and a crash reporter would attach; post-release
monitoring reads those same signals. Named here so the wiring cost is one file — not built in the
8h scope.

## How this thinking scales to live tracking (interview notes, not scope)

The same discipline applied to Runkeeper's core: GPS duty-cycling (`desiredAccuracy` tiers,
`distanceFilter`, `pausesLocationUpdatesAutomatically`, deferred updates) · `HKWorkoutSession` as
the tracking backbone · batched/deferred disk writes on the run path · coalesced networking on a
background `URLSession` (upload once, not per-split) · offline-first sync so achievements earned
mid-run survive dead zones · image downsampling for any feed content. The medal case needs none of
these — knowing *why not* is the point.
