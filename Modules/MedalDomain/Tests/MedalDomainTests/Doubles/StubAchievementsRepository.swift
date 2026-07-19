import MedalDomain

/// A local test double for `AchievementsRepository`.
///
/// MedalDomain's own tests use this local stub rather than the shared `MockAchievementsRepository` in
/// `MedalTestSupport`, because `MedalTestSupport` depends on `MedalDomain` — importing it here would
/// create a `MedalDomain ↔ MedalTestSupport` package cycle (the exact trap the LocalSakeShop eval once
/// caught). Downstream consumers use the shared mock.
struct StubAchievementsRepository: AchievementsRepository {
    var result: Result<AchievementsCase, any Error>

    func achievements() async throws -> AchievementsCase {
        try result.get()
    }
}
