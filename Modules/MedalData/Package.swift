// swift-tools-version: 6.0
import PackageDescription

/// MedalData — the data layer (ADR-0003, ADR-0004). Implements MedalDomain's protocols; imports no UI.
/// Ships the bundled achievements fixture as a resource and is the seam a remote source would slot into.
let package = Package(
    name: "MedalData",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "MedalData", targets: ["MedalData"])
    ],
    dependencies: [
        .package(path: "../MedalDomain")
    ],
    targets: [
        .target(
            name: "MedalData",
            dependencies: ["MedalDomain"],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "MedalDataTests",
            dependencies: ["MedalData", "MedalDomain"]
        )
    ]
)
