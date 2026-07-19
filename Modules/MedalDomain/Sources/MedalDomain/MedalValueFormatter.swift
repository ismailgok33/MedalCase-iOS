/// Pure, total rendering of a `MedalValue` to its mock-exact string (ADR-0010, R3).
///
/// Returns raw numeric glyphs (`23:07`, `2095 ft`) — not localized prose. The user-facing "Not Yet"
/// string is a presentation concern and lives in the feature's String Catalog (R4.4);
/// ``lockedPlaceholder()`` exists only so pure tests can assert the non-localized default.
public enum MedalValueFormatter {
    /// The formatted value line, or `nil` when there is no value to show (locked, or an unknown/absent
    /// value — policy P3). Negative inputs are treated as zero so the function never traps.
    public static func string(for value: MedalValue?) -> String? {
        guard let value else { return nil }
        switch value {
        case let .duration(seconds, style):
            return durationString(seconds: max(0, seconds), style: style)
        case let .elevation(feet):
            return "\(max(0, feet)) ft"
        }
    }

    /// The non-localized locked default. The feature renders the localized catalog string instead.
    public static func lockedPlaceholder() -> String {
        "Not Yet"
    }

    private static func durationString(seconds: Int, style: DurationStyle) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        switch style {
        case .minutesSeconds:
            return "\(pad2(minutes)):\(pad2(secs))"
        case .hoursMinutesSeconds:
            let hours = minutes / 60
            let mins = minutes % 60
            return "\(pad2(hours)):\(pad2(mins)):\(pad2(secs))"
        }
    }

    /// Zero-pads to at least two digits without Foundation, keeping the domain framework-free (and
    /// portable). Values ≥ 100 (e.g. 100+ minutes) pass through un-truncated.
    private static func pad2(_ value: Int) -> String {
        value < 10 ? "0\(value)" : "\(value)"
    }
}
