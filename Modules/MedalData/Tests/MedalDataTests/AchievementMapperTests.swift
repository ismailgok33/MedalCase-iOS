import MedalDomain
import Testing
@testable import MedalData

@Suite("AchievementMapper — semantic policies P2–P8")
struct AchievementMapperTests {
    private let mapper = AchievementMapper()

    private func medal(
        id: String = "m",
        type: String = "t",
        title: String = "T",
        assetKey: String = "k",
        status: String,
        value: MedalValueDTO? = nil
    ) -> MedalDTO {
        MedalDTO(id: id, type: type, title: title, assetKey: assetKey, status: status, value: value)
    }

    private func doc(_ medals: [MedalDTO]) -> AchievementsDocumentDTO {
        AchievementsDocumentDTO(
            schemaVersion: 1,
            sections: [SectionDTO(id: "s", title: "S", showsProgressCount: true, medals: medals)]
        )
    }

    private func firstMedal(_ document: AchievementsDocumentDTO) -> Achievement? {
        mapper.map(document).sections.first?.medals.first
    }

    @Test("an unknown medal type is passed through and the medal kept (P2)")
    func test_mapper_unknownType_keepsMedal() {
        let medal = firstMedal(doc([medal(type: "brand_new_type", status: "earned")]))
        #expect(medal?.type == "brand_new_type")
        #expect(medal?.isEarned == true)
    }

    @Test("an unknown value kind maps to earned(nil), the medal kept (P3)")
    func test_mapper_unknownValueKind_mapsToEarnedNil() {
        let value = MedalValueDTO(kind: "heart_rate", seconds: nil, style: nil, feet: nil)
        let medal = firstMedal(doc([medal(status: "earned", value: value)]))
        #expect(medal?.status == .earned(nil))
    }

    @Test("a duration missing its style degrades to earned(nil) (P3)")
    func test_mapper_durationMissingStyle_mapsToEarnedNil() {
        let value = MedalValueDTO(kind: "duration", seconds: 100, style: nil, feet: nil)
        let medal = firstMedal(doc([medal(status: "earned", value: value)]))
        #expect(medal?.status == .earned(nil))
    }

    @Test("an unknown status is treated as locked (P4)")
    func test_mapper_unknownStatus_treatsAsLocked() {
        let medal = firstMedal(doc([medal(status: "in_progress")]))
        #expect(medal?.status == .locked)
    }

    @Test("a locked medal with a stray value drops the value (P6)")
    func test_mapper_lockedWithValue_dropsValue() {
        let value = MedalValueDTO(kind: "duration", seconds: 100, style: "minutes_seconds", feet: nil)
        let medal = firstMedal(doc([medal(status: "locked", value: value)]))
        #expect(medal?.status == .locked)
    }

    @Test("duplicate medal ids keep the first (P7)")
    func test_mapper_duplicateIds_keepsFirst() {
        let mapped = mapper.map(doc([
            medal(id: "dup", title: "First", status: "earned"),
            medal(id: "dup", title: "Second", status: "earned")
        ]))
        #expect(mapped.sections.first?.medals.count == 1)
        #expect(mapped.sections.first?.medals.first?.title == "First")
    }

    @Test("duplicate section ids keep the first (P7)")
    func test_mapper_duplicateSectionIds_keepsFirst() {
        let document = AchievementsDocumentDTO(schemaVersion: 1, sections: [
            SectionDTO(id: "dup", title: "First", showsProgressCount: false, medals: []),
            SectionDTO(id: "dup", title: "Second", showsProgressCount: false, medals: [])
        ])
        let mapped = mapper.map(document)
        #expect(mapped.sections.count == 1)
        #expect(mapped.sections.first?.title == "First")
    }

    @Test("negative duration clamps to zero (P8)")
    func test_mapper_negativeValues_clampToZero() {
        let negative = MedalValueDTO(kind: "duration", seconds: -30, style: "minutes_seconds", feet: nil)
        let medal = firstMedal(doc([medal(status: "earned", value: negative)]))
        #expect(medal?.status == .earned(.duration(seconds: 0, style: .minutesSeconds)))
    }

    @Test("negative elevation clamps to zero (P8)")
    func test_mapper_negativeElevation_clampToZero() {
        let negative = MedalValueDTO(kind: "elevation", seconds: nil, style: nil, feet: -100)
        let medal = firstMedal(doc([medal(status: "earned", value: negative)]))
        #expect(medal?.status == .earned(.elevation(feet: 0)))
    }

    @Test("an empty document maps to an empty case without throwing (R2.3)")
    func test_mapper_emptyDocument_producesEmptyCaseWithoutThrowing() {
        let mapped = mapper.map(AchievementsDocumentDTO(schemaVersion: 1, sections: []))
        #expect(mapped.hasNoMedals)
    }
}
