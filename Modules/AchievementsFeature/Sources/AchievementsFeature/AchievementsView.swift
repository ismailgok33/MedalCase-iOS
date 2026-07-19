import DesignSystem
import MedalDomain
import SwiftUI

/// The medal-case screen. A declarative switch over `ViewState`: skeleton while loading, the grid when
/// loaded, calm empty and retryable error surfaces otherwise. The App wraps this in a `NavigationStack`
/// and applies the teal bar appearance (composition root); the feature owns its title and demo menu.
public struct AchievementsView: View {
    @State private var viewModel: AchievementsViewModel

    private let columns = [
        GridItem(.flexible(), spacing: Spacing.columnSpacing),
        GridItem(.flexible(), spacing: Spacing.columnSpacing)
    ]

    public init(viewModel: AchievementsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        content
            .navigationTitle("Achievements")
            .toolbar { demoMenu }
            .task { await viewModel.load() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            AchievementsGridSkeleton()
        case let .loaded(achievements):
            grid(achievements)
        case .empty:
            EmptyStateView(message: "You haven't earned any medals yet.")
        case let .error(error):
            ErrorStateView(message: error.message, isRetryable: error.isRetryable) {
                Task { await viewModel.retry() }
            }
        }
    }

    private func grid(_ achievements: AchievementsCase) -> some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(achievements.sections) { section in
                    SectionHeaderView(title: section.title, progress: SectionProgress.value(for: section))
                    LazyVGrid(columns: columns, spacing: Spacing.gridGutter) {
                        ForEach(section.medals) { medal in
                            MedalCellView(medal: medal)
                        }
                    }
                    .padding(Spacing.gridGutter)
                }
            }
        }
        .background(SemanticColor.surface)
    }

    @ToolbarContentBuilder
    private var demoMenu: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Menu {
                Button("Toggle Marathon (demo)") { viewModel.toggleMarathonDemo() }
                Button("Reset") { Task { await viewModel.reset() } }
            } label: {
                Image(systemName: "ellipsis")
                    .accessibilityLabel("More options")
            }
        }
    }
}

#if DEBUG
    /// Preview-only repository + sample data, kept inline so the production target never depends on
    /// `MedalTestSupport` (that stays a test-target concern). Stripped from release builds.
    private struct PreviewRepository: AchievementsRepository {
        let result: Result<AchievementsCase, any Error>
        func achievements() async throws -> AchievementsCase {
            try result.get()
        }
    }

    private enum PreviewData {
        static let loaded = AchievementsCase(sections: [
            AchievementSection(id: "personal_records", title: "Personal Records", showsProgressCount: true, medals: [
                Achievement(
                    id: "pr_longest_run",
                    type: "longest_run",
                    title: "Longest Run",
                    assetKey: "pr_longest_run",
                    status: .earned(.duration(seconds: 0, style: .minutesSeconds))
                ),
                Achievement(
                    id: "pr_highest_elevation",
                    type: "highest_elevation",
                    title: "Highest Elevation",
                    assetKey: "pr_highest_elevation",
                    status: .earned(.elevation(feet: 2095))
                ),
                Achievement(
                    id: "pr_fastest_5k",
                    type: "fastest_5k",
                    title: "Fastest 5K",
                    assetKey: "pr_fastest_5k",
                    status: .earned(.duration(seconds: 0, style: .minutesSeconds))
                ),
                Achievement(
                    id: "pr_marathon",
                    type: "fastest_marathon",
                    title: "Marathon",
                    assetKey: "pr_fastest_marathon",
                    status: .locked
                )
            ])
        ])
    }

    @MainActor
    private func previewScreen(_ result: Result<AchievementsCase, any Error>) -> some View {
        NavigationStack {
            AchievementsView(viewModel: AchievementsViewModel(repository: PreviewRepository(result: result)))
        }
    }

    #Preview("Loaded") { previewScreen(.success(PreviewData.loaded)) }
    #Preview("Empty") { previewScreen(.success(AchievementsCase(sections: []))) }
    #Preview("Error") { previewScreen(.failure(MedalError.decoding)) }
#endif
