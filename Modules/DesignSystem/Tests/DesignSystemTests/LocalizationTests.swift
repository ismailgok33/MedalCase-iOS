import Foundation
import Testing
@testable import DesignSystem

/// Proves the design system's String Catalog is wired (R4.4, ADR-0012): the `fr` table exists in the
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
}
