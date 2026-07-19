// swift-tools-version: 6.0
import PackageDescription

/// MedalDomain — the pure-Swift domain layer (ADR-0003). Depends on nothing: no SwiftUI, no UIKit,
/// no Foundation networking, no other module. macOS is declared alongside iOS purely so the fast
/// `swift test` inner loop runs on the host; the module ships iOS.
let package = Package(
    name: "MedalDomain",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "MedalDomain", targets: ["MedalDomain"])
    ],
    targets: [
        .target(name: "MedalDomain"),
        .testTarget(name: "MedalDomainTests", dependencies: ["MedalDomain"])
    ]
)
