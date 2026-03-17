import SwiftUI
import SpriteKit

// MARK: - MainPetView

struct MainPetView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var store: GameStore

    @State private var showJournal = false
    @State private var feedShake: CGFloat = 0

    // INJ-05: dimensioni lette da GeometryReader, non da UIScreen.main (deprecato)
    @State private var sceneSize: CGSize = UIScreen.main.bounds.size

    @State private var scene: GardenScene = {
        let s = GardenScene(size: UIScreen.main.bounds.size)
        s.scaleMode = .resizeFill
        return s
    }()

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                kawaiiBg.ignoresSafeArea()
                KawaiiDecorations().ignoresSafeArea()

                // Scena isometrica: occupa la fascia centrale della schermata
                // lasciando spazio all'HUD in alto e all'action bar in basso.
                SceneView(scene: scene, options: [.allowsTransparency])
                    .frame(width: geo.size.width,
                           height: geo.size.height * 0.58)
                    .offset(y: geo.size.height * 0.04)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    topHUD
                        .padding(.top, geo.safeAreaInsets.top + 12)
                        .padding(.horizontal, 16)
                    Spacer()
                    actionBar
                        .padding(.bottom, geo.safeAreaInsets.bottom + 16)
                        .padding(.horizontal, 20)
                }
            }
            // INJ-05: aggiorna la scena con le dimensioni reali del frame iso
            .onAppear {
                let isoSize = CGSize(width: geo.size.width,
                                    height: geo.size.height * 0.58)
                scene = {
                    let s = GardenScene(size: isoSize)
                    s.scaleMode = .resizeFill
                    s.mood = appState.mood
                    return s
                }()
            }
        }
        // BUG-01/06: il mood viene derivato da GameStore, non impostato manualmente
        .onChange(of: store.pet.needs.hunger)    { _, _ in syncMood() }
        .onChange(of: store.pet.needs.happiness) { _, _ in syncMood() }
        .onChange(of: store.pet.needs.calm)      { _, _ in syncMood() }
        .onChange(of: store.pet.needs.energy)    { _, _ in syncMood() }
        .onChange(of: appState.mood) { _, mood in
            scene.mood = mood
            SoundscapeManager.shared.transition(to: mood)
        }
        // BUG-02: shake quando il cibo è esaurito
        .onChange(of: store.feedBlocked) { _, blocked in
            if blocked { triggerShake() }
        }
        // BUG-04: collegare il sheet del diario
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

    // MARK: - Mood Sync (BUG-01 / BUG-06)

    private func syncMood() {
        let derived = store.derivedMood()
        if appState.mood != derived {
            appState.mood = derived
        }
    }

    // MARK: - Background

    private var kawaiiBg: some View {
        LinearGradient(
            colors: [
                Color(red: 1.00, green: 0.91, blue: 0.94),
                Color(red: 0.92, green: 0.85, blue: 1.00)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - HUD

    private var topHUD: some View {
        VStack(spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    // INJ-01: nome sanitizzato
                    Text(store.pet.sanitizedName)
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundStyle(Color(red: 0.55, green: 0.25, blue: 0.60))
                    Text("Mood: \(appState.mood.rawValue)")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(moodEmoji(appState.mood))
                    .font(.system(size: 32))
            }

            VStack(spacing: 6) {
                KawaiiStatBar(icon: "heart.fill",      color: Color(red: 1.0, green: 0.45, blue: 0.60), value: store.pet.needs.happiness, label: "Felicità")
                KawaiiStatBar(icon: "leaf.fill",       color: Color(red: 0.35, green: 0.78, blue: 0.50), value: store.pet.needs.hunger,    label: "Fame")
                KawaiiStatBar(icon: "moon.stars.fill", color: Color(red: 0.55, green: 0.45, blue: 0.90), value: store.pet.needs.calm,      label: "Calma")
                KawaiiStatBar(icon: "bolt.fill",       color: Color(red: 1.0, green: 0.65, blue: 0.20),  value: store.pet.needs.energy,    label: "Energia")
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.white.opacity(0.72))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .strokeBorder(Color(red: 1.0, green: 0.75, blue: 0.85), lineWidth: 1.5)
                )
        )
        .shadow(color: Color(red: 1.0, green: 0.60, blue: 0.75).opacity(0.18), radius: 12, x: 0, y: 6)
    }

    // MARK: - Action Bar

    private var actionBar: some View {
        HStack(spacing: 12) {
            KawaiiActionButton(
                icon: "sparkles", label: "Medita",
                color: Color(red: 0.72, green: 0.50, blue: 0.98),
                haptic: .medium
            ) {
                store.meditate()   // BUG-01: mood derivato automaticamente
            }

            // BUG-02: shake + badge "0" quando cibo esaurito
            KawaiiActionButton(
                icon: "carrot.fill", label: "Cibo",
                color: Color(red: 1.00, green: 0.55, blue: 0.45),
                badge: store.pet.food == 0 ? "!" : nil,
                haptic: store.pet.food > 0 ? .light : .none
            ) {
                store.feed()
            }
            .offset(x: feedShake)

            KawaiiActionButton(
                icon: "gamecontroller.fill", label: "Gioca",
                color: Color(red: 0.30, green: 0.72, blue: 0.90),
                haptic: .light
            ) {
                store.play()
            }

            KawaiiActionButton(
                icon: "book.closed.fill", label: "Diario",
                color: Color(red: 1.00, green: 0.70, blue: 0.30),
                haptic: .light
            ) {
                showJournal.toggle()   // BUG-04: ora collegato al sheet
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.white.opacity(0.75))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .strokeBorder(Color(red: 1.0, green: 0.75, blue: 0.85), lineWidth: 1.5)
                )
        )
        .shadow(color: .pink.opacity(0.15), radius: 14, x: 0, y: 6)
    }

    // MARK: - Shake Animation (BUG-02)

    private func triggerShake() {
        withAnimation(.spring(response: 0.1, dampingFraction: 0.3).repeatCount(4, autoreverses: true)) {
            feedShake = 6
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            feedShake = 0
        }
    }

    // MARK: - Helpers

    private func moodEmoji(_ mood: PetMood) -> String {
        switch mood {
        case .calm:     return "🌸"
        case .happy:    return "✨"
        case .anxious:  return "🌧️"
        case .sleepy:   return "🌙"
        case .sick:     return "🤒"
        case .evolving: return "🦋"
        }
    }
}

