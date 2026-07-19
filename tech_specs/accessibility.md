# Accessibility

Accessibility is a default, not a pass (CLAUDE.md). This spec is the audit checklist; each row is
verified in M6/M7 and reported honestly in the README — including the one place the mock itself
fails contrast.

## VoiceOver semantics

| Element | Treatment | Label |
|---|---|---|
| Medal cell (earned) | **one** element (`.accessibilityElement(children: .combine)` or explicit) | "«title», «formatted value»" — e.g. "Virtual 5K Race, 23:07" |
| Medal cell (locked) | one element | "«title», not yet earned" (never the visual "Not Yet" alone — context matters aurally) |
| Section header | heading trait | "«title»"; if it shows a count: ", N of M earned" |
| Back button | button, standard | system-provided |
| Overflow menu | button → menu | "More options" |
| Badge image inside a cell | `.accessibilityHidden(true)` | decorative — the cell label already carries meaning |

Reading order: header → its medals in visual order → next header. No focus traps; the grid is a
plain scroll surface.

## Dynamic Type

- All fonts are tokens built with `Font.custom(_:size:relativeTo:)` (or `.system` text styles) so
  the mock's px sizes (L8) scale with the user's setting — **no fixed sizes**.
- At accessibility sizes (`.accessibility1`+, `dynamicTypeSize.isAccessibilitySize`) the grid reflows
  from 2 columns to **1 column** — cells grow rather than cramp or truncate.
- Long titles ("Tokyo-Hakone Ekiden 2020", "Mizuno Singapore Ekiden 2015") wrap to multiple lines
  (default `Text` wrapping, no line limit). **Truncation is a test failure**, not a style choice.

## Contrast audit (computed, WCAG 2.1 AA)

| Pair | Ratio | Verdict |
|---|---|---|
| medal title `#000000` on `#FFFFFF` | 21.0:1 | ✅ AA/AAA |
| section title `#333333` on `#F7F7F7` | 11.8:1 | ✅ AA/AAA |
| section count `#666666` on `#F7F7F7` | 5.4:1 | ✅ AA |
| medal value `#666666` on `#FFFFFF` | 5.7:1 | ✅ AA |
| **nav title `#FFFFFF` on teal `#63C6D4`** | **2.0:1** | ❌ **fails AA (4.5:1; even large-text 3:1)** |

**The honest finding:** the mock's own nav bar fails WCAG contrast. Resolution: keep mock fidelity
in the default appearance (it is the brief), and support **Increased Contrast** — when
`colorSchemeContrast == .increased`, the composition root (`RootView`) swaps the bar's
`.toolbarBackground` to the darkened `brandTealHighContrast` token that clears 4.5:1 against white.
Both colors are DesignSystem tokens; the swap is one environment read. Documented in the README rather
than silently claimed compliant.

## Other

- **Reduce Motion:** no animations are used beyond default navigation transitions — nothing to
  gate, stated explicitly.
- **Dark mode:** adaptive tokens (surface/strip/text) with the same contrast targets; badge assets
  render on the adaptive surface unchanged.
- **Localization:** chrome/state strings ("Achievements", "Not Yet", "not yet earned", error/empty
  copy) live in the per-package localization tables (EN + FR — ADR-0012). **Language stance:**
  visible text follows the in-app language override; accessibility *labels* deliberately follow the
  device language (VoiceOver speaks in the system voice/language — reading French labels with an
  English voice would be worse than consistent system-language labels). FR strings exist for both
  paths, so a French *device* gets fully French VoiceOver. Medal/section titles arrive from data (server-localized in
  production — [`02-data-contract.md`](02-data-contract.md)).

*done =* `test_medalCell_accessibilityLabel_earned`, `test_medalCell_accessibilityLabel_locked`,
`test_sectionHeader_isAccessibilityHeading`, `test_navBar_increasedContrast_usesAccessibleTeal`,
snapshots `achievements-grid-xxl` + `achievements-grid-dark`.
