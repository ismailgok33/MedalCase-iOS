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

    /// Taps only after the element's frame stops moving: menu/submenu rows animate in, and a tap
    /// computed from a mid-animation frame can land beside the row and dismiss the menu without
    /// selecting (observed on iOS 26 — the failure hierarchy showed a closed menu and no commit).
    private func tapWhenSettled(_ element: XCUIElement, timeout: TimeInterval = 3) {
        XCTAssertTrue(element.waitForExistence(timeout: timeout))
        var previousFrame = CGRect.null
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            let frame = element.frame
            if frame == previousFrame {
                break
            }
            previousFrame = frame
            RunLoop.current.run(until: Date().addingTimeInterval(0.15))
        }
        element.tap()
    }

    @MainActor
    func test_launch_showsAchievementsGrid() {
        let app = XCUIApplication()
        // Hermetic: the language-switcher test persists "fr" on this simulator; pin EN explicitly so
        // test order can never change what this test sees.
        app.launchArguments += ["-app_language", "en"]
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

    /// The in-app language switcher (R1.6, ADR-0012 + ADR-0013): round-trip EN → FR through the
    /// overflow menu — the chrome re-resolves live, and the **content refreshes** to the French payload
    /// (section titles + medal titles served by the data layer, brand race names verbatim).
    ///
    /// Deliberately launches with NO language argument: `-app_language X` would register in
    /// `NSArgumentDomain`, which shadows every AppStorage write and makes the switch unobservable —
    /// the launch-arg "hermeticity" of this test's first version was exactly what broke it. Instead it
    /// pins its EN baseline through the UI, addressing rows by language-independent
    /// `accessibilityIdentifier`s. (Cell text can't be asserted directly: cells are single combined
    /// accessibility elements per R4.1 — the FR cell rendering is locked by the
    /// `test_medalCell_locked_fr` snapshot instead.)
    @MainActor
    func test_languageSwitcher_switchesChromeAndContentToFrench() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.navigationBars.firstMatch.waitForExistence(timeout: 10))

        // Pin the EN baseline through the switcher itself (also exercises the EN direction).
        tapWhenSettled(app.buttons["overflow-menu"])
        tapWhenSettled(app.buttons["language-menu"])
        tapWhenSettled(app.buttons["language-en"])
        XCTAssertTrue(app.staticTexts["Achievements"].waitForExistence(timeout: 8))
        XCTAssertTrue(element(app, labeled: "Longest Run, 00:00").waitForExistence(timeout: 8))

        // Flip to Français: chrome re-resolves live…
        tapWhenSettled(app.buttons["overflow-menu"])
        tapWhenSettled(app.buttons["language-menu"])
        tapWhenSettled(app.buttons["language-fr"])
        XCTAssertTrue(app.staticTexts["Réalisations"].waitForExistence(timeout: 8))

        // …and the CONTENT refreshed to the French payload (ADR-0013). The combined header label is
        // fully French — format AND title — because accessibility labels render through SwiftUI Text
        // under the `\.locale` environment, so they follow the app's effective language (this test is
        // the empirical pin for that stance in accessibility.md).
        XCTAssertTrue(element(app, labeled: "Records personnels, 5 sur 6 obtenues").waitForExistence(timeout: 8))
        XCTAssertTrue(element(app, labeled: "Course la plus longue, 00:00").exists)

        tapWhenSettled(app.buttons["overflow-menu"])
        XCTAssertTrue(app.buttons["Réinitialiser"].waitForExistence(timeout: 3))
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
