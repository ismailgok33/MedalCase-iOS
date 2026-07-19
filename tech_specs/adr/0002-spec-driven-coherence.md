# ADR-0002 — Spec-driven coherence

**Status:** accepted (M0)

## Context
The app is built through an agentic pipeline. Generated code that silently diverges from its spec
destroys the pipeline's core promise: that `tech_specs/` describes what the code actually does.

## Decision
Specs are authoritative. Any change to behavior, a public contract, or acceptance criteria updates
the relevant `tech_specs/` file **in the same change**. `/pre-commit-review` fails a change that
adds public API without a spec entry; requirements are EARS-formed with a "done = these tests" list
so every claim is executable.

## Consequences
The spec tree is trustworthy documentation (JD: "document technical decisions and approaches") and
the substrate agents build from. Cost: small spec edits accompany code changes — the tax that keeps
docs true.
