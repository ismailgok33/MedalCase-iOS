/// How a duration medal value should be rendered. Carried in the data, not inferred from magnitude,
/// because the mock shows equal-magnitude durations in both styles (ADR-0010).
public enum DurationStyle: Equatable, Sendable {
    /// `MM:SS` — e.g. Fastest 5K, "23:07".
    case minutesSeconds
    /// `HH:MM:SS` — e.g. the 10K record, "00:00:00".
    case hoursMinutesSeconds
}
