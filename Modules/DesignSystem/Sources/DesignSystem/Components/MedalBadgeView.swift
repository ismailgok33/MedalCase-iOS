import SwiftUI

/// The badge image for a cell: the catalog art at a fixed display size, ghosted when locked
/// (ADR-0007). Decorative — the enclosing cell owns the accessibility label, so VoiceOver reads the
/// medal once, not twice.
public struct MedalBadgeView: View {
    private let assetKey: String
    private let isLocked: Bool

    public init(assetKey: String, isLocked: Bool) {
        self.assetKey = assetKey
        self.isLocked = isLocked
    }

    public var body: some View {
        MedalAsset.image(for: assetKey)
            .resizable()
            .scaledToFit()
            .frame(width: Spacing.badgeSize, height: Spacing.badgeSize)
            .modifier(GhostedMedal(isActive: isLocked))
            .accessibilityHidden(true)
    }
}
