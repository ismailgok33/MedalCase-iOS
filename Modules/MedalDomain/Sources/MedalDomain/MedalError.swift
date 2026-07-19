/// The domain error taxonomy. Every decoding/mapping failure in the data layer maps into one of these
/// before it reaches a feature; no raw `Error` escapes (CLAUDE.md). No transport cases yet — there is
/// no networking layer (ADR-0004); they arrive the day a remote source does.
public enum MedalError: Error, Equatable, Sendable {
    /// The payload was malformed or structurally wrong (policy P1).
    case decoding
    /// The data resource was missing or unreadable.
    case emptyData
    /// An unclassified failure — mapped, never surfaced raw.
    case unknown
}
