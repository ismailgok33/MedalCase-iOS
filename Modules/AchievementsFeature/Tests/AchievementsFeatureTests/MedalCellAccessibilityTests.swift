import Foundation
import MedalDomain
import MedalTestSupport
import Testing
@testable import AchievementsFeature

@Suite("Medal cell accessibility label (R4.1)")
struct MedalCellAccessibilityTests {
    @Test("an earned medal reads «title», «value»")
    func test_medalCell_accessibilityLabel_earned() {
        let medal = AchievementFixtures.earnedDuration(
            title: "Virtual 5K Race", seconds: 1387, style: .minutesSeconds
        )
        #expect(String(localized: MedalAccessibility.label(for: medal)) == "Virtual 5K Race, 23:07")
    }

    @Test("a locked medal reads «title», not yet earned")
    func test_medalCell_accessibilityLabel_locked() {
        let medal = AchievementFixtures.lockedMarathon()
        #expect(String(localized: MedalAccessibility.label(for: medal)) == "Marathon, not yet earned")
    }

    @Test("an earned medal with no value reads just the title")
    func test_medalCell_accessibilityLabel_earnedNoValue() {
        let medal = Achievement(id: "x", type: "t", title: "Mystery", assetKey: "k", status: .earned(nil))
        #expect(String(localized: MedalAccessibility.label(for: medal)) == "Mystery")
    }
}
