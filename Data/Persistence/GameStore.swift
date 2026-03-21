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
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(0.6))
                feedBlocked = false
            }
            return
        }

        objectWillChange.send()
        pet.food -= 1
        pet.needs.hunger = min(1, pet.needs.hunger + 0.3)
        pet.needs.happiness = min(1, pet.needs.happiness + 0.1)
        syncMood()
        save()
    }

    func play() {
        objectWillChange.send()
        pet.needs.happiness = min(1, pet.needs.happiness + 0.2)
        pet.needs.energy = max(0, pet.needs.energy - 0.1)
        syncMood()
        save()
    }

    func meditate() {
        objectWillChange.send()
        pet.needs.calm = min(1, pet.needs.calm + 0.25)
        pet.needs.happiness = min(1, pet.needs.happiness + 0.1)
        syncMood()
        save()
    }

    /// Cycles to the next pet color in the palette and persists it.
    func cycleColor() {
        objectWillChange.send()
        let next = PetColor(rawValue: (pet.colorIndex + 1) % PetColor.allCases.count) ?? .cream
        pet.colorIndex = next.rawValue
        save()
    }

    var currentPetColor: PetColor {
        PetColor(rawValue: pet.colorIndex) ?? .cream
    }

    /// Applies stat boosts from a house item or a reward.
    func applyBoost(hunger: Double, happiness: Double, calm: Double, energy: Double) {
        objectWillChange.send()
        pet.needs.hunger = min(1, pet.needs.hunger + Float(hunger))
        pet.needs.happiness = min(1, pet.needs.happiness + Float(happiness))
        pet.needs.calm = min(1, pet.needs.calm + Float(calm))
        pet.needs.energy = min(1, pet.needs.energy + Float(energy))
        syncMood()
        save()
    }

    /// Complete a timed meditation session; boosts calm proportional to duration.
    func completeMeditation(durationSeconds: Int, type: String = "free") {
        objectWillChange.send()
        let bonus = min(Float(durationSeconds) / 240.0, 1.0) * 0.35
        pet.needs.calm = min(1, pet.needs.calm + bonus)
        pet.needs.happiness = min(1, pet.needs.happiness + 0.15)
        pet.needs.energy = min(1, pet.needs.energy + 0.1)

        let session = MeditationSession(durationSeconds: durationSeconds, type: type)
        modelContext.insert(session)
        syncMood()
        save()
    }

    /// Complete the 3-step care ritual. Awards large stat boosts.
    func completeCareRitual(gratitudeText: String) {
        objectWillChange.send()
        pet.needs.calm = min(1, pet.needs.calm + 0.4)
        pet.needs.happiness = min(1, pet.needs.happiness + 0.25)
        pet.needs.hunger = min(1, pet.needs.hunger + 0.1)
        pet.needs.energy = min(1, pet.needs.energy + 0.15)
        pet.food += 2

        if !gratitudeText.isEmpty {
            let entry = GratitudeEntry(text: gratitudeText)
            modelContext.insert(entry)
        }

        let session = MeditationSession(durationSeconds: 240, type: "care_ritual")
        modelContext.insert(session)
        syncMood()
        save()
    }

    func recentSessions(limit: Int = 10) -> [MeditationSession] {
        var descriptor = FetchDescriptor<MeditationSession>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func recentGratitude(limit: Int = 10) -> [GratitudeEntry] {
        var descriptor = FetchDescriptor<GratitudeEntry>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    // MARK: - Mood Derivation

    /// Derives the pet mood from its current statistics and persists it.
    func derivedMood() -> PetMood {
        let needs = pet.needs
        if needs.energy < 0.2 { return .sleepy }
        if needs.calm < 0.3 { return .anxious }
        if needs.hunger < 0.2 || needs.happiness < 0.2 { return .sick }
        if needs.calm > 0.9 && needs.happiness > 0.9 { return .evolving }
        if needs.happiness > 0.85 && needs.calm > 0.75 { return .happy }
        return .calm
    }

    private func syncMood() {
        pet.mood = derivedMood()
    }

    // MARK: - Persistence

    private func save() {
        do {
            try modelContext.save()
        } catch {
            logger.error("SwiftData save failed: \(error.localizedDescription)")
        }
    }
}
