import SwiftUI
import SpriteKit

// MARK: - MainPetView

/// Homepage principale di METIME.
/// Stile fedele al mockup originale:
/// - Sfondo gradiente rosa (#FFD6E0) → lavanda (#E8D5F5)
/// - Nome "Me" + badge mood centrati in alto
/// - Giardino isometrico SpriteKit al centro (pet bianco/rosa, alberi verdi, fiori)
/// - Quattro pill colorate in basso (Hunger viola, Happiness corallo, Calm azzurro, Energy verde)
struct MainPetView: View {

    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var store: GameStore

    @State private var showJournal = false
    @State private var feedShake: CGFloat = 0

    // Scena SpriteKit inizializzata una sola volta (BUG-03 fix)
    @State private var scene: GardenScene = {
        let s = GardenScene(size: UIScreen.main.bounds.size)
        s.scaleMode = .resizeFill
        return s
    }()

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // ── Sfondo rosa → lavanda ────────────────────────────────
                LinearGradient(
                    colors: [
                        Color(hex: "#FFD6E0"),
                        Color(hex: "#E8D5F5")
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {

                    // ── Nome + badge mood ────────────────────────────────
                    VStack(spacing: 8) {
                        Text(store.pet.sanitizedName)
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "#3D2C5E"))

                        moodBadge
                    }
                    .padding(.top, geo.safeAreaInsets.top + 20)
                    .padding(.bottom, 4)

                    // ── Giardino SpriteKit isometrico ────────────────────
                    SpriteView(scene: scene, options: [.allowsTransparency])
                        .frame(width: geo.size.width, height: geo.size.height * 0.54)
                        .onChange(of: appState.mood) { _, mood in
                            scene.mood = mood
                            SoundscapeManager.shared.transition(to: mood)
                        }
                        .onChange(of: store.pet.colorIndex) { _, _ in
                            scene.applyPetColor(store.currentPetColor, animated: true)
                        }
                        .onAppear {
                            let isoSize = CGSize(width: geo.size.width,
                                                 height: geo.size.height * 0.54)
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

                    // ── Quattro pill colorate ────────────────────────────
                    pillGrid
                        .padding(.horizontal, 28)
                        .padding(.bottom, geo.safeAreaInsets.bottom + 20)
                }
            }
        }
        // Sincronizzazione mood da GameStore
        .onChange(of: store.pet.needs.hunger)    { _, _ in syncMood() }
        .onChange(of: store.pet.needs.happiness) { _, _ in syncMood() }
        .onChange(of: store.pet.needs.calm)      { _, _ in syncMood() }
        .onChange(of: store.pet.needs.energy)    { _, _ in syncMood() }
        // Shake quando cibo esaurito (BUG-02)
        .onChange(of: store.feedBlocked) { _, blocked in
            if blocked { triggerShake() }
        }
        // Sheet diario (BUG-04)
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
