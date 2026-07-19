import MedalDomain
import Testing
@testable import MedalData

@Suite("DefaultAchievementsRepository — load + map + error surfacing")
struct DefaultAchievementsRepositoryTests {
    @Test("loads the bundled fixture and maps it to domain (5 of 6 PRs, locked Marathon, 6 races)")
    func test_repository_load_mapsBundledFixtureToDomain() async throws {
        let repository = DefaultAchievementsRepository()
        let result = try await repository.achievements()

        #expect(result.sections.count == 2)

        let personalRecords = try #require(result.sections.first)
        #expect(personalRecords.id == "personal_records")
        #expect(personalRecords.showsProgressCount)
        #expect(personalRecords.earnedCount == 5)
        #expect(personalRecords.totalCount == 6)
        #expect(personalRecords.medals.last?.status == .locked) // Marathon

        let races = result.sections[1]
        #expect(races.id == "virtual_races")
        #expect(!races.showsProgressCount)
        #expect(races.medals.count == 6)
        // The Virtual 5K, 23:07 = 1387s, minutes:seconds.
        #expect(races.medals.last?.status == .earned(.duration(seconds: 1387, style: .minutesSeconds)))
    }

    @Test("a data-source failure surfaces as a MedalError")
    func test_repository_dataSourceThrows_surfacesMedalError() async {
        let repository = DefaultAchievementsRepository(
            dataSource: MockAchievementsDataSource(result: .failure(MedalError.decoding))
        )
        await #expect(throws: MedalError.decoding) {
            try await repository.achievements()
        }
    }
}
