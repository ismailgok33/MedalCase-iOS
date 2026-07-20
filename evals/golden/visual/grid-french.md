# Visual golden — achievements grid, French (in-app switcher)

**Image:** `docs/media/04-fr.png` (running app, iPhone 17, light appearance, launched in FR — the
state the in-app EN/FR switcher produces, ADR-0012 + ADR-0013).

## Intent (what must be visually true)
- The teal bar title reads **"Réalisations"** (white, small, centered) — the principal-item title
  re-resolved in French; the trailing ⋮ control is present.
- The Personal Records header reads **"Records personnels"** with the count **"5 sur 6"**
  right-aligned on the light strip; the second header reads **"Courses virtuelles"** — section titles
  are content, served by the FR payload variant (ADR-0013).
- Generic medal titles are French ("Course la plus longue", "Altitude la plus élevée",
  "5 km le plus rapide", "10 km", "Demi-marathon", "Course virtuelle de …"); **brand race names stay
  verbatim** ("Tokyo-Hakone Ekiden 2020", "Hakone Ekiden", "Mizuno Singapore Ekiden 2015") — brands
  are not translated, by contract.
- The locked Marathon cell's value line reads **"Pas encore"**; earned medals keep their verbatim
  numeric values (00:00, 2095 ft, …) — numbers are never "translated" (ADR-0010; "ft" → "pi" is a
  documented production step).
- Longer French titles ("Course virtuelle de demi-marathon") wrap to extra lines rather than
  truncate — no ellipsis anywhere.
- Layout, colors, badge order, and locked ghosting identical to the EN grid: the language switch
  changes *how it reads*, never *what is shown* (the parity invariant, ADR-0013).
