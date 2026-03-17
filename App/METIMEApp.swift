import SwiftUI
import SwiftData
import OSLog

// MARK: - METIMEApp

@main
struct METIMEApp: App {
    @StateObject private var appState = AppState()

    // INJ-06: rileva se siamo in modalità UI test
    private static let isUITesting = CommandLine.arguments.contains("--uitesting")

    private let container: ModelContainer = {
        let schema = Schema([Pet.self, PetNeeds.self])
        let logger = Logger(subsystem: "com.metime.app", category: "Container")
        let inMemory = METIMEApp.isUITesting

        // DATA PROTECTION: i file SwiftData vengono cifrati con la chiave
        // derivata dal passcode dell'utente. Il file è accessibile solo
        // quando il dispositivo è sbloccato o in background dopo il primo sblocco.
        // Richiede il capability "Data Protection" abilitato in Xcode.
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: inMemory,
            allowsSave: true,
            groupContainer: .none,
            cloudKitDatabase: .none
        )

        do {
            let c = try ModelContainer(for: schema, configurations: [config])

            // Applica Data Protection al file del database dopo la creazione
            if !inMemory {
                applyDataProtection(to: c, logger: logger)
            }
            return c
        } catch {
            // INJ-03: fallback in-memory invece di fatalError
            logger.error("Primary ModelContainer failed: \(error.localizedDescription) — falling back to in-memory")
            let fallback = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            do {
                return try ModelContainer(for: schema, configurations: [fallback])
            } catch {
                fatalError("Failed to create fallback in-memory container: \(error.localizedDescription)")
            }
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

    // MARK: - Data Protection Helper

    /// Applica `FileProtectionType.completeUnlessOpen` a tutti i file
    /// nella directory del container SwiftData.
    private static func applyDataProtection(to container: ModelContainer,
                                            logger: Logger) {
        guard let storeURL = container.configurations.first?.url else { return }
        let directory = storeURL.deletingLastPathComponent()

        let fm = FileManager.default
        guard let enumerator = fm.enumerator(at: directory,
                                              includingPropertiesForKeys: [.fileProtectionKey],
                                              options: [.skipsHiddenFiles]) else { return }

        for case let fileURL as URL in enumerator {
            do {
                try fm.setAttributes(
                    [.protectionKey: FileProtectionType.completeUnlessOpen],
                    ofItemAtPath: fileURL.path
                )
            } catch {
                logger.warning("Could not set Data Protection on \(fileURL.lastPathComponent): \(error.localizedDescription)")
            }
        }
        logger.info("Data Protection applied to SwiftData store at \(directory.path)")
    }
}

// MARK: - ContentRoot

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
