# Visual golden — achievements grid, accessibility XXL

**Image:** `docs/media/03-xxl.png` (running app, iPhone 17, content size
`accessibility-extra-extra-extra-large`).

## Intent (the accessibility acceptance — R4.3)
- Every title and value is **enlarged** with Dynamic Type (the ScaledFont tokens scale the mock's
  point sizes), proving fonts are not fixed.
- The grid **reflows to a single column** at this accessibility size so cells grow rather than cramp.
- **No truncation:** long titles wrap to multiple lines fully visible — nothing is clipped or
  ellipsised (a truncated title is criterion-2 blocker = 0).
- The teal bar + inline title remain intact.
