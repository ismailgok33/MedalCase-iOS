/// A decoded medal. `type` and `asset_key` stay opaque strings — the mapper never switches on them
/// (forward-compat policies P2/P5). `value` is absent for locked medals.
struct MedalDTO: Decodable, Equatable {
    let id: String
    let type: String
    let title: String
    let assetKey: String
    let status: String
    let value: MedalValueDTO?

    enum CodingKeys: String, CodingKey {
        case id
        case type
        case title
        case assetKey = "asset_key"
        case status
        case value
    }
}
