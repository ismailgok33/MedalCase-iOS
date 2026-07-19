# Evals — measuring the pipeline's output quality

This suite makes the AI-DLC pipeline's output **measurable** rather than vibes-based (the JD's
"automated eval pipelines / LLM-as-judge scoring" requirement). It scores generated artifacts against
`CLAUDE.md` and the specs, with structured, schema-conformant output and threshold gating.

## Layout

```
evals/
  rubric.md                 # code-quality rubric (9 weighted criteria, 3 blockers)
  rubric.visual.md          # rendered-UI visual-intent rubric (7 criteria) — advisory (ADR-0009)
  schema/result.schema.json # draft-07 schema every result must conform to
  thresholds.json           # per-suite pass thresholds + regression tolerance
  golden/
    scaffold-module/        # code goldens: MedalDomain (clean) + MedalData-cyclic (adversarial)
    visual/                 # visual goldens keyed to docs/media/ screenshots
  results/                  # recorded LLM-as-judge results (one JSON per golden case)
```

## How it discriminates (the point)

An eval that always returns 1.0 is theatre. Two design choices give this one teeth:

1. **An adversarial golden.** `golden/scaffold-module/MedalData-cyclic` describes a scaffold that leaks
   `MedalTestSupport` into a production target (a dependency-rule cycle) and force-tries in non-test
   code. The rubric scores its blocker criteria (1 and 3) at **0**, so it **FAILS**
   (`results/scaffold-module.MedalData-cyclic.json`, aggregate 0.45). A run where this case *passes* is
   a rubric regression, called out in `thresholds.json`. This is the same class of defect the real M4
   build avoided by construction — here we prove the rubric would catch it.

2. **Blocker criteria.** Aggregate ≥ threshold is necessary but not sufficient: any blocker at 0 fails
   the case regardless of aggregate. So a mostly-good artifact with one dependency-rule violation cannot
   sneak through on a high average.

## Current results

| Suite | Case | Aggregate | Verdict |
|---|---|:--:|:--:|
| scaffold-module | MedalDomain | 1.00 | ✅ PASS |
| scaffold-module | MedalData-cyclic (adversarial) | 0.375 | ❌ FAIL *(expected)* |
| visual | grid-light | 1.00 | ✅ PASS |
| visual | grid-dark | 1.00 | ✅ PASS |
| visual | grid-accessibility-xxl | 1.00 | ✅ PASS |
| visual | locked-cell | 0.975 | ✅ PASS |

## Honest gaps (own them)

- **Golden-set size.** Two code goldens (one clean, one adversarial) + four visual — enough to prove the
  harness discriminates, not yet a dataset. Before trusting the score to gate a team's merges, grow
  good *and* adversarially-bad goldens per skill.
- **Judge determinism.** These results are recorded from a manual judge pass. Production hardening:
  pin the judge model + temperature 0 + multi-sample voting; the `regression_tolerance` (0.05) absorbs
  small variance today.
- **The visual suite is advisory** (ADR-0009) — it informs, it never blocks a merge.
