import Testing
@testable import MedalDomain

@Suite("Achievement & AchievementsCase — status and emptiness")
struct AchievementTests {
    @Test("isEarned is true for earned (with or without a value), false for locked")
    func test_achievement_isEarned_reflectsStatus() {
        let earned = Achievement(
            id: "1",
            type: "t",
            title: "T",
            assetKey: "k",
            status: .earned(.elevation(feet: 10))
        )
        let earnedNoValue = Achievement(
            id: "2",
            type: "t",
            title: "T",
            assetKey: "k",
            status: .earned(nil)
        )
        let locked = Achievement(id: "3", type: "t", title: "T", assetKey: "k", status: .locked)
        #expect(earned.isEarned)
        #expect(earnedNoValue.isEarned)
        #expect(!locked.isEarned)
    }

    @Test("hasNoMedals is true only when every section is empty (R2.3)")
    func test_achievementsCase_hasNoMedals_reflectsEmptiness() {
        let empty = AchievementsCase(sections: [
            AchievementSection(id: "a", title: "A", showsProgressCount: false, medals: [])
        ])
        let populated = AchievementsCase(sections: [
            AchievementSection(id: "a", title: "A", showsProgressCount: false, medals: [
                Achievement(id: "1", type: "t", title: "T", assetKey: "k", status: .locked)
            ])
        ])
        #expect(empty.hasNoMedals)
        #expect(!populated.hasNoMedals)
    }
}
