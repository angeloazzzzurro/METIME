import SwiftUI

final class AppState: ObservableObject {
    @Published var mood: PetMood = .calm
}

enum PetMood: String, CaseIterable {
    case calm
    case happy
    case anxious
    case sleepy
    case sick
    case evolving
}

struct PetNeeds {
    var hunger: Float = 0.8
    var happiness: Float = 0.8
    var calm: Float = 0.7
    var energy: Float = 0.9
}

struct Pet {
    var name: String = "MeTime"
    var stage: Int = 0
    var needs: PetNeeds = .init()
    var food: Int = 3
}
