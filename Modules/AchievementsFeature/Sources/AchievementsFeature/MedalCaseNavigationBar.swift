import DesignSystem
import SwiftUI

/// The mock's teal navigation bar, applied by the feature (not the App target).
///
/// Keeping this here means the **App target never directly depends on `DesignSystem`** — a
/// resource-bearing package that is also a transitive dependency (via this feature). An app target that
/// directly depends on such a package trips Xcode's package resolver ("Missing package product"), even
/// though `xcodebuild`/CI tolerate it; routing the one DesignSystem use (the teal color) through the
/// feature avoids it. Scoped SwiftUI toolbar styling, not a global `UINavigationBar.appearance()`
/// mutation; swaps to the darkened high-contrast teal under Increased Contrast (accessibility.md).
///
/// iOS-only: the `navigationBar` toolbar placement is unavailable on macOS, where this package also
/// builds for the fast `swift test` loop.
struct MedalCaseNavigationBar: ViewModifier {
    #if os(iOS)
        @Environment(\.colorSchemeContrast) private var contrast
    #endif

    func body(content: Content) -> some View {
        #if os(iOS)
            content
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(tealBackground, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarColorScheme(.dark, for: .navigationBar)
        #else
            content
        #endif
    }

    #if os(iOS)
        private var tealBackground: Color {
            contrast == .increased ? SemanticColor.brandTealHighContrast : SemanticColor.brandTeal
        }
    #endif
}

public extension View {
    /// Applies the medal case's teal navigation-bar styling (iOS; a no-op elsewhere).
    func medalCaseNavigationBar() -> some View {
        modifier(MedalCaseNavigationBar())
    }
}
