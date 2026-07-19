---
name: visual-eval
description: Run the visual eval suite — a vision-model judge scores the committed UI snapshot baselines against a per-view visual-intent rubric (vs the view specs + CLAUDE.md accessibility rules), reports pass/fail per case + an aggregate, and flags regressions below threshold. Advisory (does not gate). Use in the Verify phase after a UI or snapshot-baseline change.
---

# /visual-eval — measure the UI's visual intent

Operates the **Verify** phase. A *semantic* companion to the deterministic pixel snapshots:
pixel-diff asks "did it change?"; this asks "is it right?" — over the **same** committed images.
**Advisory, not a gate** — report findings; never block on a VLM verdict.

## I/O contract
- **Input:** `$ARGUMENTS` = optional golden-case name; defaults to every case under `evals/golden/visual/`.
- **Output:** a per-case results table (score 0–1, pass/fail, rubric breakdown with **visual** evidence),
  an aggregate, and a regression verdict vs `evals/thresholds.json` (`visual` suite).
- **Errors:** if a golden case names an image that is missing, STOP — never score against an absent image.

## Procedure
1. Load each golden case from `evals/golden/visual/` (image path + stated **intent** — e.g. "earned
   cell shows badge + title + value", "locked Marathon is ghosted and reads Not Yet", "XXL reflows
   without truncating 'Tokyo-Hakone Ekiden 2020'") and the rubric from `evals/rubric.visual.md`.
   Image paths are repo-root-relative.
2. For each case: **Read the image** (the harness renders it), then score it against the rubric — judging
   only what is **visible**, citing visual evidence for any score < 1.
3. Emit one `schema/result.schema.json`-conformant object per case (`suite: "visual"`); compute the
   aggregate; compare to the threshold. On a regression, report it as an **advisory concern** — do **not**
   exit non-zero / block (this suite does not gate).
4. Append a telemetry line per case: `telemetry/record-run.sh skill visual-eval "<case>" ADVISORY`.

## Calibration (required before promoting this suite to a blocking gate)
An initial **advisory** baseline may be recorded from a manual run (the suite never blocks). Before
trusting that baseline for regression comparison — and **mandatory** before any promotion from advisory
to a gate:
- Feed the judge a **deliberately bad** image (e.g. a truncated "Tokyo-Hakone Ekiden 2020" title, or
  a colored Marathon cell claimed as locked) and confirm the matching blocker criterion scores **0**
  → the case FAILS. A rubric that can't fail a known-bad image is not yet trustworthy.
- Run a case **≥3×** and confirm the verdict is stable. If it swings, tighten the rubric/intent first.

## Done when
Every selected case is scored against a present image, the aggregate + threshold verdict is returned, and
(once calibrated) the results are recorded. Findings are advisory — they inform, they do not block.
