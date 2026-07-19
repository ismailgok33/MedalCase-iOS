import SwiftUI

/// Typed access to the medal badge catalog, keyed by the data contract's `assetKey`. An unknown key
/// resolves to a neutral SF Symbol placeholder rather than a missing-image box (policy P5), so a medal
/// with unfamiliar art still renders its title and value.
public enum MedalAsset {
    /// How an `assetKey` resolves: a named catalog image, or the neutral placeholder (P5). The pure,
    /// testable seam that `image(for:)` renders — so P5's placeholder branch is asserted without a view.
    enum Resolution: Equatable {
        case catalog(String)
        case placeholder
    }

    /// The single source of truth for what the catalog contains: the 13 imagesets shipped in
    /// `MedalAssets.xcassets` (the 12 the fixture uses + the unused `race_virtual_marathon`, kept to
    /// prove the grid is data-driven — L4). Internal: only the module and its tests need it.
    static let knownKeys: Set<String> = [
        "pr_longest_run",
        "pr_highest_elevation",
        "pr_fastest_5k",
        "pr_fastest_10k",
        "pr_fastest_half_marathon",
        "pr_fastest_marathon",
        "race_virtual_half_marathon",
        "race_tokyo_hakone_ekiden_2020",
        "race_virtual_10k",
        "race_hakone_ekiden",
        "race_mizuno_singapore_ekiden",
        "race_virtual_5k",
        "race_virtual_marathon"
    ]

    /// Pure P5 decision — the testable seam.
    static func resolution(for key: String) -> Resolution {
        knownKeys.contains(key) ? .catalog(key) : .placeholder
    }

    /// The badge image for a key, or a neutral placeholder when the key is unknown (P5).
    public static func image(for key: String) -> Image {
        switch resolution(for: key) {
        case let .catalog(name):
            Image(name, bundle: .module)
        case .placeholder:
            Image(systemName: "rosette")
        }
    }
}
