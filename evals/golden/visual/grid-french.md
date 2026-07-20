# Visual golden — achievements grid, French (in-app switcher)

**Image:** `docs/media/04-fr.png` (running app, iPhone 17, light appearance, launched in FR — the
state the in-app EN/FR switcher produces, ADR-0012).

## Intent (what must be visually true)
- The teal bar title reads **"Réalisations"** (white, small, centered) — the principal-item title
  re-resolved in French; the trailing ⋮ control is present.
- The Personal Records header count reads **"5 sur 6"** (the FR `%lld of %lld` table entry),
  right-aligned on the light strip.
- The locked Marathon cell's value line reads **"Pas encore"**; earned medals keep their verbatim
  numeric values (00:00, 2095 ft, …) — numbers are never "translated".
- **Medal titles and section titles remain English** ("Personal Records", "Longest Run", …): they are
  data-supplied, server-localized in production — this is intended, not a localization gap
  (02-data-contract.md).
- Layout, colors, and locked ghosting identical to the EN grid (the switch changes strings only).
