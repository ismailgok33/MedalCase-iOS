import MedalDomain

/// The grid's decision about a section's "N of M" header: computed from the section's earned/total
/// counts, and shown **only** when the section declares it (R1.2, ADR-0008). Pure and testable, so the
/// count logic is verified without rendering.
enum SectionProgress {
    static func value(for section: AchievementSection) -> (earned: Int, total: Int)? {
        guard section.showsProgressCount else { return nil }
        return (section.earnedCount, section.totalCount)
    }
}
