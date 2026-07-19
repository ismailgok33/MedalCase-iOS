---
name: ios-review
description: Adversarial iOS code review of the current diff against CLAUDE.md and tech_specs — architecture/dependency-rule conformance, Swift 6 concurrency, accessibility, performance/battery, naming, no hardcoded values, and spec↔code coherence. Use before committing a module or opening a PR.
---

# /ios-review — adversarial review vs the constitution

Operates the **Verify** phase. Be skeptical; assume there are violations and find them.

## I/O contract
- **Input:** `$ARGUMENTS` = optional scope (a module name or "diff"); defaults to the working-tree diff.
- **Output:** a findings list — each with severity (blocker/major/minor), file:line, the CLAUDE.md
  rule or spec clause violated, and a concrete fix. End with a single PASS/FAIL verdict.
- **Errors:** never rubber-stamp. If you cannot verify a claim, mark it "unverified" — don't pass it.

## Checklist
- **Dependency rule:** any import that violates the arrows? Does MedalDomain import SwiftUI/UIKit or
  any module? Does a feature import another feature? Does DesignSystem import domain/data?
- **Spec coherence (rule 2):** is new/changed public API reflected in `tech_specs/`?
- **Concurrency:** `@MainActor` correctness, `Sendable`, no data races, no `@unchecked` without reason.
- **Safety:** no force-unwrap / try! / as! / IUO in non-test code.
- **No hardcoding:** user strings in the String Catalog; the mock's hexes/sizes only in DesignSystem
  tokens; the "N of M" count computed from data, never literal (ADR-0008).
- **Accessibility:** each medal cell is one element ("«title», «value»" / "«title», not yet earned");
  section headers are headings; Dynamic Type to XXL with no truncation of long race names.
- **Performance (rule 8):** no timers/polling/background work introduced; no offscreen effects on
  grid cells; stable `Identifiable` ids; assets referenced through the typed catalog.
- **Testing:** acceptance criteria covered; mocks in dedicated files.
- **Naming / one-type-per-file / duplication.**

## Record evidence (this unlocks the push gate)
On a PASS, record it so `.githooks/pre-push` will allow the push:
```
bash .githooks/record-review.sh ios-review PASS "<one-line summary>"
```
The evidence is keyed to HEAD, so a new commit invalidates it — re-review after fixes.
Also append a telemetry line: `telemetry/record-run.sh skill ios-review "<scope>" <PASS|FAIL>`.

## Done when
Every checklist item is judged with file:line evidence, a single PASS/FAIL verdict is given, **and** a
PASS is recorded.
