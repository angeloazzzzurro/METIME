import SwiftUI
import SwiftData

@main
struct METIMEApp: App {
    @StateObject private var appState = AppState()

    // SwiftData container — creato una sola volta per tutta la vita dell'app
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
// NON private: SwiftUI deve poter istanziare questa view come radice della WindowGroup.
// Recupera il ModelContext dall'environment e costruisce GameStore una sola volta
// tramite @StateObject per evitare re-creazioni ad ogni re-render.
struct ContentRoot: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ContentRootInner(modelContext: modelContext)
            .environmentObject(appState)
    }
}

// Wrapper interno che crea GameStore una sola volta con @StateObject
private struct ContentRootInner: View {
    @StateObject private var store: GameStore

    init(modelContext: ModelContext) {
        _store = StateObject(wrappedValue: GameStore(modelContext: modelContext))
    }

    var body: some View {
        MainPetView()
            .environmentObject(store)
    }
}
