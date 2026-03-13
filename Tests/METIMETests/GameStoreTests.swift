import XCTest
import SwiftData
@testable import METIME

// MARK: - GameStoreTests

/// Unit tests for GameStore business logic.
/// Uses an in-memory SwiftData container so no disk state is touched.
@MainActor
final class GameStoreTests: XCTestCase {

    // MARK: - Setup

    private var container: ModelContainer!
    private var store: GameStore!

    override func setUpWithError() throws {
        let schema = Schema([Pet.self, PetNeeds.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: [config])
        store = GameStore(modelContext: container.mainContext)
    }

    override func tearDownWithError() throws {
        store = nil
        container = nil
    }

    // MARK: - Initial State

    func test_initialState_petHasDefaultValues() {
        XCTAssertEqual(store.pet.name, "MeTime")
        XCTAssertEqual(store.pet.stage, 0)
        XCTAssertEqual(store.pet.food, 3)
        XCTAssertEqual(store.pet.needs.hunger,    0.8, accuracy: 0.001)
        XCTAssertEqual(store.pet.needs.happiness, 0.8, accuracy: 0.001)
        XCTAssertEqual(store.pet.needs.calm,      0.7, accuracy: 0.001)
        XCTAssertEqual(store.pet.needs.energy,    0.9, accuracy: 0.001)
    }

    // MARK: - Feed

    func test_feed_decrementsFoodAndIncreasesHunger() {
        let initialFood    = store.pet.food
        let initialHunger  = store.pet.needs.hunger
        let initialHappy   = store.pet.needs.happiness

        store.feed()

        XCTAssertEqual(store.pet.food,             initialFood - 1)
        XCTAssertEqual(store.pet.needs.hunger,     min(1, initialHunger + 0.3),    accuracy: 0.001)
        XCTAssertEqual(store.pet.needs.happiness,  min(1, initialHappy  + 0.1),    accuracy: 0.001)
    }

    func test_feed_doesNothingWhenNoFoodLeft() {
        // Drain all food
        store.pet.food = 0

        let hungerBefore = store.pet.needs.hunger
        store.feed()

        XCTAssertEqual(store.pet.food, 0)
        XCTAssertEqual(store.pet.needs.hunger, hungerBefore, accuracy: 0.001)
    }

    func test_feed_hungerCapsAtOne() {
        store.pet.needs.hunger = 0.95
        store.feed()
        XCTAssertEqual(store.pet.needs.hunger, 1.0, accuracy: 0.001)
    }

    // MARK: - Play

    func test_play_increasesHappinessAndDecreasesEnergy() {
        let initialHappy  = store.pet.needs.happiness
        let initialEnergy = store.pet.needs.energy

        store.play()

        XCTAssertEqual(store.pet.needs.happiness, min(1, initialHappy  + 0.2), accuracy: 0.001)
        XCTAssertEqual(store.pet.needs.energy,    max(0, initialEnergy - 0.1), accuracy: 0.001)
    }

    func test_play_energyDoesNotGoBelowZero() {
        store.pet.needs.energy = 0.05
        store.play()
        XCTAssertGreaterThanOrEqual(store.pet.needs.energy, 0.0)
    }

    // MARK: - Meditate

    func test_meditate_increasesCalmAndHappiness() {
        let initialCalm  = store.pet.needs.calm
        let initialHappy = store.pet.needs.happiness

        store.meditate()

        XCTAssertEqual(store.pet.needs.calm,      min(1, initialCalm  + 0.25), accuracy: 0.001)
        XCTAssertEqual(store.pet.needs.happiness, min(1, initialHappy + 0.1),  accuracy: 0.001)
    }

    func test_meditate_calmCapsAtOne() {
        store.pet.needs.calm = 0.9
        store.meditate()
        XCTAssertEqual(store.pet.needs.calm, 1.0, accuracy: 0.001)
    }

    // MARK: - Persistence

    func test_feed_persistsPetStateAcrossNewStoreInstance() throws {
        store.feed()
        let savedFood   = store.pet.food
        let savedHunger = store.pet.needs.hunger

        // Create a second store backed by the same in-memory context
        let store2 = GameStore(modelContext: container.mainContext)

        XCTAssertEqual(store2.pet.food,          savedFood,   accuracy: 0)
        XCTAssertEqual(store2.pet.needs.hunger,  savedHunger, accuracy: 0.001)
    }
}

// MARK: - ResourceTests

/// Tests for type-safe resource enums.
final class ResourceTests: XCTestCase {

    func test_audioAmbient_allMoodsHaveATrack() {
        for mood in PetMood.allCases {
            let track = AudioResource.Ambient.track(for: mood)
            XCTAssertFalse(track.rawValue.isEmpty,
                           "Mood \(mood.rawValue) has no ambient track")
        }
    }

    func test_colorResource_allMoodsHaveABackground() {
        for mood in PetMood.allCases {
            let color = ColorResource.background(for: mood)
            XCTAssertFalse(color.rawValue.isEmpty,
                           "Mood \(mood.rawValue) has no background color")
        }
    }

    func test_spriteResource_stagesMapCorrectly() {
        XCTAssertEqual(SpriteResource.sprite(forStage: 0), .egg)
        XCTAssertEqual(SpriteResource.sprite(forStage: 1), .sprout)
        XCTAssertEqual(SpriteResource.sprite(forStage: 2), .bloom)
        XCTAssertEqual(SpriteResource.sprite(forStage: 3), .spirit)
        XCTAssertEqual(SpriteResource.sprite(forStage: 99), .legend)
    }
}
