import Foundation
import SwiftUI

@MainActor
final class GameStore: ObservableObject {
    @Published var pet: Pet = .init()

    func feed() {
        guard pet.food > 0 else { return }
        pet.food -= 1
        pet.needs.hunger = min(1, pet.needs.hunger + 0.3)
        pet.needs.happiness = min(1, pet.needs.happiness + 0.1)
    }

    func play() {
        pet.needs.happiness = min(1, pet.needs.happiness + 0.2)
        pet.needs.energy = max(0, pet.needs.energy - 0.1)
    }
}
