import Testing
@testable import MedalDomain

@Suite("AchievementSection — computed progress counts (ADR-0008)")
struct AchievementSectionTests {
    private func medal(_ id: String, _ status: AchievementStatus) -> Achievement {
        Achievement(id: id, type: "t", title: id, assetKey: id, status: status)
    }

    @Test("earnedCount counts only earned; totalCount counts all (mock: 5 of 6)")
    func test_achievementSection_earnedCount_countsOnlyEarned() {
        let section = AchievementSection(
            id: "personal_records",
            title: "Personal Records",
            showsProgressCount: true,
            medals: [
                medal("a", .earned(.duration(seconds: 0, style: .minutesSeconds))),
                medal("b", .earned(.elevation(feet: 2095))),
                medal("c", .earned(.duration(seconds: 0, style: .minutesSeconds))),
                medal("d", .earned(.duration(seconds: 0, style: .hoursMinutesSeconds))),
                medal("e", .earned(.duration(seconds: 0, style: .minutesSeconds))),
                medal("f", .locked)
            ]
        )
        #expect(section.earnedCount == 5)
        #expect(section.totalCount == 6)
    }

    @Test("an all-locked section reports zero earned")
    func test_achievementSection_allLocked_earnedCountIsZero() {
        let section = AchievementSection(
            id: "s", title: "S", showsProgressCount: true,
            medals: [medal("a", .locked), medal("b", .locked)]
        )
        #expect(section.earnedCount == 0)
        #expect(section.totalCount == 2)
    }

    @Test("an earned medal with a nil value still counts as earned (P3)")
    func test_achievementSection_earnedNilValue_countsAsEarned() {
        let section = AchievementSection(
            id: "s", title: "S", showsProgressCount: true,
            medals: [medal("a", .earned(nil))]
        )
        #expect(section.earnedCount == 1)
    }
}
