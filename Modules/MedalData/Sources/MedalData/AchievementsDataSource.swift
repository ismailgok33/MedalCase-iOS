/// Abstracts *where the encoded document comes from* — the bundle today, a network client tomorrow
/// (ADR-0004). Returns the decoded DTO; mapping to domain is the repository's job. Internal: a remote
/// data source would be added inside this package, behind this same seam.
protocol AchievementsDataSource: Sendable {
    func load() async throws -> AchievementsDocumentDTO
}
