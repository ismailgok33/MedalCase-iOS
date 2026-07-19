import XCTest

/// End-to-end smoke test of the composed app: launch → the medal case renders its cells with the
/// combined accessibility labels → the Virtual Races section is reachable by scrolling. Runs in CI
/// (validates the real app, not a package in isolation).
final class MedalCaseUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    /// Matches any element whose accessibility label equals `text`, across element types — robust to
    /// whether a combined cell surfaces as a staticText or otherElement.
    private func element(_ app: XCUIApplication, labeled text: String) -> XCUIElement {
        app.descendants(matching: .any).matching(NSPredicate(format: "label == %@", text)).firstMatch
    }

    @MainActor
    func test_launch_showsAchievementsGrid() {
        let app = XCUIApplication()
        app.launch()

        // The grid loaded: an earned medal cell exposes its combined "«title», «value»" label (R4.1).
        XCTAssertTrue(element(app, labeled: "Highest Elevation, 2095 ft").waitForExistence(timeout: 10))

        // The locked Marathon reads "not yet earned" rather than a duration.
        XCTAssertTrue(element(app, labeled: "Marathon, not yet earned").exists)

        // A navigation bar is present (the teal Achievements bar).
        XCTAssertTrue(app.navigationBars.firstMatch.exists)

        // The Virtual Races section is reachable by scrolling to one of its race cells.
        let race = element(app, labeled: "Virtual 5K Race, 23:07")
        var attempts = 0
        while !race.exists, attempts < 6 {
            app.swipeUp()
            attempts += 1
        }
        XCTAssertTrue(race.exists)
    }

    /// Cold-launch time to first frame (rule 8 / performance-battery.md). Reproducible number for the
    /// README; also the guardrail that would catch a launch regression from added startup work.
    @MainActor
    func test_launchPerformance() {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