// MARK: - KawaiiStatBar

private struct KawaiiStatBar: View {
    let icon: String
    let color: Color
    let value: Float
    let label: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(color)
                .frame(width: 18)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(color.opacity(0.15))
                        .frame(height: 10)
                    RoundedRectangle(cornerRadius: 8)
                        .fill(LinearGradient(colors: [color.opacity(0.8), color],
                                             startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * CGFloat(max(0, min(1, value))), height: 10)
                        .animation(.easeInOut(duration: 0.4), value: value)
                }
            }
            .frame(height: 10)

            Text(label)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
                .frame(width: 52, alignment: .trailing)
        }
    }
}

// MARK: - KawaiiActionButton

enum HapticStyle { case none, light, medium }

private struct KawaiiActionButton: View {
    let icon: String
    let label: String
    let color: Color
    var badge: String? = nil
    var haptic: HapticStyle = .light
    let action: () -> Void

    var body: some View {
        Button {
            // BUG-05: feedback aptico
            switch haptic {
            case .light:  UIImpactFeedbackGenerator(style: .light).impactOccurred()
            case .medium: UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            case .none:   UINotificationFeedbackGenerator().notificationOccurred(.warning)
            }
            action()
        } label: {
            VStack(spacing: 5) {
                ZStack(alignment: .topTrailing) {
                    Circle()
                        .fill(color.opacity(0.18))
                        .frame(width: 48, height: 48)
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(color)

                    // BUG-02: badge "!" quando cibo esaurito
                    if let badge {
                        Text(badge)
                            .font(.system(size: 10, weight: .black))
                            .foregroundStyle(.white)
                            .padding(3)
                            .background(Color.red, in: Circle())
                            .offset(x: 4, y: -4)
                    }
                }
                Text(label)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(color)
            }
        }
        .frame(maxWidth: .infinity)
        .buttonStyle(.plain)
    }
}

// MARK: - KawaiiDecorations

private struct KawaiiDecorations: View {
    private let decorations: [(symbol: String, x: CGFloat, y: CGFloat, size: CGFloat, opacity: Double, rotation: Double)] = [
        ("star.fill",   0.08, 0.12, 14, 0.25,  15),
        ("heart.fill",  0.88, 0.18, 12, 0.20, -10),
        ("sparkle",     0.15, 0.35, 10, 0.18,   0),
        ("star.fill",   0.92, 0.42, 10, 0.15,  30),
        ("heart.fill",  0.05, 0.60, 11, 0.18,   5),
        ("sparkle",     0.90, 0.65, 13, 0.20, -20),
        ("star.fill",   0.20, 0.80,  9, 0.15,  45),
        ("heart.fill",  0.78, 0.85, 10, 0.18,  -5),
        ("circle.fill", 0.50, 0.08,  8, 0.12,   0),
        ("circle.fill", 0.35, 0.92,  7, 0.10,   0),
    ]

    var body: some View {
        GeometryReader { geo in
            ForEach(Array(decorations.enumerated()), id: \.offset) { _, d in
                Image(systemName: d.symbol)
                    .font(.system(size: d.size))
                    .foregroundStyle(LinearGradient(colors: [.pink, .purple], startPoint: .top, endPoint: .bottom))
                    .opacity(d.opacity)
                    .rotationEffect(.degrees(d.rotation))
                    .position(x: geo.size.width * d.x, y: geo.size.height * d.y)
            }
        }
    }
}
