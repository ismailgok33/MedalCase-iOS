import DesignSystem
import MedalDomain
import MedalTestSupport
import Testing
@testable import AchievementsFeature

@Suite("AchievementsViewModel — state machine (R2, R1)")
@MainActor
struct AchievementsViewModelTests {
    private func marathonStatus(_ viewModel: AchievementsViewModel) -> AchievementStatus? {
        guard case let .loaded(achievements) = viewModel.state else { return nil }
        return achievements.sections
            .flatMap(\.medals)
            .first { $0.id == AchievementsViewModel.marathonDemoID }?
            .status
    }

    @Test("a successful load sets .loaded")
    func test_achievementsViewModel_loadSuccess_setsLoaded() async {
        let viewModel = AchievementsViewModel(
            repository: MockAchievementsRepository(result: .success(AchievementFixtures.canonicalCase))
        )
        await viewModel.load()
        guard case let .loaded(achievements) = viewModel.state else {
            Issue.record("expected .loaded, got \(viewModel.state)")
            return
        }
        #expect(achievements.sections.count == 2)
    }

    @Test("a successful load preserves section and medal order (R1.1/R1.3)")
    func test_achievementsViewModel_loadSuccess_preservesSectionAndMedalOrder() async {
        let viewModel = AchievementsViewModel(
            repository: MockAchievementsRepository(result: .success(AchievementFixtures.canonicalCase))
        )
        await viewModel.load()
        guard case let .loaded(achievements) = viewModel.state else {
            Issue.record("expected .loaded")
            return
        }
        #expect(achievements.sections.map(\.id) == ["personal_records", "virtual_races"])
        #expect(achievements.sections[0].medals.first?.id == "pr_longest_run")
        #expect(achievements.sections[0].medals.last?.id == "pr_marathon")
    }

    @Test("a load returning no medals sets .empty (R2.3)")
    func test_achievementsViewModel_loadEmpty_setsEmpty() async {
        let viewModel = AchievementsViewModel(
            repository: MockAchievementsRepository(result: .success(AchievementFixtures.emptyCase))
        )
        await viewModel.load()
        #expect(viewModel.state == .empty)
    }

    @Test("a load failure sets .error with a retryable message (R2.2)")
    func test_achievementsViewModel_loadFailure_setsErrorWithRetry() async {
        let viewModel = AchievementsViewModel(
            repository: MockAchievementsRepository(result: .failure(MedalError.decoding))
        )
        await viewModel.load()
        guard case let .error(error) = viewModel.state else {
            Issue.record("expected .error, got \(viewModel.state)")
            return
        }
        #expect(error.isRetryable)
    }

    @Test("retry after a failure reloads to .loaded and re-invokes the repository")
    func test_achievementsViewModel_retry_reloadsAfterFailure() async {
        let mock = MockAchievementsRepository(result: .failure(MedalError.decoding))
        let viewModel = AchievementsViewModel(repository: mock)
        await viewModel.load()
        #expect({
            if case .error = viewModel.state {
                true
            } else {
                false
            }
        }())

        mock.result = .success(AchievementFixtures.canonicalCase)
        await viewModel.retry()
        #expect({
            if case .loaded = viewModel.state {
                true
            } else {
                false
            }
        }())
        #expect(mock.callCount == 2)
    }

    @Test("the demo action flips the Marathon medal earned↔locked (R1.6)")
    func test_achievementsViewModel_toggleMarathonDemo_flipsStatus() async {
        let viewModel = AchievementsViewModel(
            repository: MockAchievementsRepository(result: .success(AchievementFixtures.canonicalCase))
        )
        await viewModel.load()
        #expect(marathonStatus(viewModel) == .locked)

        viewModel.toggleMarathonDemo()
        #expect(marathonStatus(viewModel) == .earned(nil))

        viewModel.toggleMarathonDemo()
        #expect(marathonStatus(viewModel) == .locked)
    }
}
