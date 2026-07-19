/// A decoded section. `shows_progress_count` maps via explicit `CodingKeys` (no global key strategy).
struct SectionDTO: Decodable, Equatable {
    let id: String
    let title: String
    let showsProgressCount: Bool
    let medals: [MedalDTO]

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case showsProgressCount = "shows_progress_count"
        case medals
    }
}
