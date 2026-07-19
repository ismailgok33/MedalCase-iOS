---
name: scaffold-module
description: Generate a new local Swift Package under Modules/ from its tech_specs module contract — Package.swift, folder layout, public protocol stubs, a test target, and a dedicated mocks file in MedalTestSupport. Use when starting a new module, or to prove the architecture re-implements easily for a different data source.
---

# /scaffold-module — scaffold an SPM package from its spec

Operates the **Construct** phase. This skill is also live proof of re-usability: the same contract
could scaffold against a remote achievements API tomorrow.

## I/O contract
- **Input:** `$ARGUMENTS` = module name (e.g. `MedalData`) matching a `tech_specs/modules/<name>.md`.
- **Output:** `Modules/<Name>/` with `Package.swift`, `Sources/<Name>/` (public protocol stubs from
  the spec), `Tests/<Name>Tests/`, and dedicated mocks in `MedalTestSupport` for any new protocol.
- **Errors:** if the module spec is missing, STOP and run `/spec` first. Never add a dependency that
  violates the dependency rule (CLAUDE.md rule 1).

## Procedure
1. Read `tech_specs/modules/<name>.md`; extract the public protocols/types and declared dependencies.
2. Generate `Package.swift`: `swift-tools-version: 6.0`, platform `.iOS(.v17)` (ADR-0005), products +
   targets, and ONLY the local dependencies the spec declares (verify against the dependency arrows).
3. One type per file. Create `public protocol` stubs with `///` docs and `// TODO: implement via /tdd`.
4. Create the test target importing Swift Testing + `MedalTestSupport`.
5. For each new protocol, create `Sources/MedalTestSupport/Mock<Protocol>.swift` (a dedicated mock
   with call-spies and stubbable returns) — never inline mocks in tests.
6. Build the package (`swift build --package-path Modules/<Name>`) to confirm it compiles, then add
   the package to `project.yml` and run `xcodegen generate` (ADR-0001).
7. Append a telemetry line: `telemetry/record-run.sh skill scaffold-module "<Name>" <PASS|FAIL>`.

## Done when
The package compiles, exposes exactly the spec's public surface, has a test target wired to
`MedalTestSupport`, and adds no dependency-rule violation.
