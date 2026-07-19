import AchievementsFeature
import DesignSystem
import MedalDomain
import MedalTestSupport
import SnapshotTesting
import SwiftUI
import XCTest

/// Pixel baselines for the deterministic view atoms — cells and the section header — which render
/// synchronously from their inputs (no async load to settle). The full async grid is verified by the
/// running-app screenshots + the advisory visual eval (ADR-0009); these lock the building blocks.
///
/// Baselines are renderer-pinned to the dev simulator (ADR-0009); this target is skipped in CI and runs
/// locally + in the pre-push gate. Record with `isRecording = true` (or delete `__Snapshots__`).
@MainActor
final class MedalComponentSnapshotTests: XCTestCase {
    private let cellSize = CGSize(width: 195, height: 180)
    private let headerSize = CGSize(width: 390, height: 48)

    private func card(_ view: some View, size: CGSize, colorScheme: ColorScheme = .light) -> UIViewController {
        let host = UIHostingController(
            rootView: view
                .frame(width: size.width, height: size.height)
                .background(SemanticColor.surface)
                .environment(\.colorScheme, colorScheme)
        )
        host.overrideUserInterfaceStyle = colorScheme == .dark ? .dark : .light
        host.view.frame = CGRect(origin: .zero, size: size)
        return host
    }

    func test_medalCell_earned() {
        let medal = AchievementFixtures.earnedDuration(title: "Fastest 5K", assetKey: "pr_fastest_5k")
        assertSnapshot(of: card(MedalCellView(medal: medal), size: cellSize), as: .image)
    }

    func test_medalCell_locked() {
        assertSnapshot(of: card(MedalCellView(medal: AchievementFixtures.lockedMarathon()), size: cellSize), as: .image)
    }

    func test_medalCell_earned_dark() {
        let medal = AchievementFixtures.earnedDuration(title: "Fastest 5K", assetKey: "pr_fastest_5k")
        assertSnapshot(of: card(MedalCellView(medal: medal), size: cellSize, colorScheme: .dark), as: .image)
    }

    func test_sectionHeader_withCount() {
        assertSnapshot(
            of: card(SectionHeaderView(title: "Personal Records", progress: (5, 6)), size: headerSize),
            as: .image
        )
    }

    func test_sectionHeader_noCount() {
        assertSnapshot(
            of: card(SectionHeaderView(title: "Virtual Races", progress: nil), size: headerSize),
            as: .image
        )
    }
}
