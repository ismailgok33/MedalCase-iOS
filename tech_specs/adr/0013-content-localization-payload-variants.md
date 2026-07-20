# ADR-0013 — Content localization: per-language payload variants from the data layer

**Status:** accepted

## Context

ADR-0012 drew the localization line: client-owned **chrome/state** strings live in per-package
tables; **content** (medal/section titles) is payload text, server-localized in production. The
in-app switcher made that split visible — and it *read as half-done*: flipping to French translated
the chrome while every title stayed English. The stance was architecturally right (clients cannot
carry tables for content they have never seen — new virtual races ship server-side without an app
release; brand names like "Hakone Ekiden" are never translated) but the demo experience argued for
demonstrating the server side too. Since the bundled fixture *is* our server (ADR-0004), we can.

## Decision

Model Accept-Language inside the bundled source:

- Two **structurally identical** documents: `achievements.json` (EN, base) and `achievements-fr.json`
  (generic titles translated, **brand race names verbatim**). Parity — ids, order, statuses, values,
  asset keys — is enforced by test, so a language switch can never change *what* is shown.
- `BundledAchievementsDataSource.resourceName(forLanguageCode:)` (pure, tested): any `fr*` tag → the
  FR document, anything else → base.
- `DefaultAchievementsRepository.init(languageCode: @Sendable () -> String)` reads the provider
  **per call**. The composition root passes the same resolution the switcher UI uses (the stored
  `AppLanguage`, else the system seed) — `AppLanguage` became `public` for exactly this consumer —
  so chrome and content can never disagree.
- On a language switch the feature calls `refreshContent()`: re-fetch, replace content **in place**
  (no `.loading` flip), and on a failed refresh keep the current content — a language flip must never
  destroy a loaded medal case. From a non-loaded state it degrades to a full load.

## Consequences

The FR screen is fully French (chrome via ADR-0012 tables, content via the FR payload), while the
production architecture stays honest: a remote source honoring real Accept-Language slots in behind
the same seam with zero downstream change. Costs: a second fixture to maintain (the parity test turns
drift into a red test); the refresh is user-initiated and bounded (rule 8 holds). Numeric value glyphs
stay verbatim per ADR-0010 — unit localization ("ft" → "pi") remains the documented production step
with `MeasurementFormatter`. Accessibility labels follow the app's **effective language** — the
combined header label is fully French in FR mode, format and payload title alike (empirically pinned
by the switcher UI test; `accessibility.md`). The residual demo-override cost is a voice/text
mismatch — French label text spoken by an English system voice — which disappears under iOS's
per-app language setting. A future remote source would also add a non-destructive failure affordance
for `refreshContent()` (keep content + notify) in place of today's silent keep, which is fine only
while the source is a bundled resource that cannot genuinely fail.
