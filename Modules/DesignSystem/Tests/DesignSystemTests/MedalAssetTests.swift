import Testing
@testable import DesignSystem

@Suite("MedalAsset — key resolution (policy P5)")
struct MedalAssetTests {
    @Test("a known contract key resolves to its catalog image (P5)")
    func test_medalAsset_knownKey_returnsImage() {
        #expect(MedalAsset.resolution(for: "pr_fastest_5k") == .catalog("pr_fastest_5k"))
        #expect(
            MedalAsset.resolution(for: "race_tokyo_hakone_ekiden_2020")
                == .catalog("race_tokyo_hakone_ekiden_2020")
        )
    }

    @Test("an unknown key resolves to the placeholder, not a broken image (P5)")
    func test_medalAsset_unknownKey_returnsPlaceholder() {
        #expect(MedalAsset.resolution(for: "not_a_real_medal") == .placeholder)
        #expect(MedalAsset.resolution(for: "") == .placeholder)
    }

    @Test("the catalog exposes exactly the 13 shipped imagesets")
    func test_medalAsset_knownKeys_countMatchesCatalog() {
        // 12 medals the fixture renders + the unused race_virtual_marathon (L4).
        #expect(MedalAsset.knownKeys.count == 13)
    }

    @Test("the unused 7th race asset ships and resolves to catalog art (data-driven proof, L4)")
    func test_medalAsset_unusedMarathonRace_isPresent() {
        #expect(MedalAsset.resolution(for: "race_virtual_marathon") == .catalog("race_virtual_marathon"))
    }
}
