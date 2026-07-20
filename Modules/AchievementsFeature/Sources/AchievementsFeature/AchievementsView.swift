import DesignSystem
import MedalDomain
import SwiftUI

/// The medal-case screen. A declarative switch over `ViewState`: skeleton while loading, the grid when
/// loaded, calm empty and retryable error surfaces otherwise. The App wraps this in a `NavigationStack`
/// and applies the teal bar appearance (composition root); the feature owns its title and demo menu.
public struct AchievementsView: View {
    @State private var viewModel: AchievementsViewModel
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @AppStorage(AppLanguage.storageKey) private var appLanguage = AppLanguage.systemDefault.rawValue

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
            .toolbar {
                principalTitle
                demoMenu
            }
            .medalCaseNavigationBar()
            // Applied outermost-of-the-subtree so every localization-table lookup below — title, menu,
            // cells, state surfaces — re-resolves live when the reviewer flips the language (ADR-0012).
            .environment(\.locale, Locale(identifier: appLanguage))
            // New identity per language: toolbar content is bridged into the UIKit bar, which can hold
            // on to already-resolved text; re-creating the subtree guarantees the flip is total.
            .id(appLanguage)
            // ORDER IS LOAD-BEARING: `.task`/`.onChange` must sit OUTSIDE the `.id` boundary. Inside
            // it, the language switch replaces the subtree wholesale — `.onChange` never fires and
            // `.task` re-runs `load()` (a `.loading` flip that destroys on-screen content), turning
            // `refreshContent()` into dead code. Caught by the adversarial review's SwiftUI probe.
            .task { await viewModel.load() }
            // Content follows the language too (ADR-0013): re-fetch so the repository serves the new
            // language's payload — the client-side analog of re-requesting on an Accept-Language change.
            .onChange(of: appLanguage) {
                Task { await viewModel.refreshContent() }
            }
    }

    /// The bar title as a `principal` toolbar item, not `navigationTitle`: a navigationTitle Text is
    /// hoisted into the UIKit bar and resolves against the app's system language, escaping the SwiftUI
    /// locale environment — it would stay English after the in-app switch (ADR-0012). A principal item
    /// is an in-tree view, so it re-resolves like every other Text; it also takes the mock's exact
    /// 16px navTitle token rather than the system title font.
    @ToolbarContentBuilder
    private var principalTitle: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text("Achievements", bundle: .module)
                .medalFont(Typography.navTitle)
                .foregroundStyle(SemanticColor.navTitle)
                .accessibilityAddTraits(.isHeader)
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            AchievementsGridSkeleton()
        case let .loaded(achievements):
            grid(achievements)
        case .empty:
            EmptyStateView(message: Text("You haven't earned any medals yet.", bundle: .module))
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
            languageMenu
            Button { viewModel.toggleMarathonDemo() } label: {
                Text("Toggle Marathon (demo)", bundle: .module)
            }
            Button { Task { await viewModel.reset() } } label: {
                Text("Reset", bundle: .module)
            }
        } label: {
            Image(systemName: "ellipsis")
                .rotationEffect(Self.verticalEllipsisAngle)
                .foregroundStyle(SemanticColor.navTitle)
                // LocalizedStringResource with an explicit module bundle; rendered through Text under
                // the locale environment it follows the app's effective language, like every
                // accessibility label (accessibility.md).
                .accessibilityLabel(Text(LocalizedStringResource(
                    "More options",
                    bundle: .atURL(Bundle.module.bundleURL)
                )))
        }
        .accessibilityIdentifier("overflow-menu")
    }

    /// EN/FR switcher (R1.6, ADR-0012) — a "Language" submenu of buttons with a checkmark on the
    /// current selection (mirroring Picker semantics). Buttons rather than a Picker so each row can
    /// carry a stable `accessibilityIdentifier`: the switcher UI test must address rows
    /// language-independently — it cannot pin the language via a launch argument, because an
    /// `-app_language` argument registers in `NSArgumentDomain`, which shadows every AppStorage write
    /// and would make the switch unobservable (the exact bug the first version of the test had).
    /// Language names display verbatim in their own language.
    private var languageMenu: some View {
        Menu {
            ForEach(AppLanguage.allCases) { language in
                Button {
                    appLanguage = language.rawValue
                } label: {
                    if language.rawValue == appLanguage {
                        Label { Text(verbatim: language.displayName) } icon: { Image(systemName: "checkmark") }
                    } else {
                        Text(verbatim: language.displayName)
                    }
                }
                .accessibilityIdentifier("language-\(language.rawValue)")
            }
        } label: {
            Label { Text("Language", bundle: .module) } icon: { Image(systemName: "globe") }
        }
        .accessibilityIdentifier("language-menu")
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
