// swift-tools-version: 6.0
import PackageDescription

/// MedalTestSupport — shared test material (mocks + fixtures) so no test inlines a double (ADR-0009).
/// Depends on MedalDomain only; linked by downstream test targets (AchievementsFeature, app tests).
/// It has no test target of its own — its correctness is exercised transitively by every consumer.
let package = Package(
    name: "MedalTestSupport",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "MedalTestSupport", targets: ["MedalTestSupport"])
    ],
    dependencies: [
        .package(path: "../MedalDomain")
    ],
    targets: [
        .target(name: "MedalTestSupport", dependencies: ["MedalDomain"])
    ]
)
