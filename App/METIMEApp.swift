import SwiftUI
import SwiftData
import OSLog

// MARK: - METIMEApp

@main
struct METIMEApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var navigationState = NavigationState()

    private static let isUITesting = CommandLine.arguments.contains("--uitesting")

    private let container: ModelContainer = {
        let schema = Schema([
            Pet.self,
            PetNeeds.self,
            OwnedItem.self,
            Wallet.self,
            MeditationSession.self,
            GratitudeEntry.self,
        ])
        let logger = Logger(subsystem: "com.metime.app", category: "Container")
        let inMemory = METIMEApp.isUITesting

        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: inMemory,
            allowsSave: true,
            groupContainer: .none,
            cloudKitDatabase: .none
        )

        do {
            let container = try ModelContainer(for: schema, configurations: [config])
            if !inMemory {
                applyDataProtection(to: container, logger: logger)
            }
            return container
        } catch {
            logger.error("Primary ModelContainer failed: \(error.localizedDescription) - falling back to in-memory")
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
                .environmentObject(navigationState)
                .modelContainer(container)
                .onAppear {
                    SoundscapeManager.shared.start(mood: .calm)
                }
        }
    }

    private static func applyDataProtection(to container: ModelContainer, logger: Logger) {
        guard let storeURL = container.configurations.first?.url else { return }
        let directory = storeURL.deletingLastPathComponent()
        let fm = FileManager.default
        guard let enumerator = fm.enumerator(
            at: directory,
            includingPropertiesForKeys: [.fileProtectionKey],
            options: [.skipsHiddenFiles]
        ) else { return }

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
    @EnvironmentObject private var navigationState: NavigationState

    var body: some View {
        ContentRootInner(modelContext: modelContext)
            .environmentObject(appState)
            .environmentObject(navigationState)
    }
}

// MARK: - ContentRootInner

private struct ContentRootInner: View {
    @StateObject private var gameStore: GameStore
    @StateObject private var houseStore: HouseStore

    init(modelContext: ModelContext) {
        let gameStore = GameStore(modelContext: modelContext)
        let houseStore = HouseStore(modelContext: modelContext)
        _gameStore = StateObject(wrappedValue: gameStore)
        _houseStore = StateObject(wrappedValue: houseStore)
    }

    @EnvironmentObject private var navigationState: NavigationState

    var body: some View {
        AppTabView()
            .environmentObject(gameStore)
            .environmentObject(houseStore)
            .environmentObject(navigationState)
    }
}

// MARK: - AppTabView

struct AppTabView: View {
    @EnvironmentObject var gameStore: GameStore
    @EnvironmentObject var houseStore: HouseStore

    var body: some View {
        MainPetView()
    }
}
