# Visual golden — achievements grid, light mode

**Image:** `docs/media/01-light.png` (running app, iPhone 17, light appearance, default Dynamic Type).

## Intent (what must be visually true)
- A **teal** (`#63C6D4`) navigation bar with a small, centered, **white** "Achievements" title and a
  trailing overflow (⋮) control.
- A **"Personal Records"** section header on a light (`#F7F7F7`) strip with a right-aligned **"5 of 6"**
  count (data-driven — matches the 5 earned + 1 locked medals shown; the mock's own "4 of 6" is
  unsatisfiable, ADR-0008).
- A **2-column** grid of the six PR medals with shield badges: Longest Run 00:00, Highest Elevation
  2095 ft, Fastest 5K 00:00, 10K 00:00:00, Half Marathon 00:00, and **Marathon ghosted with "Not Yet"**.
- A **"Virtual Races"** section header, then hexagonal Asics race medals (Virtual Half Marathon Race,
  Tokyo-Hakone Ekiden 2020, …) with their values.
- No truncation of any title; clean 2-column alignment; colors match the mock's annotations.
