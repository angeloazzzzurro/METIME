import XCTest

// MARK: - METIMEUITests

final class METIMEUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        // INJ-06: --uitesting attiva il container in-memory nell'app
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

    func test_gardenHome_moodLabelStartsAsCalm() {
        let moodLabel = app.staticTexts["Mood: calm"]
        XCTAssertTrue(moodLabel.waitForExistence(timeout: 3),
                      "Initial mood should be 'calm'")
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
        XCTAssertTrue(app.buttons["Cibo"].exists, "App should still be running after feed tap")
    }

    func test_feed_blockedWhenFoodIsZero() {
        // Tap 4 times to drain all food (initial food = 3, 4th tap should be blocked)
        let feedButton = app.buttons["Cibo"]
        XCTAssertTrue(feedButton.waitForExistence(timeout: 3))
        feedButton.tap()
        feedButton.tap()
        feedButton.tap()
        feedButton.tap() // 4th tap — food = 0, should trigger shake + badge
        // App should still be running
        XCTAssertTrue(app.buttons["Cibo"].exists)
    }

    // MARK: - Action: Play

    func test_play_buttonTapDoesNotCrash() {
        let playButton = app.buttons["Gioca"]
        XCTAssertTrue(playButton.waitForExistence(timeout: 3))
        playButton.tap()
        XCTAssertTrue(app.buttons["Gioca"].exists)
    }

    func test_play_repeatedTapsEventuallyChangeMoodToSleepy() {
        // Tap play many times to drain energy below 0.2 → mood should become sleepy
        let playButton = app.buttons["Gioca"]
        XCTAssertTrue(playButton.waitForExistence(timeout: 3))
        // Initial energy = 0.9, each tap -0.1 → need 8 taps to reach < 0.2
        for _ in 0..<8 { playButton.tap() }
        let sleepyMood = app.staticTexts["Mood: sleepy"]
        XCTAssertTrue(sleepyMood.waitForExistence(timeout: 3),
                      "Mood should become 'sleepy' after draining energy")
    }

    // MARK: - Action: Meditate

    func test_meditate_doesNotSetMoodDirectlyToHappy() {
        // BUG-01 fix: mood should be derived from stats, not hardcoded to .happy
        let meditaButton = app.buttons["Medita"]
        XCTAssertTrue(meditaButton.waitForExistence(timeout: 3))
        meditaButton.tap()
        // After one meditation from default stats, mood should remain .calm
        // (calm goes from 0.7 to 0.95, happiness 0.8 to 0.9 — not enough for .happy threshold)
        let calmMood = app.staticTexts["Mood: calm"]
        XCTAssertTrue(calmMood.waitForExistence(timeout: 2),
                      "After one meditation from default stats, mood should remain 'calm'")
    }

    func test_meditate_repeatedTapsEventuallyReachHappy() {
        let meditaButton = app.buttons["Medita"]
        XCTAssertTrue(meditaButton.waitForExistence(timeout: 3))
        // Tap multiple times to push calm > 0.9 and happiness > 0.85
        for _ in 0..<4 { meditaButton.tap() }
        let happyOrEvolving = app.staticTexts.matching(
            NSPredicate(format: "label IN {'Mood: happy', 'Mood: evolving'}")
        ).firstMatch
        XCTAssertTrue(happyOrEvolving.waitForExistence(timeout: 3),
                      "After multiple meditations, mood should reach 'happy' or 'evolving'")
    }

    // MARK: - Journal Sheet (BUG-04 fix)

    func test_journal_sheetOpensOnTap() {
        let diarioButton = app.buttons["Diario"]
        XCTAssertTrue(diarioButton.waitForExistence(timeout: 3))
        diarioButton.tap()
        // The sheet should present a "Chiudi" button in the navigation bar
        let closeButton = app.buttons["Chiudi"]
        XCTAssertTrue(closeButton.waitForExistence(timeout: 3),
                      "Journal sheet should open and show a 'Chiudi' button")
    }

    func test_journal_sheetClosesOnDismiss() {
        let diarioButton = app.buttons["Diario"]
        XCTAssertTrue(diarioButton.waitForExistence(timeout: 3))
        diarioButton.tap()
        let closeButton = app.buttons["Chiudi"]
        XCTAssertTrue(closeButton.waitForExistence(timeout: 3))
        closeButton.tap()
        // After closing, the main screen action bar should be visible again
        XCTAssertTrue(app.buttons["Diario"].waitForExistence(timeout: 3),
                      "Main screen should be visible after closing the journal sheet")
    }
}
