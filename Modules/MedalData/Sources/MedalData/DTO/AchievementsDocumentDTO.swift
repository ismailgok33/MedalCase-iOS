/// The top-level decoded shape of `achievements.json` (02-data-contract.md). Internal — never leaks
/// past the mapper; the feature only ever sees domain types.
struct AchievementsDocumentDTO: Decodable, Equatable {
    let schemaVersion: Int
    let sections: [SectionDTO]

    enum CodingKeys: String, CodingKey {
        case schemaVersion
        case sections
    }
}
