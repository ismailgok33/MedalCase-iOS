/// The seam between the feature and wherever medals come from. `async throws` because that is the real
/// contract — the medal case is server-fed (ADR-0004). Today the only implementation reads a bundled
/// fixture; a remote one would slot in behind this same protocol with no downstream change.
public protocol AchievementsRepository: Sendable {
    func achievements() async throws -> AchievementsCase
}
