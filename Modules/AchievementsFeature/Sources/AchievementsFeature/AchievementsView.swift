import DesignSystem
import MedalDomain
import SwiftUI

/// The medal-case screen. A declarative switch over `ViewState`: skeleton while loading, the grid when
/// loaded, calm empty and retryable error surfaces otherwise. The App wraps this in a `NavigationStack`
/// and applies the teal bar appearance (composition root); the feature owns its title and demo menu.
public struct AchievementsView: View {
    @State private var viewModel: AchievementsViewModel
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    /// Two columns normally (matching the mock); a single column at accessibility text sizes so cells
    /// grow rather than cramp — the reflow accessibility.md prescribes (R4.3).
    private var columns: [GridItem] {
        let count = dynamicTypeSize.isAccessibilitySize ? 1 : 2
        return Array(repeating: GridItem(.flexible(), spacing: Spacing.columnSpacing), count: count)
    }

    public init(viewModel: AchievementsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        content
            .navigationTitle("Achievements")
            .toolbar { demoMenu }
            .medalCaseNavigationBar()
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

    /// SF Symbols has no bare vertical ellipsis (only bubbled/circled variants), so the mock's ⋮ is
    /// the horizontal `ellipsis` rotated 90° — keeping SF Symbol weight-matching and scaling.
    private static let verticalEllipsisAngle = Angle.degrees(90)

    @ToolbarContentBuilder
    private var demoMenu: some ToolbarContent {
        // iOS 26's Liquid Glass wraps toolbar buttons in a capsule the mock doesn't have; hide it so
        // the glyph sits bare on the teal bar. Pre-26 systems render the bare glyph already.
        if #available(iOS 26.0, macOS 26.0, *) {
            ToolbarItem(placement: .primaryAction) { demoMenuButton }
                .sharedBackgroundVisibility(.hidden)
        } else {
            ToolbarItem(placement: .primaryAction) { demoMenuButton }
        }
    }

    private var demoMenuButton: some View {
        Menu {
            Button("Toggle Marathon (demo)") { viewModel.toggleMarathonDemo() }
            Button("Reset") { Task { await viewModel.reset() } }
        } label: {
            Image(systemName: "ellipsis")
                .rotationEffect(Self.verticalEllipsisAngle)
                .foregroundStyle(SemanticColor.navTitle)
                .accessibilityLabel("More options")
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
