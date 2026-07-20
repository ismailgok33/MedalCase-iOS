import Foundation
import Testing
@testable import DesignSystem

/// Proves the design system's localization tables are wired (R4.4, ADR-0012): the `fr` table exists in the
/// module bundle and resolves the state-surface keys — including the positional count format the
/// section header renders.
struct LocalizationTests {
    private func frenchBundle() throws -> Bundle {
        let url = try #require(Bundle.module.url(forResource: "fr", withExtension: "lproj"))
        return try #require(Bundle(url: url))
    }

    @Test func test_localization_frenchCatalog_resolvesRetry() throws {
        let resolved = try frenchBundle().localizedString(forKey: "Retry", value: nil, table: nil)
        #expect(resolved == "Réessayer")
    }

    @Test func test_localization_frenchCatalog_resolvesProgressCountFormat() throws {
        let format = try frenchBundle().localizedString(forKey: "%lld of %lld", value: nil, table: nil)
        #expect(String(format: format, 5, 6) == "5 sur 6")
    }

    @Test func test_localization_frenchCatalog_resolvesHeaderEarnedFormat() throws {
        let format = try frenchBundle().localizedString(forKey: "%@, %lld of %lld earned", value: nil, table: nil)
        #expect(String(format: format, "Personal Records", 5, 6) == "Personal Records, 5 sur 6 obtenues")
    }

    // The two tests above assert the table side by raw key; these two resolve through the
    // production `L10n` accessors — a typo'd key inside `L10n` would silently fall back to English
    // at runtime, and fails here instead.

    @Test func test_l10n_loading_resolvesFrenchThroughProductionAccessor() {
        var resource = L10n.loading
        resource.locale = Locale(identifier: "fr")
        #expect(String(localized: resource) == "Chargement")
    }

    @Test func test_l10n_sectionHeaderLabel_resolvesFrenchThroughProductionAccessor() {
        var resource = L10n.sectionHeaderLabel(title: "Personal Records", earned: 5, total: 6)
        resource.locale = Locale(identifier: "fr")
        #expect(String(localized: resource) == "Personal Records, 5 sur 6 obtenues")
    }
}
