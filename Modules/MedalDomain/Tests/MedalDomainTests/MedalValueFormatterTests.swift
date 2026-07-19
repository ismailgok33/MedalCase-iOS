import Testing
@testable import MedalDomain

@Suite("MedalValueFormatter — mock-exact value rendering (R3, ADR-0010)")
struct MedalValueFormatterTests {
    @Test("minutes:seconds at zero → 00:00")
    func test_medalValueFormatter_minutesSeconds_zero() {
        #expect(MedalValueFormatter.string(for: .duration(seconds: 0, style: .minutesSeconds)) == "00:00")
    }

    @Test("minutes:seconds non-zero → 23:07 (the Virtual 5K)")
    func test_medalValueFormatter_minutesSeconds_nonZero() {
        #expect(MedalValueFormatter.string(for: .duration(seconds: 1387, style: .minutesSeconds)) == "23:07")
    }

    @Test("minutes may exceed 99 without overflowing the field")
    func test_medalValueFormatter_minutesSeconds_largeMinutes() {
        // 100 minutes exactly — guards against a fixed 2-digit assumption.
        #expect(MedalValueFormatter.string(for: .duration(seconds: 6000, style: .minutesSeconds)) == "100:00")
    }

    @Test("hours:minutes:seconds at zero → 00:00:00")
    func test_medalValueFormatter_hoursMinutesSeconds_zero() {
        #expect(
            MedalValueFormatter.string(for: .duration(seconds: 0, style: .hoursMinutesSeconds)) == "00:00:00"
        )
    }

    @Test("hours:minutes:seconds carries correctly (3661s → 01:01:01)")
    func test_medalValueFormatter_hoursMinutesSeconds_carries() {
        #expect(
            MedalValueFormatter.string(for: .duration(seconds: 3661, style: .hoursMinutesSeconds)) == "01:01:01"
        )
    }

    @Test("elevation → whole feet + unit, no digit grouping")
    func test_medalValueFormatter_elevation_wholeFeet() {
        #expect(MedalValueFormatter.string(for: .elevation(feet: 2095)) == "2095 ft")
    }

    @Test("nil value → nil (no value line, policy P3)")
    func test_medalValueFormatter_nilValue_returnsNil() {
        #expect(MedalValueFormatter.string(for: nil) == nil)
    }

    @Test("negative seconds are treated as zero (totality guard, P8)")
    func test_medalValueFormatter_negativeSeconds_treatedAsZero() {
        #expect(MedalValueFormatter.string(for: .duration(seconds: -5, style: .minutesSeconds)) == "00:00")
    }

    @Test("locked placeholder default is Not Yet")
    func test_medalValueFormatter_lockedPlaceholder_isNotYet() {
        #expect(MedalValueFormatter.lockedPlaceholder() == "Not Yet")
    }
}
