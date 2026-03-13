import Foundation

// MARK: - AudioResource

/// Type-safe identifiers for all audio files bundled in the app.
/// Eliminates hardcoded strings scattered across the codebase.
enum AudioResource {

    // MARK: - Ambient Loops

    /// Ambient soundscape loops, keyed by pet mood.
    enum Ambient: String, CaseIterable {
        case calm     = "ambient_calm"
        case happy    = "ambient_happy"
        case anxious  = "ambient_anxious"
        case sleepy   = "ambient_sleepy"
        case sick     = "ambient_sick"

        /// File extension used for all ambient loops.
        static let ext = "m4a"

        /// Returns the `Ambient` track matching a given `PetMood`.
        static func track(for mood: PetMood) -> Ambient {
            switch mood {
            case .calm:              return .calm
            case .happy, .evolving:  return .happy
            case .anxious:           return .anxious
            case .sleepy:            return .sleepy
            case .sick:              return .sick
            }
        }
    }

    // MARK: - Sound Effects

    /// One-shot sound effects.
    enum SFX: String, CaseIterable {
        case gentleBell = "gentle_bell"

        /// File extension used for all SFX files.
        static let ext = "caf"
    }
}

// MARK: - SpriteResource

/// Type-safe identifiers for sprite image assets.
enum SpriteResource: String, CaseIterable {
    case egg    = "pet_egg"
    case sprout = "pet_sprout"
    case bloom  = "pet_bloom"
    case spirit = "pet_spirit"
    case legend = "pet_legend"

    /// Returns the sprite matching the pet's evolution stage.
    static func sprite(forStage stage: Int) -> SpriteResource {
        switch stage {
        case 0:  return .egg
        case 1:  return .sprout
        case 2:  return .bloom
        case 3:  return .spirit
        default: return .legend
        }
    }
}

// MARK: - ColorResource

/// Type-safe identifiers for named colors in Assets.xcassets.
enum ColorResource: String, CaseIterable {
    case bgCalm     = "BgCalm"
    case bgHappy    = "BgHappy"
    case bgAnxious  = "BgAnxious"
    case bgSleepy   = "BgSleepy"
    case bgSick     = "BgSick"
    case bgEvolving = "BgEvolving"

    /// Returns the background color name matching a given `PetMood`.
    static func background(for mood: PetMood) -> ColorResource {
        switch mood {
        case .calm:     return .bgCalm
        case .happy:    return .bgHappy
        case .anxious:  return .bgAnxious
        case .sleepy:   return .bgSleepy
        case .sick:     return .bgSick
        case .evolving: return .bgEvolving
        }
    }
}
