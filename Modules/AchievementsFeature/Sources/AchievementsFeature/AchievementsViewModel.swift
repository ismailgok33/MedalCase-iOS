import DesignSystem
import Foundation
import MedalDomain
import Observation

/// Drives the medal-case screen. `@Observable @MainActor`: the view is a dumb switch over `state`; all
/// loading/empty/error decisions and the `MedalError → UserFacingError` mapping live here (CLAUDE.md).
///
/// The battery rule (rule 8): `load()` runs once and the ViewModel goes inert — no timers, polling, or
/// background work.
@Observable
@MainActor
public final class AchievementsViewModel {
    /// The id of the medal the overflow-menu demo toggles (the mock's locked Marathon).
    static let marathonDemoID = "pr_marathon"

    public private(set) var state: ViewState<AchievementsCase> = .loading

    private let repository: any AchievementsRepository

    public init(repository: any AchievementsRepository) {
        self.repository = repository
    }

    /// Loads the medal case, flipping to `.loading` first. Called once on appear.
    public func load() async {
        state = .loading
        await fetch()
    }

    /// Re-runs the load path after an error (R2.2).
    public func retry() async {
        await load()
    }

    /// Demo action (R1.6): flips the Marathon medal earned↔locked in-memory, so the wired overflow
    /// menu visibly changes the computed "N of M" count. No persistence.
    public func toggleMarathonDemo() {
        guard case let .loaded(current) = state else { return }
        let updated = toggling(current, medalID: Self.marathonDemoID)
        state = updated.hasNoMedals ? .empty : .loaded(updated)
    }

    /// Demo action (R1.6): discards demo changes by reloading the source data.
    public func reset() async {
        await load()
    }

    /// Re-fetches after the in-app language changes (ADR-0013), so the repository serves the new
    /// language's payload. Loaded content stays on screen while fetching (no `.loading` flip — the
    /// refresh pattern), and stays on a failed refresh: a language flip must never destroy an
    /// already-loaded medal case. From any other state this is just a load.
    public func refreshContent() async {
        guard case .loaded = state else {
            await load()
            return
        }
        do {
            let achievements = try await repository.achievements()
            state = achievements.hasNoMedals ? .empty : .loaded(achievements)
        } catch {
            // Keep the current language's content; the switch simply doesn't take visual effect.
        }
    }

    private func fetch() async {
        do {
            let achievements = try await repository.achievements()
            state = achievements.hasNoMedals ? .empty : .loaded(achievements)
        } catch {
            state = .error(Self.userFacingError(for: error))
        }
    }

    private func toggling(_ achievements: AchievementsCase, medalID: String) -> AchievementsCase {
        AchievementsCase(sections: achievements.sections.map { section in
            AchievementSection(
                id: section.id,
                title: section.title,
                showsProgressCount: section.showsProgressCount,
                medals: section.medals.map { medal in
                    guard medal.id == medalID else { return medal }
                    let flipped: AchievementStatus = medal.isEarned ? .locked : .earned(nil)
                    return Achievement(
                        id: medal.id,
                        type: medal.type,
                        title: medal.title,
                        assetKey: medal.assetKey,
                        status: flipped
                    )
                }
            )
        })
    }

    /// Any load failure maps to one retryable, localized message — no raw `Error` reaches the UI.
    private static func userFacingError(for _: any Error) -> UserFacingError {
        UserFacingError(
            message: LocalizedStringResource(
                "We couldn't load your medals. Please try again.",
                bundle: .atURL(Bundle.module.bundleURL)
            ),
            isRetryable: true
        )
    }
}
