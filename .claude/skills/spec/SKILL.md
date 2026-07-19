---
name: spec
description: Author or update a spec in tech_specs/ (product requirements, architecture, data contract, or a per-module contract) using EARS-style requirements with explicit acceptance criteria and a "done = these tests" list. Use when defining or changing what a module/feature must do, before writing code.
---

# /spec — author or update a spec

You are operating the **Specify/Decompose** phase of the AI-DLC pipeline (see CLAUDE.md). Specs in
`tech_specs/` are the source of truth; code is generated from them.

## I/O contract
- **Input:** `$ARGUMENTS` = the spec target — a path under `tech_specs/` (e.g. `modules/medal-data.md`)
  or a short description of the spec to author/update, plus the intent.
- **Output:** a created/updated Markdown spec in `tech_specs/`, and a one-paragraph summary of what
  changed and which downstream modules/tests are affected.
- **Errors:** if the target is ambiguous or would violate the dependency rule, STOP and ask; never
  invent requirements not implied by the brief (the mock) or existing specs.

## Procedure
1. Locate or create the target spec file; reuse the existing structure if updating.
2. Write requirements in **EARS** form:
   - Ubiquitous — "The <system> shall <response>."
   - Event — "When <trigger>, the <system> shall <response>."
   - State — "While <state>, the <system> shall <response>."
   - Unwanted — "If <condition>, then the <system> shall <response>."
3. For each requirement add **acceptance criteria** (Given/When/Then) and a **"done = these tests"**
   list naming the Swift Testing cases that will prove it.
4. For a module contract, declare: public protocols/types, dependencies (must obey the dependency
   rule), and the relevant edge cases from `tech_specs/02-data-contract.md` (locked medals, mixed
   value formats, unknown medal types, asset-name mapping, the computed "N of M" count).
5. Keep it platform-agnostic where possible — the contract should render to Kotlin/Compose as
   readily as SwiftUI (Runkeeper ships both platforms).
6. Note any decision worth an ADR and cross-link it.
7. Append a telemetry line: `telemetry/record-run.sh skill spec "<target>" PASS`.

## Done when
The spec is self-contained, testable, obeys the dependency rule, and a builder could implement it
without further questions.
