/// One titled group of medals (e.g. "Personal Records"). The progress count is **computed here**, never
/// stored, so the header can never drift from the medals it summarizes (ADR-0008).
public struct AchievementSection: Identifiable, Equatable, Sendable {
    public let id: String
    public let title: String
    public let showsProgressCount: Bool
    public let medals: [Achievement]

    public init(id: String, title: String, showsProgressCount: Bool, medals: [Achievement]) {
        self.id = id
        self.title = title
        self.showsProgressCount = showsProgressCount
        self.medals = medals
    }

    /// Number of earned medals in this section.
    public var earnedCount: Int {
        medals.lazy.filter(\.isEarned).count
    }

    /// Total number of medals in this section.
    public var totalCount: Int {
        medals.count
    }
}
