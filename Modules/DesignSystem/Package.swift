// swift-tools-version: 6.0
import PackageDescription

/// DesignSystem — reusable SwiftUI tokens, the medal asset catalog, and stateless components
/// (ADR-0003). Depends on SwiftUI only (a system framework, not a package). macOS is declared so the
/// pure-logic tests run in the fast `swift test` loop; UIKit-only pieces are `#if canImport`-guarded.
let package = Package(
    name: "DesignSystem",
    defaultLocalization: "en",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "DesignSystem", targets: ["DesignSystem"])
    ],
    targets: [
        .target(
            name: "DesignSystem",
            resources: [.process("Resources/MedalAssets.xcassets")]
        ),
        .testTarget(name: "DesignSystemTests", dependencies: ["DesignSystem"])
    ]
)
