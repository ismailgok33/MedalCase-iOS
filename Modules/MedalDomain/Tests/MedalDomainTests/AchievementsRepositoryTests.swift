import Testing
@testable import MedalDomain

@Suite("AchievementsRepository — the async seam")
struct AchievementsRepositoryTests {
    @Test("a conforming repository returns its case through the async boundary")
    func test_achievementsRepository_success_returnsCase() async throws {
        let expected = AchievementsCase(sections: [
            AchievementSection(id: "s", title: "S", showsProgressCount: false, medals: [])
        ])
        let repository = StubAchievementsRepository(result: .success(expected))
        let result = try await repository.achievements()
        #expect(result == expected)
    }

    @Test("a failing repository propagates its MedalError")
    func test_achievementsRepository_failure_propagatesError() async {
        let repository = StubAchievementsRepository(result: .failure(MedalError.decoding))
        await #expect(throws: MedalError.decoding) {
            try await repository.achievements()
        }
    }
}
