---
name: tdd
description: Test-Driven Development for a module — write failing Swift Testing tests and dedicated mocks from a module spec's acceptance criteria FIRST, then implement to green, then refactor. Use when implementing a scaffolded module's behavior.
---

# /tdd — red → green → refactor from the spec

Operates the **Construct** phase. Tests come from the spec's "done = these tests" list.

## I/O contract
- **Input:** `$ARGUMENTS` = module name (with an existing scaffold + spec).
- **Output:** failing tests first, then the minimal implementation that makes them pass, then a
  refactor pass — committed in that order where possible.
- **Errors:** if a test can't be derived from an acceptance criterion, the spec is incomplete — STOP
  and run `/spec`. Never write implementation before a failing test exists.

## Procedure
1. From `tech_specs/modules/<name>.md`, enumerate acceptance criteria → one `@Test` each, named
   `test_subject_condition_expectation`, using mocks from `MedalTestSupport`.
2. Run tests; confirm they FAIL for the right reason (red).
3. Implement the minimum to pass. Honor CLAUDE.md: no force-unwrap, constructor DI, `@MainActor`
   where needed, errors mapped `MedalError → UserFacingError`.
4. Run tests; green. Then refactor for clarity/dedup with tests still green.
5. Cover the edge cases from `02-data-contract.md` where relevant to this module: locked medals
   (`Not Yet`), mixed value formats (`00:00` / `00:00:00` / `2095 ft`), unknown medal type, missing
   asset mapping, the data-driven "N of M" count, the unused 7th virtual-race asset.
6. Append a telemetry line: `telemetry/record-run.sh skill tdd "<Name>" <PASS|FAIL> <attempts>`.

## Done when
Every acceptance criterion has a green test, mocks live in dedicated files, and `swift test` passes.
