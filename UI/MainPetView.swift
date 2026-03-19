import SwiftUI
import SpriteKit

// MARK: - MainPetView

/// Homepage principale di METIME.
/// Barra di navigazione fissa in alto (come nel mockup), contenuto sezione sotto.
struct MainPetView: View {
    private let sections: [NavigationState.Section] = [.home, .garden, .store, .inventory, .decorate, .meTime]

    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var store: GameStore
    @EnvironmentObject private var navigationState: NavigationState
    @EnvironmentObject private var houseStore: HouseStore

    @State private var showJournal = false
    @State private var feedShake: CGFloat = 0
    @State private var sceneSize: CGSize = .zero

    // Scena SpriteKit inizializzata una sola volta
    @State private var scene: GardenScene = {
        let s = GardenScene(size: CGSize(width: 390, height: 520))
        s.scaleMode = .resizeFill
        return s
    }()

    var body: some View {
        ZStack(alignment: .top) {
            kawaiiBg.ignoresSafeArea()

            VStack(spacing: 0) {
                // ── Barra di navigazione fissa in alto ──
                navBar

                ZStack(alignment: .topLeading) {
                    currentSection
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    if navigationState.activeSection != .home {
                        backButton
                            .padding(.top, 14)
                            .padding(.leading, 20)
                    }
                }
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
                        navigationState.navigate(to: sections[currentIndex + 1])
                    } else if horizontal > 0, currentIndex > 0 {
                        navigationState.navigate(to: sections[currentIndex - 1])
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
                    HomePetNavButton(icon: "bag.fill", label: "Store 🛒", color: Color(hex: "#F87171")) {
                        navigationState.navigate(to: .store)
                    }
                    HomePetNavButton(icon: "wand.and.stars", label: "Decora ✨", color: Color(hex: "#A78BFA")) {
                        navigationState.navigate(to: .decorate)
                    }
                    HomePetNavButton(icon: "sparkles.rectangle.stack.fill", label: "Me Time 💖", color: Color(hex: "#F59E0B")) {
                        navigationState.navigate(to: .meTime)
                    }
                    // HomePetNavButton(icon: "backpack.fill", label: "Zaino", color: Color(hex: "#60A5FA")) {
                    //     navigationState.navigate(to: .inventory)
                    // }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 8)
            }
            .scrollClipDisabled()
            .background(Color.white)
            .cornerRadius(28)
            .background(PetColor.cream.color)
            .shadow(color: Color(hex: "#F59E0B").opacity(0.07), radius: 18, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(PetColor.lilac.color.opacity(0.18), lineWidth: 1.5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.white.opacity(0.08))
            )

            HStack(spacing: 0) {
                HomePetTabButton(
                    icon: "leaf",
                    label: "Giardino",
                    selected: navigationState.activeSection == .garden
                ) {
                    navigationState.navigate(to: .garden)
                }
                HomePetTabButton(
                    icon: "house.fill",
                    label: "Casa",
                    selected: navigationState.activeSection == .home
                ) {
                    navigationState.navigate(to: .home)
                }
            }
            .frame(height: 56)
            .background(Color.white)
            .cornerRadius(22)
            .background(PetColor.peach.color)
            .shadow(color: Color(hex: "#A78BFA").opacity(0.06), radius: 14, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(PetColor.lilac.color.opacity(0.14), lineWidth: 1.2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color.white.opacity(0.06))
            )
            .padding(.horizontal, 32)
        }
        .padding(.top, 8)
        .padding(.bottom, 4)
        .padding(.horizontal, 16)
    }

    private var currentSection: some View {
        Group {
            switch navigationState.activeSection {
            case .home, .garden:
                homeSection
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
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    private var backButton: some View {
        Button {
            navigationState.navigate(to: .home)
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 13, weight: .black))
                Text("Torna alla Home")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
            }
            .foregroundStyle(Color(hex: "#6B4E98"))
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color.white.opacity(0.95))
            .overlay {
                Capsule()
                    .stroke(Color(hex: "#D3BCEC"), lineWidth: 1.2)
            }
            .clipShape(Capsule())
            .shadow(color: Color.black.opacity(0.08), radius: 8, y: 3)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Home Section

    private var homeSection: some View {
        GeometryReader { geo in
            let sceneHeight = min(max(geo.size.height * 0.56, 260), 520)
            let compact = geo.size.width < 390 || geo.size.height < 760

            VStack(spacing: 0) {
                SpriteView(scene: scene, options: [.allowsTransparency])
                    .frame(width: geo.size.width, height: sceneHeight)
                    .onChange(of: appState.mood) { _, mood in
                        scene.mood = mood
                        SoundscapeManager.shared.transition(to: mood)
                    }
                    .onChange(of: store.pet.colorIndex) { _, _ in
                        scene.applyPetColor(store.currentPetColor, animated: true)
                    }
                    .onChange(of: geo.size) { _, newSize in
                        configureScene(for: CGSize(width: newSize.width, height: min(max(newSize.height * 0.56, 260), 520)))
                    }
                    .onAppear {
                        configureScene(for: CGSize(width: geo.size.width, height: sceneHeight))
                    }

                Spacer(minLength: compact ? 8 : 14)

                pillGrid(compact: compact)
                    .padding(.horizontal, compact ? 18 : 28)
                    .padding(.bottom, compact ? 16 : 24)
            }
        }
    }

    // MARK: - Pill Grid

    private func pillGrid(compact: Bool) -> some View {
        let columns = compact ? [GridItem(.flexible()), GridItem(.flexible())] : [GridItem(.flexible()), GridItem(.flexible())]

        return LazyVGrid(columns: columns, spacing: 12) {
            pill(
                label: "🍖 Hunger",
                color: Color(hex: "#A78BFA"),
                badge: store.pet.food == 0 ? "!" : nil
            ) {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                store.feed()
            }
            .offset(x: feedShake)

            pill(label: "😊 Happiness", color: Color(hex: "#F87171")) {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                store.play()
            }

            pill(label: "🌿 Calm", color: Color(hex: "#60A5FA")) {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                store.meditate()
            }

            pill(label: "⚡ Energy", color: Color(hex: "#34D399")) {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                showJournal = true
            }
        }
    }

    private func configureScene(for size: CGSize) {
        guard sceneSize != size else { return }
        sceneSize = size

        let updatedScene = GardenScene(size: size)
        updatedScene.scaleMode = .resizeFill
        updatedScene.mood = appState.mood
        updatedScene.applyPetColor(store.currentPetColor, animated: false)
        updatedScene.onPetTapped = { [weak store] in
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            store?.cycleColor()
        }
        scene = updatedScene
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

    private func sectionPlaceholder(
        title: String,
        subtitle: String,
        icon: String,
        color: Color
    ) -> some View {
        VStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 42, weight: .bold))
                .foregroundStyle(color)
            Text(title)
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundStyle(color)
                .padding(.bottom, 2)
            Text(subtitle)
                .font(.system(size: 15, weight: .light, design: .rounded))
                .foregroundStyle(Color(hex: "#6B5A7F"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Background

    private var kawaiiBg: some View {
        LinearGradient(
            colors: [Color(hex: "#F0E6FF"), Color(hex: "#E8D5F5"), Color(hex: "#D9C0F0")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
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
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .padding(14)
                    .background(color)
                    .clipShape(Circle())
                Text(label)
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundColor(color)
                    .padding(.vertical, 2)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background(color.opacity(0.14))
            .cornerRadius(28)
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
