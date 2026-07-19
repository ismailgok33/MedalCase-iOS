import MedalDomain
import MedalTestSupport
import Testing
@testable import AchievementsFeature

@Suite("SectionProgress — count shown only when the section declares it (R1.2, ADR-0008)")
struct SectionProgressTests {
    @Test("a section that shows the count reports (earned, total) computed from data")
    func test_sectionHeader_progress_shownWhenDeclared() {
        let personalRecords = AchievementFixtures.canonicalCase.sections[0]
        let progress = SectionProgress.value(for: personalRecords)
        #expect(progress?.earned == 5)
        #expect(progress?.total == 6)
    }

    @Test("a section that does not show the count reports nil")
    func test_sectionHeader_progress_shownOnlyWhenDeclared() {
        let virtualRaces = AchievementFixtures.canonicalCase.sections[1]
        #expect(SectionProgress.value(for: virtualRaces) == nil)
    }
}
