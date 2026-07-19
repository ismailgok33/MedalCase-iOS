# LLM-as-Judge Rubric — generated Swift module quality

The judge scores a skill's output (a generated/scaffolded module) against `CLAUDE.md` and the module
spec. Each criterion is scored **0** (absent/violated), **0.5** (partial), or **1** (fully met), then
weighted. Aggregate = Σ(weight × score). A case **PASSES** when aggregate ≥ the suite threshold
(`thresholds.json`) **and** no `blocker` criterion scores 0.

| # | Criterion | Weight | blocker? | 1.0 means |
|---|-----------|:------:|:--------:|-----------|
| 1 | Dependency rule respected (imports obey the arrows; `MedalDomain` imports nothing — not even Foundation) | 0.20 | ✅ | No violating import anywhere |
| 2 | One type per file; filename == type | 0.10 | — | Every file holds one primary type named after it |
| 3 | No force-unwrap / `try!` / `as!` / IUO in non-test code | 0.15 | ✅ | None present |
| 4 | Constructor DI; depends on protocols, not concretes | 0.15 | — | All deps injected via `init` as protocols |
| 5 | Dedicated mock/double file(s) (not inline in a test) | 0.10 | — | Doubles in their own files |
| 6 | Tests present and derived from acceptance criteria (the spec's `done =` list) | 0.15 | ✅ | Each criterion has a `@Test` |
| 7 | No hardcoded user strings / magic numbers (strings catalog-ready; sizes/colors in DesignSystem tokens) | 0.05 | — | No literals that belong in a token/catalog |
| 8 | Public surface == spec (no over-exposure; DTOs/mappers internal) | 0.05 | — | Only spec'd API is `public` |
| 9 | Swift 6 concurrency correct (`@MainActor`/`Sendable`; `@unchecked` justified) | 0.05 | — | No concurrency smell |

The judge **must cite file:line evidence** for any score below 1 and must not award a score it cannot
justify from the artifact. Output conforms to [`schema/result.schema.json`](schema/result.schema.json).

## Discrimination (why this rubric has teeth)

An eval that always returns 1.0 is theatre. The suite includes an **adversarial** golden case
(`golden/scaffold-module/MedalData-cyclic.input.md`) that *intentionally* violates the dependency rule
(a `MedalDomain ↔ MedalTestSupport` cycle). The rubric must score criterion 1 (a blocker) at **0** for
that case → the case **FAILS**. A rubric that can't fail a known-bad artifact is not trustworthy; this
one is calibrated to catch exactly the class of defect the real M4 build avoided by construction.
