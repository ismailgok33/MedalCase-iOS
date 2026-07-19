import MedalDomain

/// The shared `AchievementsRepository` double for downstream (feature, app) tests — a spy + stub.
///
/// `@unchecked Sendable` is justified: each test owns its own instance and Swift Testing serializes
/// access within a test, so the mutable spy state never actually crosses an isolation boundary. This
/// is the single written `@unchecked` escape hatch the constitution allows, and it lives in test
/// support only — never in app code.
public final class MockAchievementsRepository: AchievementsRepository, @unchecked Sendable {
    public var result: Result<AchievementsCase, any Error>
    public private(set) var callCount = 0

    public init(result: Result<AchievementsCase, any Error> = .success(AchievementFixtures.canonicalCase)) {
        self.result = result
    }

    public func achievements() async throws -> AchievementsCase {
        callCount += 1
        return try result.get()
    }
}
