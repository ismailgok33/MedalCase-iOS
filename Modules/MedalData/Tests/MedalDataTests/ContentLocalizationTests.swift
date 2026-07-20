import MedalDomain
import Testing
@testable import MedalData

/// Content localization (ADR-0013): the bundled source serves a per-language payload variant — the
/// Accept-Language analog — and the two documents stay structurally identical (only display text may
/// differ), so switching language can never change ids, statuses, values, or ordering.
struct ContentLocalizationTests {
    @Test func test_resourceName_frenchTags_selectFrenchVariant() {
        #expect(BundledAchievementsDataSource.resourceName(forLanguageCode: "fr") == "achievements-fr")
        #expect(BundledAchievementsDataSource.resourceName(forLanguageCode: "fr-CA") == "achievements-fr")
    }

    @Test func test_resourceName_otherTags_fallBackToBaseDocument() {
        #expect(BundledAchievementsDataSource.resourceName(forLanguageCode: "en") == "achievements")
        #expect(BundledAchievementsDataSource.resourceName(forLanguageCode: "ja") == "achievements")
    }

    @Test func test_repository_frenchLanguage_servesFrenchTitles() async throws {
        let repository = DefaultAchievementsRepository(languageCode: { "fr" })
        let achievements = try await repository.achievements()
        #expect(achievements.sections.first?.title == "Records personnels")
        #expect(achievements.sections.first?.medals.first?.title == "Course la plus longue")
    }

    @Test func test_repository_unsupportedLanguage_servesEnglishTitles() async throws {
        let repository = DefaultAchievementsRepository(languageCode: { "ja" })
        let achievements = try await repository.achievements()
        #expect(achievements.sections.first?.title == "Personal Records")
    }

    @Test func test_fixtures_frenchMirrorsEnglishStructure() async throws {
        let english = try await BundledAchievementsDataSource(resource: "achievements").load()
        let french = try await BundledAchievementsDataSource(resource: "achievements-fr").load()
        let mapper = AchievementMapper()
        let en = mapper.map(english)
        let fr = mapper.map(french)

        #expect(en.sections.map(\.id) == fr.sections.map(\.id))
        for (enSection, frSection) in zip(en.sections, fr.sections) {
            #expect(enSection.showsProgressCount == frSection.showsProgressCount)
            #expect(enSection.medals.map(\.id) == frSection.medals.map(\.id))
            #expect(enSection.medals.map(\.type) == frSection.medals.map(\.type))
            #expect(enSection.medals.map(\.status) == frSection.medals.map(\.status))
            #expect(enSection.medals.map(\.assetKey) == frSection.medals.map(\.assetKey))
        }
    }

    /// The FR analog of `test_bundledResource_matchesCanonicalFixture`: pins the packaged French copy
    /// to the canonical `tech_specs/data/achievements-fr.json` content, so the two cannot silently
    /// diverge (the parity test alone compares packaged-EN vs packaged-FR, not packaged vs canonical).
    @Test func test_bundledFrenchResource_matchesCanonicalFixture() async throws {
        let french = try await AchievementMapper().map(
            BundledAchievementsDataSource(languageCode: "fr").load()
        )
        #expect(french.sections.count == 2)
        let records = try #require(french.sections.first)
        #expect(records.title == "Records personnels")
        #expect(records.medals.count == 6)
        #expect(records.medals.first?.title == "Course la plus longue")
        #expect(records.medals.last?.isEarned == false)
        let races = try #require(french.sections.last)
        #expect(races.title == "Courses virtuelles")
        #expect(races.medals.count == 6)
        #expect(races.medals.last?.title == "Course virtuelle de 5 km")
        #expect(races.medals.last?.status == .earned(.duration(seconds: 1387, style: .minutesSeconds)))
    }

    @Test func test_fixtures_brandRaceNamesStayVerbatimInFrench() async throws {
        let french = try await AchievementMapper().map(
            BundledAchievementsDataSource(resource: "achievements-fr").load()
        )
        let races = try #require(french.sections.last).medals
        #expect(races.contains { $0.title == "Tokyo-Hakone Ekiden 2020" })
        #expect(races.contains { $0.title == "Hakone Ekiden" })
        #expect(races.contains { $0.title == "Mizuno Singapore Ekiden 2015" })
    }
}
