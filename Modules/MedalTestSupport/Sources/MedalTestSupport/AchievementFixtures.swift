import MedalDomain

/// Domain-shaped fixtures mirroring the canonical `tech_specs/data/achievements.json` (kept in step in
/// the same change — ADR-0002). Downstream tests build from these instead of inlining medals, so every
/// suite agrees on one dataset. The `MedalData` layer separately verifies the *bundled* JSON matches
/// this content.
public enum AchievementFixtures {
    /// The full mock: Personal Records (5 earned + 1 locked Marathon) and Virtual Races (6, incl. 23:07).
    public static var canonicalCase: AchievementsCase {
        AchievementsCase(sections: [personalRecords, virtualRaces])
    }

    /// A case with a section but no medals — drives the empty state (R2.3).
    public static var emptyCase: AchievementsCase {
        AchievementsCase(sections: [
            AchievementSection(id: "personal_records", title: "Personal Records", showsProgressCount: true, medals: [])
        ])
    }

    /// A single section with the requested counts — for progress-count and label assertions.
    public static func singleSection(
        earned: Int,
        locked: Int,
        showsProgressCount: Bool = true
    ) -> AchievementsCase {
        let earnedMedals = (0 ..< earned).map { earnedDuration(id: "earned_\($0)") }
        let lockedMedals = (0 ..< locked).map { lockedMarathon(id: "locked_\($0)") }
        return AchievementsCase(sections: [
            AchievementSection(
                id: "s",
                title: "Section",
                showsProgressCount: showsProgressCount,
                medals: earnedMedals + lockedMedals
            )
        ])
    }

    // MARK: - Individual medal builders

    public static func earnedDuration(
        id: String = "pr_fastest_5k",
        title: String = "Fastest 5K",
        assetKey: String = "pr_fastest_5k",
        seconds: Int = 0,
        style: DurationStyle = .minutesSeconds
    ) -> Achievement {
        Achievement(
            id: id,
            type: "duration",
            title: title,
            assetKey: assetKey,
            status: .earned(.duration(seconds: seconds, style: style))
        )
    }

    public static func elevation(
        id: String = "pr_highest_elevation",
        feet: Int = 2095
    ) -> Achievement {
        Achievement(
            id: id,
            type: "highest_elevation",
            title: "Highest Elevation",
            assetKey: "pr_highest_elevation",
            status: .earned(.elevation(feet: feet))
        )
    }

    public static func lockedMarathon(id: String = "pr_marathon") -> Achievement {
        Achievement(
            id: id,
            type: "fastest_marathon",
            title: "Marathon",
            assetKey: "pr_fastest_marathon",
            status: .locked
        )
    }

    // MARK: - Canonical sections

    private static var personalRecords: AchievementSection {
        AchievementSection(
            id: "personal_records",
            title: "Personal Records",
            showsProgressCount: true,
            medals: [
                Achievement(
                    id: "pr_longest_run",
                    type: "longest_run",
                    title: "Longest Run",
                    assetKey: "pr_longest_run",
                    status: .earned(.duration(seconds: 0, style: .minutesSeconds))
                ),
                elevation(),
                Achievement(
                    id: "pr_fastest_5k",
                    type: "fastest_5k",
                    title: "Fastest 5K",
                    assetKey: "pr_fastest_5k",
                    status: .earned(.duration(seconds: 0, style: .minutesSeconds))
                ),
                Achievement(
                    id: "pr_fastest_10k",
                    type: "fastest_10k",
                    title: "10K",
                    assetKey: "pr_fastest_10k",
                    status: .earned(.duration(seconds: 0, style: .hoursMinutesSeconds))
                ),
                Achievement(
                    id: "pr_half_marathon",
                    type: "fastest_half_marathon",
                    title: "Half Marathon",
                    assetKey: "pr_fastest_half_marathon",
                    status: .earned(.duration(seconds: 0, style: .minutesSeconds))
                ),
                lockedMarathon()
            ]
        )
    }

    private static var virtualRaces: AchievementSection {
        AchievementSection(
            id: "virtual_races",
            title: "Virtual Races",
            showsProgressCount: false,
            medals: [
                race(
                    id: "race_virtual_half_marathon",
                    title: "Virtual Half Marathon Race",
                    assetKey: "race_virtual_half_marathon",
                    seconds: 0,
                    style: .minutesSeconds
                ),
                race(
                    id: "race_tokyo_hakone_ekiden_2020",
                    title: "Tokyo-Hakone Ekiden 2020",
                    assetKey: "race_tokyo_hakone_ekiden_2020",
                    seconds: 0,
                    style: .hoursMinutesSeconds
                ),
                race(
                    id: "race_virtual_10k",
                    title: "Virtual 10K Race",
                    assetKey: "race_virtual_10k",
                    seconds: 0,
                    style: .hoursMinutesSeconds
                ),
                race(
                    id: "race_hakone_ekiden",
                    title: "Hakone Ekiden",
                    assetKey: "race_hakone_ekiden",
                    seconds: 0,
                    style: .hoursMinutesSeconds
                ),
                race(
                    id: "race_mizuno_singapore_ekiden_2015",
                    title: "Mizuno Singapore Ekiden 2015",
                    assetKey: "race_mizuno_singapore_ekiden",
                    seconds: 0,
                    style: .hoursMinutesSeconds
                ),
                race(
                    id: "race_virtual_5k",
                    title: "Virtual 5K Race",
                    assetKey: "race_virtual_5k",
                    seconds: 1387,
                    style: .minutesSeconds
                )
            ]
        )
    }

    private static func race(
        id: String,
        title: String,
        assetKey: String,
        seconds: Int,
        style: DurationStyle
    ) -> Achievement {
        Achievement(
            id: id,
            type: "virtual_race",
            title: title,
            assetKey: assetKey,
            status: .earned(.duration(seconds: seconds, style: style))
        )
    }
}
