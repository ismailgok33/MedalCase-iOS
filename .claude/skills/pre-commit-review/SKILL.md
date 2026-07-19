---
name: pre-commit-review
description: Gate staged changes before commit — formatting/lint clean, localization coverage (no new hardcoded user-facing strings), test coverage (new types have tests), and spec↔code coherence (new public API has a tech_specs entry). Use right before committing.
---

# /pre-commit-review — the commit gate

Operates **Govern/Verify**. Backed by the `.githooks/pre-commit` hook for the mechanical checks; this
skill adds the judgement checks a regex can't make.

## I/O contract
- **Input:** the staged diff (`git diff --cached`).
- **Output:** a PASS/FAIL with a checklist; on FAIL, the exact files/lines and fixes.
- **Errors:** if nothing is staged, say so and stop.

## Checks
1. **Format/lint:** `swiftformat --lint` and `swiftlint --strict` clean on staged Swift files.
2. **Localization coverage:** no new user-facing string literals in views — must be in the String
   Catalog.
3. **Test coverage:** every new public type/behavior has a corresponding Swift Testing case.
4. **Spec↔code coherence (ADR-0002):** any new/changed public API has a matching `tech_specs/` entry
   in the same change. New public API without a spec entry → FAIL.
5. **Conventional Commit** message proposed.

## Record evidence (this unlocks the commit gate)
On a PASS, record it so `.githooks/pre-commit` will allow the commit:
```
bash .githooks/record-review.sh pre-commit PASS "<one-line summary>"
```
The evidence is keyed to the current staged diff, so staging more changes invalidates it — review then.
Also append a telemetry line: `telemetry/record-run.sh skill pre-commit-review "<summary>" <PASS|FAIL>`.

## Done when
All five checks pass **and** the PASS is recorded, or the failures are reported with concrete fixes.
