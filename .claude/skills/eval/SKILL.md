---
name: eval
description: Run the agent/skill evals — score generated code against golden cases with an LLM-as-judge rubric (vs CLAUDE.md), report pass/fail per case and an aggregate score, and flag regressions below threshold. Use in the Verify phase and in CI after changing a skill or prompt.
---

# /eval — measure the pipeline's output quality

Operates the **Verify** phase. Makes prompt/skill changes measurable — "metrics, not vibes."

## I/O contract
- **Input:** `$ARGUMENTS` = optional eval suite name; defaults to all suites under `evals/`.
- **Output:** a results table — per golden case: score 0–1, pass/fail, and the rubric breakdown; plus
  an aggregate and a regression verdict vs the threshold in `evals/thresholds.json`.
- **Errors:** if a golden case or rubric is missing, STOP — don't score against an absent baseline.

## Procedure
1. Load golden cases from `evals/golden/` (input spec → expected scaffold/output shape) and the rubric
   from `evals/rubric.md`. The golden set includes **adversarially bad** cases — a rubric that can't
   fail a known-bad input is not yet trustworthy.
2. For each case, run the target skill, then score the output with the LLM-as-judge rubric against
   CLAUDE.md (one-type-per-file, no force-unwrap, DI present, tests present, dependency rule). The
   judge must cite file:line for any score below 1.
3. Emit one `evals/schema/result.schema.json`-conformant object per case into `evals/results/`;
   compare the aggregate to the threshold; exit non-zero on regression (for CI).
4. Append one telemetry line per case:
   `telemetry/record-run.sh skill eval "<suite>/<case>" <PASS|FAIL>`.

## Done when
Every golden case is scored, the aggregate is computed, and a clear pass/fail vs threshold is returned.
