# ADR-0011 — The App target avoids directly depending on a resource-bearing package

**Status:** accepted (post-M8 fix)

## Context
Opening the committed `.xcodeproj` in Xcode 26 failed to build with **"Missing package product
'DesignSystem'" / "'MedalData'"** (in target `MedalCase`), and the Xcode navigator showed those two
packages duplicated across "Packages" and "Package Dependencies". Yet `xcodebuild` on the command line
and CI built the exact same project cleanly.

Root cause, isolated empirically: **`DesignSystem` and `MedalData` are the only two local packages that
ship resources** (the asset catalog; `achievements.json`). Xcode's GUI package resolver mishandles a
local, resource-bearing package when the **App target depends on it directly** *and* the same package is
also a transitive dependency — it creates a duplicate resolved node, and the app target's
product reference (which XcodeGen emits by product name, with no explicit `package =` link) can't bind.
The reference project (LocalSakeShop) has the identical multi-package/resource shape and builds — the
one difference is that **its App target does not depend on `DesignSystem` directly** (it arrives
transitively through the features). `xcodebuild`/CI resolve per-scheme and tolerate the ambiguity, which
is why only the GUI failed.

## Decision
The **App target depends only on `MedalDomain`, `MedalData`, and `AchievementsFeature`** — never on
`DesignSystem` directly. The single app-level `DesignSystem` use (the teal navigation-bar color) is
routed through the feature: `AchievementsView` applies a `medalCaseNavigationBar()` modifier
(`MedalCaseNavigationBar`, iOS-guarded) that lives in `AchievementsFeature` and reads the DesignSystem
tokens there. `RootView` becomes a pure composition root (repository injection + `NavigationStack`).

## Consequences
The committed project opens and builds in the Xcode GUI, matching CLI/CI. The composition root is
leaner; the feature owns its own nav-bar chrome (a defensible ownership choice). `MedalData` stays a
direct app dependency (the composition root must construct the concrete repository) — that is fine
because it is **not** also transitive, so no duplicate node forms (the same shape as LocalSakeShop's
working `SakeData` dependency). Trade-off: a reviewer reading `project.yml` sees a deliberate comment
explaining why `DesignSystem` is absent from the app target — a subtlety, but a documented one.
