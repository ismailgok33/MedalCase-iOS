import Foundation
import Testing
@testable import AchievementsFeature

/// Proves the feature's String Catalog is wired: the `fr` table exists in the module bundle and
/// resolves the keys the UI renders (R4.4, ADR-0012). Guards against the classic SPM localization
/// failure — keys silently falling back to English because a `Text` lacked `bundle: .module` or the
/// catalog wasn't processed as a resource.
struct LocalizationTests {
    private func frenchBundle() throws -> Bundle {
        let url = try #require(Bundle.module.url(forResource: "fr", withExtension: "lproj"))
        return try #require(Bundle(url: url))
    }

    @Test func test_localization_frenchCatalog_resolvesNotYet() throws {
        let resolved = try frenchBundle().localizedString(forKey: "Not Yet", value: nil, table: nil)
        #expect(resolved == "Pas encore")
    }

    @Test func test_localization_frenchCatalog_resolvesTitle() throws {
        let resolved = try frenchBundle().localizedString(forKey: "Achievements", value: nil, table: nil)
        #expect(resolved == "Réalisations")
    }

    @Test func test_localization_frenchCatalog_resolvesLockedAccessibilityFormat() throws {
        let format = try frenchBundle().localizedString(forKey: "%@, not yet earned", value: nil, table: nil)
        #expect(String(format: format, "Marathon") == "Marathon, pas encore obtenu")
    }

    @Test func test_appLanguage_coversEnglishAndFrench() {
        #expect(AppLanguage.allCases.map(\.rawValue) == ["en", "fr"])
        #expect(AppLanguage(rawValue: AppLanguage.storageKey) == nil)
    }
}
