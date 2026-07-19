import Foundation
import MedalDomain
import Testing
@testable import MedalData

@Suite("DTO decoding — CodingKeys + malformed handling (P1)")
struct DTODecodingTests {
    @Test("the canonical fixture shape decodes, mapping snake_case keys to camelCase")
    func test_dto_decodesCanonicalFixture() throws {
        let json = Data("""
        {
          "schemaVersion": 1,
          "sections": [
            {
              "id": "personal_records", "title": "Personal Records", "shows_progress_count": true,
              "medals": [
                { "id": "m", "type": "fastest_5k", "title": "Fastest 5K", "asset_key": "pr_fastest_5k",
                  "status": "earned",
                  "value": { "kind": "duration", "seconds": 1387, "style": "minutes_seconds" } }
              ]
            }
          ]
        }
        """.utf8)
        let dto = try BundledAchievementsDataSource.decode(json)
        #expect(dto.schemaVersion == 1)
        #expect(dto.sections.first?.showsProgressCount == true)
        #expect(dto.sections.first?.medals.first?.assetKey == "pr_fastest_5k")
        #expect(dto.sections.first?.medals.first?.value?.seconds == 1387)
        #expect(dto.sections.first?.medals.first?.value?.style == "minutes_seconds")
    }

    @Test("malformed JSON throws MedalError.decoding, not a raw DecodingError (P1)")
    func test_decode_malformedJSON_throwsDecoding() {
        let bad = Data("{ this is not json".utf8)
        #expect(throws: MedalError.decoding) {
            try BundledAchievementsDataSource.decode(bad)
        }
    }

    @Test("structurally wrong JSON (missing required key) throws decoding (P1)")
    func test_decode_missingRequiredKey_throwsDecoding() {
        let missing = Data(#"{ "schemaVersion": 1 }"#.utf8) // no "sections"
        #expect(throws: MedalError.decoding) {
            try BundledAchievementsDataSource.decode(missing)
        }
    }
}
