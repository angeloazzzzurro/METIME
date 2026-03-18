import Foundation
import SwiftUI
import SwiftData
import OSLog

// MARK: - GameStore

/// Manages the pet's game state and persists it via SwiftData.
@MainActor
final class GameStore: ObservableObject {

    // MARK: - State

    private(set) var pet: Pet

    /// True when the last `feed()` call was blocked because food == 0.
    @Published private(set) var feedBlocked: Bool = false

    // MARK: - Private

    private let modelContext: ModelContext
    private let logger = Logger(subsystem: "com.metime.app", category: "GameStore")

    // MARK: - Init

    init(modelContext: ModelContext) {
        self.modelContext = modelContext

        let descriptor = FetchDescriptor<Pet>()
        if let existing = try? modelContext.fetch(descriptor).first {
            self.pet = existing
        } else {
            let newPet = Pet()
            self.pet = newPet
            modelContext.insert(newPet)
            save()
        }
    }

    // MARK: - Actions

    /// Feeds the pet. Sets `feedBlocked = true` if no food is available.
    func feed() {
        guard pet.food > 0 else {
            feedBlocked = true
            // Auto-reset the flag after 0.6s so the UI can animate once
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(0.6))
                feedBlocked = false
            }
            return
        }
        objectWillChange.send()
        pet.food -= 1
        pet.needs.hunger    = min(1, pet.needs.hunger    + 0.3)
        pet.needs.happiness = min(1, pet.needs.happiness + 0.1)
        syncMood()
        save()
    }

    func play() {
        objectWillChange.send()
        pet.needs.happiness = min(1, pet.needs.happiness + 0.2)
        pet.needs.energy    = max(0, pet.needs.energy    - 0.1)
        syncMood()
        save()
    }

    func meditate() {
        objectWillChange.send()
        pet.needs.calm      = min(1, pet.needs.calm      + 0.25)
        pet.needs.happiness = min(1, pet.needs.happiness + 0.1)
        syncMood()
        save()
    }

    /// Applies stat boosts from a house item (cibo, essenziali, decorazioni).
    /// Cicla al prossimo colore nella palette PetColor e persiste l'indice.
    func cycleColor() {
        objectWillChange.send()
        let next = PetColor(rawValue: (pet.colorIndex + 1) % PetColor.allCases.count) ?? .cream
        pet.colorIndex = next.rawValue
        save()
    }

    /// Colore corrente del pet come PetColor.
    var currentPetColor: PetColor {
        PetColor(rawValue: pet.colorIndex) ?? .cream
    }

    func applyBoost(hunger: Double, happiness: Double, calm: Double, energy: Double) {
        objectWillChange.send()
        pet.needs.hunger    = min(1, pet.needs.hunger    + Float(hunger))
        pet.needs.happiness = min(1, pet.needs.happiness + Float(happiness))
        pet.needs.calm      = min(1, pet.needs.calm      + Float(calm))
        pet.needs.energy    = min(1, pet.needs.energy    + Float(energy))
        syncMood()
        save()
    }

    // MARK: - Mood Derivation (BUG-01 / BUG-06)

    /// Derives the pet mood from its current statistics and persists it.
    /// This is the single source of truth for mood — no caller should set
    /// `appState.mood` directly without going through this method.
    func derivedMood() -> PetMood {
        let n = pet.needs
        if n.energy < 0.2                          { return .sleepy   }  // BUG-03
        if n.calm < 0.3                            { return .anxious  }
        if n.hunger < 0.2 || n.happiness < 0.2    { return .sick     }
        if n.happiness > 0.85 && n.calm > 0.75    { return .happy    }
        if n.calm > 0.9 && n.happiness > 0.9      { return .evolving }
        return .calm
    }

    // MARK: - Private

    /// Syncs pet.moodRaw with the derived mood (BUG-06).
    private func syncMood() {
        pet.mood = derivedMood()
    }

    private func save() {
        do {
            try modelContext.save()
        } catch {
            // INJ-04: log instead of silently swallowing
            logger.error("SwiftData save failed: \(error.localizedDescription)")
        }
    }
}
