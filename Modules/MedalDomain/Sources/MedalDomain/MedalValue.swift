/// The measured value behind an earned medal — a typed union so a new kind (distance, pace, calories)
/// extends the model without touching call sites (ADR-0010). Absent for locked medals.
public enum MedalValue: Equatable, Sendable {
    /// A time, rendered per its `DurationStyle`.
    case duration(seconds: Int, style: DurationStyle)
    /// An elevation in whole feet (mock-exact: "2095 ft").
    case elevation(feet: Int)
}
