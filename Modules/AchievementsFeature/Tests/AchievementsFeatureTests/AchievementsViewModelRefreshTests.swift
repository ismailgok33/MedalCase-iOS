import MedalDomain
import MedalTestSupport
import Testing
@testable import AchievementsFeature

/// `refreshContent()` (ADR-0013): the language-change re-fetch. Content is replaced in place — no
/// `.loading` flip while something is on screen, and a failed refresh keeps the current content
/// rather than destroying a loaded case with an error surface.
@MainActor
struct AchievementsViewModelRefreshTests {
    private static let frenchCase = AchievementsCase(sections: [
        AchievementSection(
            id: "personal_records",
            title: "Records personnels",
            showsProgressCount: true,
            medals: [
                Achievement(
                    id: "pr_marathon",
                    type: "fastest_marathon",
                    title: "Marathon",
                    assetKey: "pr_fastest_marathon",
                    status: .locked
                )
            ]
        )
    ])

    @Test func test_refreshContent_loaded_replacesContentInPlace() async {
        let repository = MockAchievementsRepository()
        let viewModel = AchievementsViewModel(repository: repository)
        await viewModel.load()

        repository.result = .success(Self.frenchCase)
        await viewModel.refreshContent()

        #expect(viewModel.state == .loaded(Self.frenchCase))
        #expect(repository.callCount == 2)
    }

    @Test func test_refreshContent_failure_keepsCurrentContent() async {
        let repository = MockAchievementsRepository()
        let viewModel = AchievementsViewModel(repository: repository)
        await viewModel.load()
        guard case let .loaded(before) = viewModel.state else {
            Issue.record("expected a loaded state before the refresh")
            return
        }

        repository.result = .failure(MedalError.emptyData)
        await viewModel.refreshContent()

        #expect(viewModel.state == .loaded(before))
    }

    @Test func test_refreshContent_fromErrorState_performsFullLoad() async {
        let repository = MockAchievementsRepository(result: .failure(MedalError.emptyData))
        let viewModel = AchievementsViewModel(repository: repository)
        await viewModel.load()

        repository.result = .success(Self.frenchCase)
        await viewModel.refreshContent()

        #expect(viewModel.state == .loaded(Self.frenchCase))
    }
}
