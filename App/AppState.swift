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

    // MARK: - Constants

    /// Allowlist: lettere, cifre, spazi e punteggiatura comune.
    private static let allowedCharacters = CharacterSet.alphanumerics
        .union(.whitespaces)
        .union(CharacterSet(charactersIn: "'-_!?."))

    static let maxNameLength = 20

    // MARK: - Stored Properties

    /// Nome grezzo — usare sempre `sanitizedName` per la visualizzazione.
    /// La validazione viene applicata in scrittura tramite `setName(_:)`.
    private(set) var name: String

    var stage: Int
    var food: Int
    var moodRaw: String
    /// Indice del colore corrente nella palette PetColor (persistito)
    var colorIndex: Int

    @Relationship(deleteRule: .cascade) var needs: PetNeeds

    // MARK: - Loggers

    private static let petLogger  = Logger(subsystem: "com.metime.app", category: "Pet")
    private static let moodLogger = Logger(subsystem: "com.metime.app", category: "Pet.Mood")

    // MARK: - Mood accessor (INJ-02)

    var mood: PetMood {
        get {
            if let m = PetMood(rawValue: moodRaw) { return m }
            Pet.moodLogger.warning("Invalid moodRaw '\(self.moodRaw)' — falling back to .calm")
            return .calm
        }
        set { moodRaw = newValue.rawValue }
    }

    // MARK: - Name validation (INJ-01 — scrittura)

    /// Imposta il nome applicando la allowlist e il limite di lunghezza.
    /// Sostituisce i caratteri non consentiti con uno spazio e tronca a `maxNameLength`.
    func setName(_ raw: String) {
        let filtered = raw.unicodeScalars
            .map { Pet.allowedCharacters.contains($0) ? Character($0) : Character(" ") }
            .reduce(into: "") { $0.append($1) }
        let trimmed = filtered.trimmingCharacters(in: .whitespaces)
        let result  = String(trimmed.prefix(Pet.maxNameLength))
        if result != raw {
            Pet.petLogger.info("Pet name sanitized: '\(raw)' → '\(result)'")
        }
        name = result.isEmpty ? "MeTime" : result
    }

    /// Display-safe name: rimuove eventuali caratteri di controllo Unicode residui.
    var sanitizedName: String {
        let stripped = name.unicodeScalars
            .filter { !$0.properties.isDefaultIgnorableCodePoint }
            .reduce(into: "") { $0.append(Character($1)) }
        return String(stripped.prefix(Pet.maxNameLength))
    }

    // MARK: - Init

    init(name: String = "MeTime",
         stage: Int = 0,
         food: Int = 3,
         mood: PetMood = .calm,
         colorIndex: Int = 0,
         needs: PetNeeds = PetNeeds()) {
        self.name       = name
        self.stage      = stage
        self.food       = food
        self.moodRaw    = mood.rawValue
        self.colorIndex = colorIndex
        self.needs      = needs
    }
}

// MARK: - MeditationSession (SwiftData)

@Model
final class MeditationSession {
    var date: Date
    var durationSeconds: Int
    var type: String            // "breathing" | "guided" | "free"

    init(date: Date = .now, durationSeconds: Int = 0, type: String = "free") {
        self.date = date
        self.durationSeconds = durationSeconds
        self.type = type
    }
}

// MARK: - GratitudeEntry (SwiftData)

@Model
final class GratitudeEntry {
    var date: Date
    var text: String

    init(date: Date = .now, text: String = "") {
        self.date = date
        self.text = text
    }
}

@Model
final class GardenState {
    var unlockedPlots: Int
    var terrainExpansionLevel: Int

    init(unlockedPlots: Int = 3, terrainExpansionLevel: Int = 0) {
        self.unlockedPlots = unlockedPlots
        self.terrainExpansionLevel = terrainExpansionLevel
    }
}

// MARK: - CareRitualStep

enum CareRitualStep: Int, CaseIterable {
    case grounding = 0
    case breathing = 1
    case gratitude = 2

    var title: String {
        switch self {
        case .grounding: "Grounding"
        case .breathing: "Breathing"
        case .gratitude: "Gratitude"
        }
    }

    var icon: String {
        switch self {
        case .grounding: "leaf.fill"
        case .breathing: "wind"
        case .gratitude: "heart.fill"
        }
    }

    var instruction: String {
        switch self {
        case .grounding: "Siediti comodo e rilassa le spalle. Senti i piedi a terra."
        case .breathing: "Inspira per 4 secondi, espira per 6 secondi."
        case .gratitude: "Scrivi una cosa positiva della tua giornata."
        }
    }
}

// MARK: - AppState

final class AppState: ObservableObject {
    @Published var mood: PetMood = .calm
}
