import AchievementsFeature
import MedalData
import MedalDomain
import Testing

/// The one place the *real* stack meets: `DefaultAchievementsRepository` (bundled fixture) → the
/// domain mapper → the feature ViewModel — no mock. Proves the composed app loads the mock's data into
/// the "5 of 6" loaded state end-to-end.
@Suite("App integration — real repository through the ViewModel")
@MainActor
struct AppIntegrationTests {
    @Test("the composed stack loads the bundled fixture into a 5-of-6 loaded state")
    func test_app_realRepository_loadsBundledFixtureToLoaded() async {
        let viewModel = AchievementsViewModel(repository: DefaultAchievementsRepository())
        await viewModel.load()

        guard case let .loaded(achievements) = viewModel.state else {
            Issue.record("expected .loaded, got \(viewModel.state)")
            return
        }
        #expect(achievements.sections.count == 2)

        let personalRecords = achievements.sections[0]
        #expect(personalRecords.id == "personal_records")
        #expect(personalRecords.earnedCount == 5)
        #expect(personalRecords.totalCount == 6)
        #expect(personalRecords.medals.last?.isEarned == false) // Marathon locked

        #expect(achievements.sections[1].id == "virtual_races")
        #expect(achievements.sections[1].medals.count == 6)
    }
}
