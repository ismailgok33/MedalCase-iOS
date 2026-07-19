import AchievementsFeature
import MedalData
import SwiftUI

/// The composition root. Clean Architecture's one exemption to the dependency rule: the App target is
/// the single place allowed to see concrete types, so it instantiates `DefaultAchievementsRepository`
/// and injects it into the feature's ViewModel through the domain protocol, hosting the screen in a
/// `NavigationStack`.
///
/// The teal bar styling lives in the feature (`medalCaseNavigationBar`), so the App target does **not**
/// depend on `DesignSystem` directly — a resource-bearing package that Xcode's resolver mishandles as a
/// direct *app-target* dependency when it is also transitive (see `MedalCaseNavigationBar`).
struct RootView: View {
    var body: some View {
        NavigationStack {
            AchievementsView(
                viewModel: AchievementsViewModel(repository: DefaultAchievementsRepository())
            )
        }
    }
}
