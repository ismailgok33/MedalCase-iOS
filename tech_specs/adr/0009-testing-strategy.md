# ADR-0009 — Testing strategy (Swift Testing + snapshots + XCUITest)

**Status:** accepted (M1)

## Context
"Definition of done" must be executable (ADR-0002), across pure logic (formatting, mapping
policies), visual fidelity to the mock, and the composed app.

## Decision
Three layers, cheapest boundary first:
1. **Swift Testing** unit tests per package (`@Test`, `#expect`/`#require`) — every spec's
   "done = these tests" list; mocks live in dedicated `MedalTestSupport` files, fixtures come from
   the real `achievements.json`.
2. **Snapshot tests** (swift-snapshot-testing, the one test-only third-party dependency) for the
   grid and cells: light / dark / XXL / locked. Baselines are committed; they are renderer-pinned
   to the dev simulator, so CI skips them (they run locally + in the pre-push gate) — stated
   honestly rather than flaked around.
3. **One XCUITest** smoke: launch → grid visible → both sections reachable by scroll.

## Consequences
Fast per-package inner loop; visual regressions caught by diff; the known snapshot-portability
limitation is documented, with the advisory `/visual-eval` as the semantic companion. Naming:
`test_subject_condition_expectation`, one reason to fail per test.
