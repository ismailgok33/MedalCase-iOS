/// The whole medal case: ordered sections, each an ordered list of medals. Display order is data order.
public struct AchievementsCase: Equatable, Sendable {
    public let sections: [AchievementSection]

    public init(sections: [AchievementSection]) {
        self.sections = sections
    }

    /// True when there is no medal to render in any section — drives the empty state (R2.3).
    public var hasNoMedals: Bool {
        sections.allSatisfy(\.medals.isEmpty)
    }
}
