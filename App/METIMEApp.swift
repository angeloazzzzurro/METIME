import SwiftUI
import SwiftData

@main
struct METIMEApp: App {
    @StateObject private var appState = AppState()

    // SwiftData container for Pet and PetNeeds
    private let container: ModelContainer = {
        let schema = Schema([Pet.self, PetNeeds.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentRoot()
                .environmentObject(appState)
                .modelContainer(container)
                .onAppear {
                    SoundscapeManager.shared.start(mood: .calm)
                }
        }
    }
}

// MARK: - ContentRoot

/// Bridges the SwiftData ModelContext into GameStore.
private struct ContentRoot: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        MainPetView()
            .environmentObject(GameStore(modelContext: modelContext))
    }
}
