import AchievementsFeature
import DesignSystem
import MedalData
import SwiftUI

/// The composition root. Clean Architecture's one exemption to the dependency rule: the App target is
/// the single place allowed to see concrete types, so it instantiates `DefaultAchievementsRepository`
/// and injects it into the feature's ViewModel through the domain protocol.
///
/// It hosts the screen in a `NavigationStack` styled with the mock's teal bar. The bar is styled with
/// SwiftUI's scoped `toolbarBackground` rather than a global `UINavigationBar.appearance()` mutation,
/// and swaps to the darkened high-contrast teal when Increased Contrast is on (accessibility.md).
struct RootView: View {
    @Environment(\.colorSchemeContrast) private var contrast

    var body: some View {
        NavigationStack {
            AchievementsView(
                viewModel: AchievementsViewModel(repository: DefaultAchievementsRepository())
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(tealBar, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private var tealBar: Color {
        contrast == .increased ? SemanticColor.brandTealHighContrast : SemanticColor.brandTeal
    }
}
