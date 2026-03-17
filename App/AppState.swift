import SwiftUI
import SwiftData
import OSLog

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
        self.hunger    = hunger
        self.happiness = happiness
        self.calm      = calm
        self.energy    = energy
    }
}

@Model
final class Pet {
    var name: String
    var stage: Int
    var food: Int
    var moodRaw: String
    @Relationship(deleteRule: .cascade) var needs: PetNeeds

    // MARK: - Mood accessor (INJ-02: validazione in lettura con logging)

    private static let moodLogger = Logger(subsystem: "com.metime.app", category: "Pet")

    var mood: PetMood {
        get {
            if let m = PetMood(rawValue: moodRaw) { return m }
            Pet.moodLogger.warning("Invalid moodRaw '\(self.moodRaw)' — falling back to .calm")
            return .calm
        }
        set { moodRaw = newValue.rawValue }
    }

    // MARK: - INJ-01: nome sanitizzato

    /// Returns `name` with control characters removed and length capped at 20.
    var sanitizedName: String {
        let stripped = name.unicodeScalars
            .filter { !$0.properties.isDefaultIgnorableCodePoint }
            .reduce(into: "") { $0.append(Character($1)) }
        return String(stripped.prefix(20))
    }

    // MARK: - Init

    init(name: String = "MeTime",
         stage: Int = 0,
         food: Int = 3,
         mood: PetMood = .calm,
         needs: PetNeeds = PetNeeds()) {
        self.name    = name
        self.stage   = stage
        self.food    = food
        self.moodRaw = mood.rawValue
        self.needs   = needs
    }
}

// MARK: - AppState

final class AppState: ObservableObject {
    @Published var mood: PetMood = .calm
}
