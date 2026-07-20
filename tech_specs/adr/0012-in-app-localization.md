# ADR-0012 — EN + FR localization with an in-app language switcher

**Status:** accepted

## Context
The role is based in Canada; the app shipped EN-only. We want a reviewer to see localization
machinery *working* without changing device settings — an in-app EN/FR switcher in the overflow
menu (R1.6, R4.4). Four real constraints surfaced while building it, each worth recording:

1. **SwiftPM's CLI doesn't compile String Catalogs.** `swift build`/`swift test` copy a
   `Localizable.xcstrings` into the resource bundle *verbatim* (verified: the raw file sat in
   `DesignSystem_DesignSystem.bundle`; `fr.lproj` never materialized), so package unit tests see no
   localization at all. Xcode's build system compiles xcstrings fine — but the fast per-package
   `swift test` loop and CI's package matrix are the CLI.
2. **`navigationTitle` escapes the SwiftUI locale environment.** Its Text is hoisted into the UIKit
   bar and resolves against the app's *system* language — a cold FR launch still showed
   "Achievements" while everything in-tree said "5 sur 6".
3. **Launch arguments shadow AppStorage.** `-app_language en` registers in `NSArgumentDomain`,
   which precedes the persistent domain in every UserDefaults read — the switcher UI test's own
   "hermeticity" argument made the switch it was testing unobservable (writes landed; reads kept
   answering the argument value).
4. In-app language override is inherently a **demo affordance** — real apps follow the system
   language (per-app override lives in iOS Settings).

## Decision
- **Per-package `.lproj/Localizable.strings` tables (EN + FR)**, auto-detected by SwiftPM under
  `defaultLocalization`, every lookup passing `bundle: .module` (or, for resource-form strings, via
  each module's internal **`L10n`** namespace, which centralizes the
  `LocalizedStringResource(…, bundle: .atURL(Bundle.module.bundleURL))` plumbing so call sites can't
  silently resolve against the main bundle). No xcstrings in packages (constraint 1). Unit tests
  prove each table resolves (`fr.lproj` fetched explicitly) **and** that the `L10n` accessors resolve
  FR end-to-end (a typo'd key inside `L10n` fails tests instead of silently speaking English).
- **Switcher = AppStorage + `\.locale` environment.** `AppLanguage` (en/fr) persists via
  `@AppStorage`; `AchievementsView` applies `.environment(\.locale, …)` outermost plus
  `.id(appLanguage)` so the whole subtree — including UIKit-bridged toolbar content — re-creates on
  switch. First launch seeds from `Locale.preferredLanguages` (`fr*` → French, else English), so a
  French-system device starts in French without touching the switcher. Language rows are plain menu **buttons** with a checkmark and stable
  `accessibilityIdentifier`s (`language-en`/`language-fr`) so the UI test addresses them
  language-independently (constraint 3: the test launches with *no* language argument and pins its
  EN baseline through the UI itself).
- **The bar title is a `principal` toolbar item** (constraint 2) — an in-tree Text that re-resolves
  live, styled with the mock's exact 16px `navTitle` token + header trait.
- **Split of responsibility:** chrome/state strings localize client-side; medal/section titles stay
  data-supplied (server-localized in production via Accept-Language); numeric value glyphs are
  verbatim. Accessibility labels follow the *device* language by design (VoiceOver speaks the
  system voice); FR tables cover both paths so a French device is fully French.

## Consequences
The reviewer flips EN ↔ FR from the ⋮ menu and watches the title, count ("5 of 6" ↔ "5 sur 6"),
locked value ("Not Yet" ↔ "Pas encore"), menu, and state surfaces re-resolve live — proven by unit
tests (table resolution), a FR snapshot baseline, and a round-trip XCUITest. Costs: a full subtree
re-create (and reload) per switch — user-initiated and bounded, so rule 8 holds; translations are
authored in-repo (production would add native review); the error message stored in
`UserFacingError` resolves at creation locale, a known corner documented in the feature spec. For
production, the switcher would be removed in favor of iOS's per-app language setting, whose
plumbing (tables, bundles, keys) is exactly what this exercise built.

Content (medal/section titles) is deliberately **not** in these tables — it is payload text, served
per-language by the data layer. That half of the story is ADR-0013.
