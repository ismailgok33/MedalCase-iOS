import MedalDomain

/// The production `AchievementsRepository`: load the encoded document from a data source, map it to
/// domain types. The only place the two collaborators meet. A remote implementation would swap the
/// data source and leave everything downstream untouched (ADR-0004).
public struct DefaultAchievementsRepository: AchievementsRepository {
    private let dataSource: any AchievementsDataSource
    private let mapper: AchievementMapper

    /// The production wiring: the bundled fixture + the default mapper. This is the only public surface
    /// of MedalData — the App injects it as an `any AchievementsRepository`; the data source, mapper,
    /// and DTOs stay internal.
    public init() {
        self.init(dataSource: BundledAchievementsDataSource(), mapper: AchievementMapper())
    }

    /// Internal DI seam for tests (reached via `@testable`) and for a future remote data source.
    init(dataSource: any AchievementsDataSource, mapper: AchievementMapper = AchievementMapper()) {
        self.dataSource = dataSource
        self.mapper = mapper
    }

    public func achievements() async throws -> AchievementsCase {
        let document = try await dataSource.load()
        return mapper.map(document)
    }
}
