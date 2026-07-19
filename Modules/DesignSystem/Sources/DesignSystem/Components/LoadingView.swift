import SwiftUI

/// The generic loading surface. The grid uses `AchievementsGridSkeleton` for a richer skeleton; this
/// is the fallback spinner for simpler contexts.
public struct LoadingView: View {
    public init() {}

    public var body: some View {
        ProgressView()
            .accessibilityLabel(Text("Loading", bundle: .module))
    }
}
