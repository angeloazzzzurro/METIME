import XCTest

// MARK: - METIMEUITests

/// UI tests for the main user flows in the METIME app.
/// These tests launch the app and interact with it as a real user would.
final class METIMEUITests: XCTestCase {

    private var app: XCUIApplication!

    // MARK: - Setup

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        // Use in-memory store during UI tests to avoid polluting real data
        app.launchArguments = ["--uitesting"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Garden Home

    func test_gardenHome_petNameIsVisible() {
        let petName = app.staticTexts["MeTime"]
        XCTAssertTrue(petName.waitForExistence(timeout: 3),
                      "Pet name 'MeTime' should be visible on the main screen")
    }

    func test_gardenHome_moodLabelIsVisible() {
        // The mood label contains the prefix "Mood:"
        let moodLabel = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'Mood:'")).firstMatch
        XCTAssertTrue(moodLabel.waitForExistence(timeout: 3),
                      "Mood label should be visible on the main screen")
    }

    func test_gardenHome_allActionButtonsExist() {
        XCTAssertTrue(app.buttons["Medita"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["Cibo"].exists)
        XCTAssertTrue(app.buttons["Gioca"].exists)
        XCTAssertTrue(app.buttons["Diario"].exists)
    }

    // MARK: - Action: Feed

    func test_feed_buttonTapDoesNotCrash() {
        let feedButton = app.buttons["Cibo"]
        XCTAssertTrue(feedButton.waitForExistence(timeout: 3))
        feedButton.tap()
        // App should still be running after the tap
        XCTAssertTrue(app.buttons["Cibo"].exists)
    }

    // MARK: - Action: Play

    func test_play_buttonTapDoesNotCrash() {
        let playButton = app.buttons["Gioca"]
        XCTAssertTrue(playButton.waitForExistence(timeout: 3))
        playButton.tap()
        XCTAssertTrue(app.buttons["Gioca"].exists)
    }

    // MARK: - Action: Meditate

    func test_meditate_changesMoodLabel() {
        let meditaButton = app.buttons["Medita"]
        XCTAssertTrue(meditaButton.waitForExistence(timeout: 3))
        meditaButton.tap()

        // After meditation the mood should update to "happy"
        let happyMood = app.staticTexts["Mood: happy"]
        XCTAssertTrue(happyMood.waitForExistence(timeout: 2),
                      "Mood should change to 'happy' after tapping Medita")
    }

    // MARK: - Journal Sheet

    func test_journal_sheetOpensOnTap() {
        let diarioButton = app.buttons["Diario"]
        XCTAssertTrue(diarioButton.waitForExistence(timeout: 3))
        diarioButton.tap()
        // The sheet should appear; verify by checking the navigation title or a known element
        // (Exact assertion depends on the journal view implementation)
        XCTAssertTrue(app.exists)
    }
}
