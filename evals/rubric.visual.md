# LLM-as-Judge Rubric — rendered UI visual intent

The judge scores a **rendered screenshot** (a committed image under `docs/media/`, or a snapshot
baseline) against the view's **intent** — what must be visually true per the mock + specs — plus the
accessibility / no-truncation rules in `CLAUDE.md`. Each criterion is scored **0** / **0.5** / **1**,
then weighted. Aggregate = Σ(weight × score). A case **PASSES** when aggregate ≥ the `visual` threshold
(`thresholds.json`) **and** no `blocker` criterion scores 0. **Advisory** — reports findings, never
blocks (ADR-0009).

The judge reads the image plus the golden case's stated intent and scores only what is **visible**. It
**must cite visual evidence** for any score below 1 (e.g. "the Marathon badge is full-color, not
ghosted", "the race title is clipped at the right edge").

| # | Criterion | Weight | blocker? | 1.0 means |
|---|-----------|:------:|:--------:|-----------|
| 1 | **Required elements present** — every element the intent lists is visible (teal bar + title; section header + count; each medal's badge, title, value) | 0.25 | ✅ | All intent elements rendered |
| 2 | **No truncation or clipping** — text fully visible, especially long race names at accessibility Dynamic Type sizes | 0.20 | ✅ | Nothing cut off, ellipsised, or overflowing |
| 3 | **Locked state correct** — the locked medal is visibly ghosted (desaturated + dimmed) with "Not Yet"; earned medals are full-color | 0.15 | — | Locked vs earned visually distinct per the mock |
| 4 | **Progress count correct** — the section that shows a count renders "N of M" matching the visible earned medals (data-driven) | 0.15 | — | Count matches the rendered earned cells |
| 5 | **Layout coherent** — 2-column grid (or 1 at accessibility sizes); sensible spacing/alignment; no overlap | 0.10 | — | Clean, legible composition |
| 6 | **Color fidelity** — teal bar, section strip, and text colors match the mock's annotated hexes; dark mode adapts | 0.10 | — | Colors read as the mock intends |
| 7 | **Contrast & legibility** — text readable against its background (approximate WCAG sense) | 0.05 | — | Comfortably legible |

Output conforms to [`schema/result.schema.json`](schema/result.schema.json), with `suite: "visual"`.
