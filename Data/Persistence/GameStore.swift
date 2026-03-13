import Foundation
import SwiftUI
import SwiftData

// MARK: - GameStore

/// Manages the pet's game state and persists it via SwiftData.
/// All mutations must happen on the main actor to keep the UI in sync.
@MainActor
final class GameStore: ObservableObject {

    // MARK: - Published State

    @Published private(set) var pet: Pet

    // MARK: - Private

    private let modelContext: ModelContext

    // MARK: - Init

    init(modelContext: ModelContext) {
        self.modelContext = modelContext

        // Load existing pet or create a new one
        let descriptor = FetchDescriptor<Pet>()
        if let existing = try? modelContext.fetch(descriptor).first {
            self.pet = existing
        } else {
            let newPet = Pet()
            modelContext.insert(newPet)
            try? modelContext.save()
            self.pet = newPet
        }
    }

    // MARK: - Actions

    func feed() {
        guard pet.food > 0 else { return }
        pet.food -= 1
        pet.needs.hunger    = min(1, pet.needs.hunger    + 0.3)
        pet.needs.happiness = min(1, pet.needs.happiness + 0.1)
        save()
    }

    func play() {
        pet.needs.happiness = min(1, pet.needs.happiness + 0.2)
        pet.needs.energy    = max(0, pet.needs.energy    - 0.1)
        save()
    }

    func meditate() {
        pet.needs.calm      = min(1, pet.needs.calm      + 0.25)
        pet.needs.happiness = min(1, pet.needs.happiness + 0.1)
        save()
    }

    // MARK: - Persistence

    private func save() {
        try? modelContext.save()
        objectWillChange.send()
    }
}
