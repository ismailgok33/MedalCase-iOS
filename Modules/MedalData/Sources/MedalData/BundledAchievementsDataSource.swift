import Foundation
import MedalDomain

/// Loads the `achievements.json` fixture shipped in this package's bundle. Maps a missing resource to
/// `MedalError.emptyData` and malformed JSON to `MedalError.decoding` (policy P1), so no raw
/// `DecodingError` escapes.
struct BundledAchievementsDataSource: AchievementsDataSource {
    private let bundle: Bundle
    private let resource: String

    init(bundle: Bundle = .module, resource: String = "achievements") {
        self.bundle = bundle
        self.resource = resource
    }

    /// Selects the per-language payload variant — the bundled analog of a server honoring
    /// Accept-Language (ADR-0013).
    init(bundle: Bundle = .module, languageCode: String) {
        self.init(bundle: bundle, resource: Self.resourceName(forLanguageCode: languageCode))
    }

    /// Any French tag ("fr", "fr-CA") selects the French document; every other language falls back to
    /// the base English one. Pure, so the selection rule is unit-testable.
    static func resourceName(forLanguageCode code: String) -> String {
        code.lowercased().hasPrefix("fr") ? "achievements-fr" : "achievements"
    }

    func load() async throws -> AchievementsDocumentDTO {
        guard let url = bundle.url(forResource: resource, withExtension: "json"),
              let data = try? Data(contentsOf: url)
        else {
            throw MedalError.emptyData
        }
        return try Self.decode(data)
    }

    /// Pure decode step, mapping any `DecodingError` to `MedalError.decoding` (P1). Exposed so the
    /// malformed-payload path is testable without a bundle.
    static func decode(_ data: Data) throws -> AchievementsDocumentDTO {
        do {
            return try JSONDecoder().decode(AchievementsDocumentDTO.self, from: data)
        } catch {
            throw MedalError.decoding
        }
    }
}
