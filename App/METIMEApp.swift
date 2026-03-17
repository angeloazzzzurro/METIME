import SwiftUI
import SwiftData
import OSLog

// MARK: - METIMEApp

@main
struct METIMEApp: App {
    @StateObject private var appState = AppState()

    // INJ-06: rileva se siamo in modalità UI test
    private static let isUITesting = CommandLine.arguments.contains("--uitesting")

    // INJ-03: sostituisce fatalError con fallback in-memory
    private let container: ModelContainer = {
        let schema = Schema([Pet.self, PetNeeds.self])
        let logger = Logger(subsystem: "com.metime.app", category: "Container")

        // INJ-06: usa sempre in-memory durante i test UI
        let inMemory = METIMEApp.isUITesting

        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            logger.error("Primary ModelContainer failed: \(error.localizedDescription) — falling back to in-memory")
            // INJ-03: fallback in-memory invece di fatalError
            let fallback = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            return try! ModelContainer(for: schema, configurations: [fallback])
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

/// NON private: SwiftUI deve poter istanziare questa view come radice della WindowGroup.
struct ContentRoot: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ContentRootInner(modelContext: modelContext)
            .environmentObject(appState)
    }
}

// MARK: - ContentRootInner

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
