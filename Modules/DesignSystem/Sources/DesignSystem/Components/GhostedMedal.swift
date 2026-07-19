import SwiftUI

/// Derives the locked-medal look from the earned badge — desaturated and dimmed — so no separate
/// locked asset is needed (ADR-0007). One reusable, snapshot-tested modifier.
public struct GhostedMedal: ViewModifier {
    private let isActive: Bool

    public init(isActive: Bool) {
        self.isActive = isActive
    }

    public func body(content: Content) -> some View {
        content
            .saturation(isActive ? 0 : 1)
            .opacity(isActive ? Opacity.ghosted : 1)
    }
}
