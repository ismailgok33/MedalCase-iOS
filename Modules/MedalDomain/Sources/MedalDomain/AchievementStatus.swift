/// Whether a medal is earned (with an optional measured value) or still locked.
///
/// An earned medal may carry a `nil` value when the feed omits or garbles it (policy P3) — the medal
/// stays visible without a value line rather than disappearing over a formatting gap.
public enum AchievementStatus: Equatable, Sendable {
    case earned(MedalValue?)
    case locked
}
