# Module: MedalTestSupport

**Layer:** Test support (linked only by test targets). **Depends on:** `MedalDomain` only. Provides the
shared mocks + fixtures so no test inlines a double (CLAUDE.md testing rule). It depends on the domain,
so the domain's **own** tests use a local double instead (avoids a `MedalDomain ↔ MedalTestSupport`
cycle) — this is the exact cyclic-dependency trap the LocalSakeShop eval caught, avoided by
construction here.

## Public surface

- `final class MockAchievementsRepository: AchievementsRepository, @unchecked Sendable` — a spy +
  stub for `achievements()`:
  - `var result: Result<AchievementsCase, Error>` — stub the return/throw.
  - `private(set) var callCount: Int` — verifies retry re-invokes (feature tests).
  - `@unchecked Sendable` is justified: each test owns its instance and Swift Testing serializes access
    within a test; the mutable spy state never crosses a real isolation boundary. (One written
    justification, test-support only — mirrors CLAUDE.md rule 7's escape hatch.)
- `enum AchievementFixtures` — factory helpers built from the **real** canonical data:
  - `canonicalCase` — the full fixture (5 earned + 1 locked PRs; 6 races incl. the 23:07 5K).
  - `emptyCase` — zero renderable medals (drives the empty-state test).
  - `singleSection(earned:locked:)` — parameterized builder for count/label assertions.
  - Individual medal/value builders (`earnedDuration`, `lockedMarathon`, `elevation`) for cell tests.

## Behavior

- Fixtures mirror `tech_specs/data/achievements.json` exactly (the same content `MedalData` ships), so
  domain/feature tests and data tests agree on one dataset. If the fixture changes, these builders
  change with it in the same PR (spec-coherence, ADR-0002).
- No production code, no UI, no data-layer types — purely domain-shaped test material.

## done = these tests

- Not independently tested (it *is* test material). Its correctness is exercised transitively by every
  consumer's suite: `MedalDomain` (via its local double, not this), `MedalData`, and
  `AchievementsFeature`. A compile check in CI (the package builds) is the only direct gate.

## Notes

- Ships as a library product usable by any test target. The App target's unit/UI test bundles link it
  too (M6+), so the composed-app tests reuse the same mocks and fixtures.
