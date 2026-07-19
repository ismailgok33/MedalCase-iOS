# Visual golden — the locked Marathon cell, French

**Image:** `MedalCaseSnapshotTests/__Snapshots__/MedalComponentSnapshotTests/test_medalCell_locked_fr.1.png`
(the committed FR snapshot baseline — rendered under `\.locale = fr`, ADR-0012).

## Intent (locked rendering × localization)
- The Marathon badge is **ghosted** (desaturated + dimmed — ADR-0007), identical treatment to the EN
  locked cell.
- The value line reads the **French** localized locked value: **"Pas encore"** — not "Not Yet", and
  not a duration.
- The medal **title stays "Marathon"** (titles are data-supplied and deliberately not client-localized
  — 02-data-contract.md).
- Title and value are fully visible, centered under the badge, with no clipping.
