import Foundation
import SwiftUI
import SwiftData

// MARK: - GameStore

/// Manages the pet's game state and persists it via SwiftData.
/// Conforms to ObservableObject so it can be injected via @EnvironmentObject.
/// Pet mutations trigger objectWillChange manually to propagate nested changes
/// (e.g. pet.needs.hunger) to the SwiftUI view hierarchy.
@MainActor
final class GameStore: ObservableObject {

    // MARK: - State
    // Non usiamo @Published su Pet (@Model) per evitare conflitti con
    // il sistema di osservazione interno di SwiftData.
    // Le notifiche vengono inviate manualmente tramite objectWillChange.send().
    private(set) var pet: Pet

    // MARK: - Private
    private let modelContext: ModelContext

    // MARK: - Init

    init(modelContext: ModelContext) {
        self.modelContext = modelContext

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
        objectWillChange.send()
        pet.food -= 1
        pet.needs.hunger    = min(1, pet.needs.hunger    + 0.3)
        pet.needs.happiness = min(1, pet.needs.happiness + 0.1)
        save()
    }

    func play() {
        objectWillChange.send()
        pet.needs.happiness = min(1, pet.needs.happiness + 0.2)
        pet.needs.energy    = max(0, pet.needs.energy    - 0.1)
        save()
    }

    func meditate() {
        objectWillChange.send()
        pet.needs.calm      = min(1, pet.needs.calm      + 0.25)
        pet.needs.happiness = min(1, pet.needs.happiness + 0.1)
        save()
    }

    // MARK: - Persistence

    private func save() {
        try? modelContext.save()
    }
}
