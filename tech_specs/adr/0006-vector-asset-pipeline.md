# ADR-0006 — Vector asset pipeline (PDF badges)

**Status:** accepted (M1)

## Context
The brief supplies 13 PDF vector badges and instructs "use them as vector images". Badges render at
cell size normally but much larger under accessibility Dynamic Type; filenames are inconsistent
(hyphens vs snake_case, an unused 7th race asset).

## Decision
Import every PDF into the **DesignSystem** package's asset catalog under normalized names
(`pr_*` / `race_*`), configured **Single Scale + Preserve Vector Data** so the system rasterizes
from the vector at whatever size is rendered — crisp at XXL, no `@2x/@3x` pre-rasters. Views access
badges only through a typed `MedalAsset` catalog keyed by the contract's `asset_key` (policy P5:
unknown key → placeholder badge). The unused `virtual_marathon_race` ships in the catalog,
unreferenced by the fixture (L4 — proof the grid is data-driven).

## Consequences
One asset per medal serves all sizes and both color schemes; no scattered image-name string
literals; decode cost stays one-per-badge at display size (`performance-battery.md`). Cost:
Preserve Vector Data re-rasterizes when the rendered size changes — irrelevant for a static grid.
