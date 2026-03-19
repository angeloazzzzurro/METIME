    // Lista delle sezioni navigabili (solo quelle principali)
    private let sections: [ActiveSection] = [.home, .garden, .store, .inventory, .decorate, .meTime]
import SwiftUI
import SpriteKit

// MARK: - MainPetView

/// Homepage principale di METIME.
/// Barra di navigazione fissa in alto (come nel mockup), contenuto sezione sotto.
struct MainPetView: View {

    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var store: GameStore
    @EnvironmentObject private var navigationState: NavigationState
    @EnvironmentObject private var houseStore: HouseStore

    @State private var showJournal = false
    @State private var feedShake: CGFloat = 0

    // Scena SpriteKit inizializzata una sola volta
    @State private var scene: GardenScene = {
        let s = GardenScene(size: UIScreen.main.bounds.size)
        s.scaleMode = .resizeFill
        return s
    }()

    var body: some View {
        ZStack(alignment: .top) {
            kawaiiBg.ignoresSafeArea()
            KawaiiDecorations().ignoresSafeArea()

            VStack(spacing: 0) {
                // ── Barra di navigazione fissa in alto ──
                navBar

                // ── Contenuto sezione attiva ──
                Group {
                    switch navigationState.activeSection {
                    case .home:
                        homeSection
                    case .garden:
                        GardenSectionView()
                            .environmentObject(appState)
                            .environmentObject(store)
                    case .store:
                        StoreView()
                            .environmentObject(houseStore)
                            .environmentObject(navigationState)
                    case .inventory:
                        Text("Zaino")
                            .font(.largeTitle)
                            .foregroundColor(Color(hex: "#60A5FA"))
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    case .decorate:
                        Text("Decora")
                            .font(.largeTitle)
                            .foregroundColor(Color(hex: "#A78BFA"))
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    case .meTime:
                        NavigationStack {
                            CareRitualMockupView()
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        // ── Gesture swipe per navigazione tra sezioni ──
        .gesture(
            DragGesture(minimumDistance: 30, coordinateSpace: .local)
                .onEnded { value in
                    let horizontal = value.translation.width
                    guard abs(horizontal) > 30 else { return }
                    let currentIndex = sections.firstIndex(of: navigationState.activeSection) ?? 0
                    if horizontal < 0, currentIndex < sections.count - 1 {
                        navigationState.activeSection = sections[currentIndex + 1]
                    } else if horizontal > 0, currentIndex > 0 {
                        navigationState.activeSection = sections[currentIndex - 1]
                    }
                }
        )
        .onChange(of: store.pet.needs.hunger)    { _, _ in syncMood() }
        .onChange(of: store.pet.needs.happiness) { _, _ in syncMood() }
        .onChange(of: store.pet.needs.calm)      { _, _ in syncMood() }
        .onChange(of: store.pet.needs.energy)    { _, _ in syncMood() }
        .onChange(of: store.feedBlocked) { _, blocked in
            if blocked { triggerShake() }
        }
        .sheet(isPresented: $showJournal) {
            NavigationStack {
                JournalInsightsMockupView()
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Chiudi") { showJournal = false }
                        }
                    }
            }
        }
    }

    // MARK: - Nav Bar (fissa in alto)

    private var navBar: some View {
        VStack(spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    HomePetNavButton(icon: "bag.fill", label: "Store", color: Color(hex: "#F87171")) {
                        navigationState.activeSection = .store
                    }
                    HomePetNavButton(icon: "backpack.fill", label: "Zaino", color: Color(hex: "#60A5FA")) {
                        navigationState.activeSection = .inventory
                    }
                    HomePetNavButton(icon: "wand.and.stars", label: "Decora", color: Color(hex: "#A78BFA")) {
                        navigationState.activeSection = .decorate
                    }
                    HomePetNavButton(icon: "sparkles.rectangle.stack.fill", label: "Me Time", color: Color(hex: "#F59E0B")) {
                        navigationState.activeSection = .meTime
                    }
                        Menu {
                            ForEach(sections, id: \.self) { section in
                                Button(action: { navigationState.activeSection = section }) {
                                    Text(section.label)
                                }
                            }
                        } label: {
                            HomePetNavButton(icon: "ellipsis.circle", label: "Altro", color: Color(hex: "#10B981")) {}
                        }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 8)
            }
            .background(Color.white)
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.08), radius: 8, y: 2)

            HStack(spacing: 0) {
                HomePetTabButton(
                    icon: "leaf",
                    label: "Giardino",
                    selected: navigationState.activeSection == .garden
                ) {
                    navigationState.activeSection = .garden
                }
                HomePetTabButton(
                    icon: "house.fill",
                    label: "Casa",
                    selected: navigationState.activeSection == .home
                ) {
                    navigationState.activeSection = .home
                }
            }
            .frame(height: 56)
            .background(Color.white)
            .cornerRadius(18)
            .shadow(color: Color.black.opacity(0.06), radius: 6, y: 1)
            .padding(.horizontal, 32)
        }
        .padding(.top, 8)
        .padding(.bottom, 4)
        .padding(.horizontal, 16)
    }

    // MARK: - Home Section

    private var homeSection: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                SpriteView(scene: scene, options: [.allowsTransparency])
                    .frame(width: geo.size.width, height: geo.size.height * 0.60)
                    .onChange(of: appState.mood) { _, mood in
                        scene.mood = mood
                        SoundscapeManager.shared.transition(to: mood)
                    }
                    .onChange(of: store.pet.colorIndex) { _, _ in
                        scene.applyPetColor(store.currentPetColor, animated: true)
                    }
                    .onAppear {
                        let isoSize = CGSize(width: geo.size.width,
                                             height: geo.size.height * 0.60)
                        scene = {
                            let s = GardenScene(size: isoSize)
                            s.scaleMode = .resizeFill
                            s.mood = appState.mood
                            s.applyPetColor(store.currentPetColor, animated: false)
                            s.onPetTapped = { [weak store] in
                                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                                store?.cycleColor()
                            }
                            return s
                        }()
                    }

                Spacer(minLength: 0)

                pillGrid
                    .padding(.horizontal, 28)
                    .padding(.bottom, 24)
            }
        }
    }

    // MARK: - Pill Grid

    private var pillGrid: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                pill(
                    label: "Hunger",
                    color: Color(hex: "#A78BFA"),
                    badge: store.pet.food == 0 ? "!" : nil
                ) {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    store.feed()
                }
                .offset(x: feedShake)

                pill(label: "Happiness", color: Color(hex: "#F87171")) {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    store.play()
                }
            }
            HStack(spacing: 12) {
                pill(label: "Calm", color: Color(hex: "#60A5FA")) {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    store.meditate()
                }
                pill(label: "Energy", color: Color(hex: "#34D399")) {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    showJournal = true
                }
            }
        }
    }

    private func pill(
        label: String,
        color: Color,
        badge: String? = nil,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                Text(label)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        Capsule()
                            .fill(color)
                            .shadow(color: color.opacity(0.45), radius: 8, y: 4)
                    )

                if let badge {
                    Text(badge)
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(.white)
                        .padding(4)
                        .background(Color.red, in: Circle())
                        .offset(x: -4, y: 4)
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Mood Badge

    private var moodBadge: some View {
        HStack(spacing: 6) {
            Text(moodEmoji(appState.mood))
                .font(.system(size: 15))
            Text(appState.mood.rawValue.capitalized)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(Color(hex: "#5B3F8C"))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 7)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.72))
                .shadow(color: Color.purple.opacity(0.12), radius: 6, y: 3)
        )
    }

    // MARK: - Helpers

    private func syncMood() {
        let derived = store.derivedMood()
        if appState.mood != derived { appState.mood = derived }
    }

    private func triggerShake() {
        withAnimation(.spring(response: 0.1, dampingFraction: 0.3).repeatCount(4, autoreverses: true)) {
            feedShake = 6
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { feedShake = 0 }
    }

    private func moodEmoji(_ mood: PetMood) -> String {
        switch mood {
        case .calm:     return "🌿"
        case .happy:    return "✨"
        case .anxious:  return "😰"
        case .sleepy:   return "😴"
        case .sick:     return "🤒"
        case .evolving: return "🌟"
        }
    }
}

// MARK: - HomePetNavButton

private struct HomePetNavButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(10)
                    .background(color)
                    .clipShape(Capsule())
                Text(label)
                    .font(.headline.weight(.semibold))
                    .foregroundColor(color)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .background(color.opacity(0.12))
            .cornerRadius(18)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - HomePetTabButton

private struct HomePetTabButton: View {
    let icon: String
    let label: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(selected ? Color(hex: "#A78BFA") : Color.gray.opacity(0.6))
                Text(label)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(selected ? Color(hex: "#A78BFA") : Color.gray.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Color hex helper

extension Color {
    init(hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: h).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >>  8) & 0xFF) / 255
        let b = Double( int        & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
