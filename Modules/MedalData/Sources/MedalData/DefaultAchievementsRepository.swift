import MedalDomain

/// The production `AchievementsRepository`: load the encoded document from a data source, map it to
/// domain types. The only place the two collaborators meet. A remote implementation would swap the
/// data source and leave everything downstream untouched (ADR-0004).
public struct DefaultAchievementsRepository: AchievementsRepository {
    private let dataSourceProvider: @Sendable () -> any AchievementsDataSource
    private let mapper: AchievementMapper

    /// The production wiring: the bundled fixture + the default mapper. This is the only public surface
    /// of MedalData — the App injects it as an `any AchievementsRepository`; the data source, mapper,
    /// and DTOs stay internal.
    ///
    /// `languageCode` is read **per call**, and the matching payload variant is selected each time
    /// (ADR-0013) — the bundled analog of a server localizing content by Accept-Language. The
    /// composition root passes the in-app language; the default serves the base English document.
    public init(languageCode: @escaping @Sendable () -> String = { "en" }) {
        self.init(
            dataSourceProvider: { BundledAchievementsDataSource(languageCode: languageCode()) },
            mapper: AchievementMapper()
        )
    }

    /// Internal DI seam for tests (reached via `@testable`) and for a future remote data source.
    init(dataSource: any AchievementsDataSource, mapper: AchievementMapper = AchievementMapper()) {
        self.init(dataSourceProvider: { dataSource }, mapper: mapper)
    }

    init(
        dataSourceProvider: @escaping @Sendable () -> any AchievementsDataSource,
        mapper: AchievementMapper = AchievementMapper()
    ) {
        self.dataSourceProvider = dataSourceProvider
        self.mapper = mapper
    }

    public func achievements() async throws -> AchievementsCase {
        let document = try await dataSourceProvider().load()
        return mapper.map(document)
    }
}
