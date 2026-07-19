import MedalDomain
import Testing
@testable import MedalData

@Suite("Bundled resource ≡ canonical fixture")
struct BundledResourceTests {
    @Test("the packaged achievements.json loads and decodes to the canonical content")
    func test_bundledResource_matchesCanonicalFixture() async throws {
        let document = try await BundledAchievementsDataSource().load()

        #expect(document.schemaVersion == 1)
        #expect(document.sections.count == 2)

        let personalRecords = try #require(document.sections.first)
        #expect(personalRecords.id == "personal_records")
        #expect(personalRecords.showsProgressCount)
        #expect(personalRecords.medals.count == 6)
        // Marathon is the 6th PR — locked, no value (P6/L1).
        #expect(personalRecords.medals[5].status == "locked")
        #expect(personalRecords.medals[5].value == nil)

        let races = document.sections[1]
        #expect(races.id == "virtual_races")
        #expect(!races.showsProgressCount)
        #expect(races.medals.count == 6)
        // Virtual 5K, 23:07 = 1387s.
        let virtual5k = races.medals[5]
        #expect(virtual5k.value?.seconds == 1387)
        #expect(virtual5k.value?.style == "minutes_seconds")
    }
}
