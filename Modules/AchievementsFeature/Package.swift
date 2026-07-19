// swift-tools-version: 6.0
import PackageDescription

/// AchievementsFeature — the medal-case screen: ViewModel + grid (ADR-0003). A leaf in the graph:
/// depends on MedalDomain + DesignSystem only, never MedalData (the App injects the repository) and
/// never another feature. Test target adds MedalTestSupport for the shared mocks/fixtures.
let package = Package(
    name: "AchievementsFeature",
    defaultLocalization: "en",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "AchievementsFeature", targets: ["AchievementsFeature"])
    ],
    dependencies: [
        .package(path: "../MedalDomain"),
        .package(path: "../DesignSystem"),
        .package(path: "../MedalTestSupport")
    ],
    targets: [
        .target(
            name: "AchievementsFeature",
            dependencies: ["MedalDomain", "DesignSystem"]
        ),
        .testTarget(
            name: "AchievementsFeatureTests",
            dependencies: ["AchievementsFeature", "MedalDomain", "MedalTestSupport"]
        )
    ]
)
