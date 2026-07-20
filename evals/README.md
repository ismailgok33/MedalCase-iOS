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
| visual | grid-light | 0.975 | ✅ PASS |
| visual | grid-dark | 0.975 | ✅ PASS |
| visual | grid-accessibility-xxl | 0.975 | ✅ PASS |
| visual | locked-cell | 0.975 | ✅ PASS |
| visual | locked-cell-fr | 0.975 | ✅ PASS |
| visual | grid-french | 0.975 | ✅ PASS |
| visual | calibration-truncated | 0.425 | ❌ FAIL *(expected)* |

Visual cases were re-judged after the localization/chrome pass over the refreshed screenshots. The
grids now score 0.975 rather than 1.00 — not a regression (Δ 0.025 < tolerance 0.05) but a scoring
*consistency* fix: the white-on-teal title's documented contrast exception (criterion 7) is now
applied to every case, where the first run applied it only to `locked-cell`.

## Calibration (visual suite)

Per the `/visual-eval` skill, an advisory baseline is only trustworthy once the rubric demonstrably
**fails a known-bad image**. [`calibration/truncated-xxl.png`](calibration/truncated-xxl.png) is the
XXL screenshot deliberately cropped to clip the title, the ⋮ control, the count, and three medal
titles: the judge scores criterion 2 (truncation, blocker) at **0**, failing the case at 0.425
([`results/visual.calibration-truncated.json`](results/visual.calibration-truncated.json)). A rubric
that can't fail this image would be theatre; this one discriminates.

## Honest gaps (own them)

- **Golden-set size.** Two code goldens (one clean, one adversarial) + six visual + a visual
  calibration case — enough to prove the harness discriminates, not yet a dataset. Before trusting
  the score to gate a team's merges, grow good *and* adversarially-bad goldens per skill.
- **Judge determinism.** These results are recorded from a manual judge pass. Production hardening:
  pin the judge model + temperature 0 + multi-sample voting; the `regression_tolerance` (0.05) absorbs
  small variance today.
- **The visual suite is advisory** (ADR-0009) — it informs, it never blocks a merge.
