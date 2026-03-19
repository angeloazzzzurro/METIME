import SwiftUI
import SwiftData
import OSLog

// MARK: - METIMEApp

@main
struct METIMEApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var navigationState = NavigationState()

    private static let isUITesting = CommandLine.arguments.contains("--uitesting")
    private let bootstrap: AppBootstrap = {
        let schema = Schema([Pet.self, PetNeeds.self, OwnedItem.self, Wallet.self])
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
            let c = try ModelContainer(for: schema, configurations: [config])
            if !inMemory { applyDataProtection(to: c, logger: logger) }
            return .ready(c)
        } catch {
            logger.error("Primary ModelContainer failed: \(error.localizedDescription) — falling back to in-memory")
            let fallback = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            do {
                return .ready(try ModelContainer(for: schema, configurations: [fallback]))
            } catch {
                logger.fault("Fallback in-memory ModelContainer failed: \(error.localizedDescription)")
                return .failed(
                    "METIME non riesce a inizializzare i dati locali. " +
                    "Chiudi e riapri l'app. Se il problema continua, reinstalla l'app o cancella i dati corrotti."
                )
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootScene(bootstrap: bootstrap)
                .environmentObject(appState)
                .environmentObject(navigationState)
                .onAppear {
                    SoundscapeManager.shared.start(mood: .calm)
                }
        }
    }

    private static func applyDataProtection(to container: ModelContainer, logger: Logger) {
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

private enum AppBootstrap {
    case ready(ModelContainer)
    case failed(String)
}

private struct RootScene: View {
    let bootstrap: AppBootstrap

    var body: some View {
        switch bootstrap {
        case .ready(let container):
            ContentRoot()
                .modelContainer(container)
        case .failed(let message):
            StartupFailureView(message: message)
        }
    }
}

private struct StartupFailureView: View {
    let message: String

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.99, green: 0.92, blue: 0.95), Color(red: 0.94, green: 0.97, blue: 1.0)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.bubble.fill")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(.pink)

                Text("Avvio non riuscito")
                    .font(.system(.title2, design: .rounded).weight(.bold))

                Text(message)
                    .font(.system(.body, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
            }
            .padding(24)
            .background(.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .padding(24)
        }
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
        let gs = GameStore(modelContext: modelContext)
        let hs = HouseStore(modelContext: modelContext)
        _gameStore  = StateObject(wrappedValue: gs)
        _houseStore = StateObject(wrappedValue: hs)
    }

    @EnvironmentObject private var navigationState: NavigationState
    var body: some View {
        AppTabView()
            .environmentObject(gameStore)
            .environmentObject(houseStore)
            .environmentObject(navigationState)
    }
}

// MARK: - AppTabView (navigazione principale)

struct AppTabView: View {
    @EnvironmentObject var gameStore: GameStore
    @EnvironmentObject var houseStore: HouseStore
    @EnvironmentObject var navigationState: NavigationState

    var body: some View {
        if navigationState.activeSection == .home {
            HouseView()
                .environmentObject(gameStore)
                .environmentObject(houseStore)
                .environmentObject(navigationState)
        } else {
            MainPetView()
                .environmentObject(gameStore)
                .environmentObject(houseStore)
                .environmentObject(navigationState)
        }
    }
}
