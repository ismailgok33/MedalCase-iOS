import MedalDomain

/// Maps decoded DTOs into domain types, applying the data-contract's semantic policies (P2–P8). This
/// is where the mock's landmines resolve. Structural/decode failures (P1) are handled upstream by the
/// decoder; the mapper only ever sees a well-formed DTO. Internal — DTOs never leak past it.
struct AchievementMapper: Sendable {
    func map(_ dto: AchievementsDocumentDTO) -> AchievementsCase {
        // P7: duplicate section ids — keep first.
        let sections = deduplicated(dto.sections, by: \.id).map(mapSection)
        return AchievementsCase(sections: sections)
    }

    private func mapSection(_ dto: SectionDTO) -> AchievementSection {
        // P7: duplicate medal ids within a section — keep first.
        let medals = deduplicated(dto.medals, by: \.id).map(mapMedal)
        return AchievementSection(
            id: dto.id,
            title: dto.title,
            showsProgressCount: dto.showsProgressCount,
            medals: medals
        )
    }

    private func mapMedal(_ dto: MedalDTO) -> Achievement {
        Achievement(
            id: dto.id,
            type: dto.type, // P2: opaque, never switched on
            title: dto.title,
            assetKey: dto.assetKey, // P5: opaque; DesignSystem resolves unknown → placeholder
            status: mapStatus(dto)
        )
    }

    private func mapStatus(_ dto: MedalDTO) -> AchievementStatus {
        switch dto.status {
        case "earned":
            .earned(mapValue(dto.value))
        case "locked":
            .locked // P6: any value present is dropped
        default:
            .locked // P4: unknown status is treated conservatively as locked
        }
    }

    private func mapValue(_ dto: MedalValueDTO?) -> MedalValue? {
        guard let dto else { return nil }
        switch dto.kind {
        case "duration":
            // A duration needs both seconds and a known style; anything missing degrades to no value (P3).
            guard let seconds = dto.seconds, let style = mapStyle(dto.style) else { return nil }
            return .duration(seconds: max(0, seconds), style: style) // P8: clamp negatives
        case "elevation":
            guard let feet = dto.feet else { return nil }
            return .elevation(feet: max(0, feet)) // P8
        default:
            return nil // P3: unknown kind → no value, medal stays visible
        }
    }

    private func mapStyle(_ raw: String?) -> DurationStyle? {
        switch raw {
        case "minutes_seconds":
            .minutesSeconds
        case "hours_minutes_seconds":
            .hoursMinutesSeconds
        default:
            nil
        }
    }

    private func deduplicated<Element>(_ items: [Element], by id: (Element) -> String) -> [Element] {
        var seen = Set<String>()
        var result: [Element] = []
        for item in items where seen.insert(id(item)).inserted {
            result.append(item)
        }
        return result
    }
}
