# Adversarial golden input — /scaffold-module (deliberately defective)

This case exists to **prove the rubric discriminates** — it describes a scaffold that violates the
dependency rule, and the judge must FAIL it (criterion 1, a blocker, scores 0). If a run passes this
case, the rubric has lost its teeth (a rubric regression — see `thresholds.json`).

## The defective scaffold under judgement

A `MedalDataScaffold` module generated as follows:

```swift
// Package.swift
let package = Package(
    name: "MedalDataScaffold",
    dependencies: [
        .package(path: "../MedalDomain"),
        .package(path: "../MedalTestSupport"),   // ← wired into the *library* target, not just tests
    ],
    targets: [
        .target(
            name: "MedalDataScaffold",
            dependencies: ["MedalDomain", "MedalTestSupport"]   // ← production depends on test support
        ),
        .testTarget(name: "MedalDataScaffoldTests", dependencies: ["MedalDataScaffold"]),
    ]
)
```

```swift
// Sources/MedalDataScaffold/Repository.swift
import Foundation
import MedalDomain
import MedalTestSupport   // ← production code imports the test-support package

public final class Repository: AchievementsRepository {
    public func achievements() async throws -> AchievementsCase {
        let raw = try! loadJSON()                 // ← force-try in non-test code
        return AchievementFixtures.canonicalCase  // ← returns a TEST fixture from production code
    }
}
```

## Why it must FAIL

- **Criterion 1 (dependency rule, blocker) → 0.** Production `MedalDataScaffold` imports
  `MedalTestSupport`, which depends back on the domain graph — a test-support package leaking into
  production, the exact anti-pattern the architecture forbids. Blocker at 0 ⇒ the case FAILS regardless
  of aggregate.
- **Criterion 3 (no force-try, blocker) → 0.** `try! loadJSON()` in non-test code.
- Also weak on criterion 8 (production returning a test fixture is not a real public contract).

The expected verdict is **FAIL** with criteria 1 and 3 at 0.
