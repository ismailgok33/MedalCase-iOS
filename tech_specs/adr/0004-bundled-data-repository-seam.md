# ADR-0004 — Bundled data behind an async repository seam (no networking layer)

**Status:** accepted (M1)

## Context
The brief supplies a mock and vector assets — no feed, no API. Runkeeper's real medal case is
server-fed. Shipping a speculative HTTP stack would be scope theater; hardcoding view data would
make the screen a painting.

## Decision
Define the server-shaped contract ourselves (`02-data-contract.md`), bundle the canonical fixture,
and load it through `AchievementsRepository` — `async throws`, injected as a protocol. The only
implementation today reads the bundle; decoding/mapping failures surface as typed `MedalError`s
driving the real error state. **No networking layer, no caching tiers** — this brief doesn't earn
them. Deliberately no use-case layer either: one read operation makes the repository protocol the
seam (`01-architecture.md`).

## Consequences
The loading/error/empty paths are real code paths, testable and demoable. A remote source later
touches `MedalData` + the composition root only. Consequently there is no `/security-review` gate
in the cadence (no network/URL/WebView surface) — it joins the day a remote source does. "What I'd
do with more time" gets a concrete, seam-shaped answer instead of a rewrite.
