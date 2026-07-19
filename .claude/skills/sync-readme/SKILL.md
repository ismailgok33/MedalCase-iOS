---
name: sync-readme
description: Regenerate the README from tech_specs, telemetry, and git history — overview, setup, architecture diagram, decisions/ADR index, landmine table, testing, accessibility, performance numbers, the generated AI-usage telemetry table, evals results, coverage matrix, and the "what I'd do next" roadmap. Use during the Document phase or before submission.
---

# /sync-readme — regenerate the README from sources of truth

Operates the **Document** phase. The README is generated, not hand-maintained, so it never drifts.
It is the reviewer's front door — assume they read it before opening Xcode.

## I/O contract
- **Input:** `$ARGUMENTS` = optional section to refresh; defaults to the whole README.
- **Output:** an updated `README.md` whose claims are all backed by `tech_specs/`, `.claude/`,
  `evals/`, `telemetry/runs.jsonl`, or git history. Flags any section it could not source.
- **Errors:** never invent results (test counts, eval scores, Instruments numbers). If a number
  isn't measurable, say so.

## Sections
1. Hero — one-line pitch + screenshot table (light / dark / XXL / VoiceOver) + toolchain +
   "open → Run, zero setup".
2. **Brief → code matrix** — every mock element and stated requirement mapped to the satisfying
   type — plus the JD-alignment table (`docs/EXECUTION_PLAN.md` §8).
3. Architecture — module graph (Mermaid) + the dependency rule, sourced from `01-architecture.md`.
4. **The landmine table** — each mock inconsistency: found → decided → where documented (ADR links).
5. Performance & battery — the rule-8 story + **measured Instruments numbers** from M7.
6. Testing — counts by layer (computed from the tree, not guessed), how to run, snapshot policy.
7. Accessibility — what was audited and the result.
8. **AI usage** (the showcase) — pipeline overview, prompt strategy, the **telemetry table generated
   from `telemetry/runs.jsonl`** (per run: skill/agent, task, verdict, attempts) + success rate,
   evals results, and the honest-gaps section.
9. What I'd do next — the roadmap (remote source behind the existing seam, MCP validator,
   localization, medal detail/share, visual-eval promotion).
10. Setup — `git config core.hooksPath .githooks`; simulator = iPhone 17; time spent (honest, ≤ 8h).

## Done when
Every claim is traceable to a committed source, and the AI-usage section tells the pipeline story.
