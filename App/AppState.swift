import SwiftUI
import SwiftData

// MARK: - Mood

enum PetMood: String, CaseIterable, Codable {
    case calm
    case happy
    case anxious
    case sleepy
    case sick
    case evolving
}

// MARK: - SwiftData Models

@Model
final class PetNeeds {
    var hunger: Float
    var happiness: Float
    var calm: Float
    var energy: Float

    init(hunger: Float = 0.8,
         happiness: Float = 0.8,
         calm: Float = 0.7,
         energy: Float = 0.9) {
        self.hunger = hunger
        self.happiness = happiness
        self.calm = calm
        self.energy = energy
    }
}

@Model
final class Pet {
    var name: String
    var stage: Int
    var food: Int
    var moodRaw: String
    @Relationship(deleteRule: .cascade) var needs: PetNeeds

    var mood: PetMood {
        get { PetMood(rawValue: moodRaw) ?? .calm }
        set { moodRaw = newValue.rawValue }
    }

    init(name: String = "MeTime",
         stage: Int = 0,
         food: Int = 3,
         mood: PetMood = .calm,
         needs: PetNeeds = PetNeeds()) {
        self.name = name
        self.stage = stage
        self.food = food
        self.moodRaw = mood.rawValue
        self.needs = needs
    }
}

// MARK: - AppState

final class AppState: ObservableObject {
    @Published var mood: PetMood = .calm
}
