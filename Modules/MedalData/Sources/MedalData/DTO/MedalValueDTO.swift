/// A decoded value union. All fields but `kind` are optional so the decoder tolerates either variant
/// (`duration` carries `seconds`/`style`; `elevation` carries `feet`); the mapper enforces which
/// combination is valid and degrades unknowns to no value (policy P3).
struct MedalValueDTO: Decodable, Equatable {
    let kind: String
    let seconds: Int?
    let style: String?
    let feet: Int?
}
