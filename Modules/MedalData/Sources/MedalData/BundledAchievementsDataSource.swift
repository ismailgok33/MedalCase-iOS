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
