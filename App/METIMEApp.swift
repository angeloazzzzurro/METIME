import SwiftUI

@main
struct METIMEApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var store = GameStore()

    var body: some Scene {
        WindowGroup {
            MainPetView()
                .environmentObject(appState)
                .environmentObject(store)
                .onAppear {
                    SoundscapeManager.shared.start(mood: .calm)
                }
        }
    }
}
