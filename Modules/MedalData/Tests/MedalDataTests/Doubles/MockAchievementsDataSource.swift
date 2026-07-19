@testable import MedalData

/// A local `AchievementsDataSource` double for repository tests — stubs a decoded document or an error,
/// so the repository is exercised without touching the bundle. Local to `MedalDataTests` (the shared,
/// domain-level `MockAchievementsRepository` lives in `MedalTestSupport` for feature tests).
struct MockAchievementsDataSource: AchievementsDataSource {
    var result: Result<AchievementsDocumentDTO, any Error>

    func load() async throws -> AchievementsDocumentDTO {
        try result.get()
    }
}
