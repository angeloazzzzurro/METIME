import SwiftUI
import SpriteKit

// MARK: - MainPetView

struct MainPetView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var store: GameStore

    @State private var showJournal = false

    // Scena SpriteKit creata una sola volta
    @State private var scene: GardenScene = {
        let s = GardenScene(size: UIScreen.main.bounds.size)
        s.scaleMode = .resizeFill
        return s
    }()

    var body: some View {
        ZStack(alignment: .bottom) {
            // ── Sfondo kawaii ──────────────────────────────────────────
            kawaiiBg.ignoresSafeArea()

            // ── Decorazioni di sfondo ──────────────────────────────────
            KawaiiDecorations()
                .ignoresSafeArea()

            // ── Scena SpriteKit (pet + particelle) ─────────────────────
            SceneView(scene: scene, options: [.allowsTransparency])
                .ignoresSafeArea()

            // ── Layout principale ──────────────────────────────────────
            VStack(spacing: 0) {
                topHUD
                    .padding(.top, 56)
                    .padding(.horizontal, 16)

                Spacer()

                actionBar
                    .padding(.bottom, 36)
                    .padding(.horizontal, 20)
            }
        }
        .onAppear { scene.mood = appState.mood }
        .onChange(of: appState.mood) { _, mood in
            scene.mood = mood
            SoundscapeManager.shared.transition(to: mood)
        }
    }

    // MARK: - Background

    private var kawaiiBg: some View {
        LinearGradient(
            colors: [
                Color(red: 1.00, green: 0.91, blue: 0.94),  // rosa cipria
                Color(red: 0.92, green: 0.85, blue: 1.00)   // lilla chiaro
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - HUD

    private var topHUD: some View {
        VStack(spacing: 10) {
            // Nome + mood
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(store.pet.name)
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundStyle(Color(red: 0.55, green: 0.25, blue: 0.60))
                    Text("Mood: \(appState.mood.rawValue)")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                // Badge mood
                Text(moodEmoji(appState.mood))
                    .font(.system(size: 32))
            }

            // Barre di stato con icone
            VStack(spacing: 6) {
                KawaiiStatBar(icon: "heart.fill",    color: Color(red: 1.0, green: 0.45, blue: 0.60), value: store.pet.needs.happiness, label: "Felicità")
                KawaiiStatBar(icon: "leaf.fill",     color: Color(red: 0.35, green: 0.78, blue: 0.50), value: store.pet.needs.hunger,    label: "Fame")
                KawaiiStatBar(icon: "moon.stars.fill", color: Color(red: 0.55, green: 0.45, blue: 0.90), value: store.pet.needs.calm,   label: "Calma")
                KawaiiStatBar(icon: "bolt.fill",     color: Color(red: 1.0, green: 0.65, blue: 0.20),  value: store.pet.needs.energy,   label: "Energia")
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
            KawaiiActionButton(icon: "sparkles",          label: "Medita", color: Color(red: 0.72, green: 0.50, blue: 0.98)) {
                appState.mood = .happy
                store.meditate()
            }
            KawaiiActionButton(icon: "carrot.fill",       label: "Cibo",   color: Color(red: 1.00, green: 0.55, blue: 0.45)) {
                store.feed()
            }
            KawaiiActionButton(icon: "gamecontroller.fill", label: "Gioca", color: Color(red: 0.30, green: 0.72, blue: 0.90)) {
                store.play()
            }
            KawaiiActionButton(icon: "book.closed.fill",  label: "Diario", color: Color(red: 1.00, green: 0.70, blue: 0.30)) {
                showJournal.toggle()
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
                        .fill(
                            LinearGradient(colors: [color.opacity(0.8), color],
                                           startPoint: .leading, endPoint: .trailing)
                        )
                        .frame(width: geo.size.width * CGFloat(value), height: 10)
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

private struct KawaiiActionButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.18))
                        .frame(width: 48, height: 48)
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(color)
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

/// Piccoli elementi decorativi fissi sullo sfondo (stelle, cuori, fiori).
private struct KawaiiDecorations: View {
    private let decorations: [(symbol: String, x: CGFloat, y: CGFloat, size: CGFloat, opacity: Double, rotation: Double)] = [
        ("star.fill",        0.08, 0.12, 14, 0.25, 15),
        ("heart.fill",       0.88, 0.18, 12, 0.20, -10),
        ("sparkle",          0.15, 0.35, 10, 0.18, 0),
        ("star.fill",        0.92, 0.42, 10, 0.15, 30),
        ("heart.fill",       0.05, 0.60, 11, 0.18, 5),
        ("sparkle",          0.90, 0.65, 13, 0.20, -20),
        ("star.fill",        0.20, 0.80, 9,  0.15, 45),
        ("heart.fill",       0.78, 0.85, 10, 0.18, -5),
        ("circle.fill",      0.50, 0.08, 8,  0.12, 0),
        ("circle.fill",      0.35, 0.92, 7,  0.10, 0),
    ]

    var body: some View {
        GeometryReader { geo in
            ForEach(Array(decorations.enumerated()), id: \.offset) { _, d in
                Image(systemName: d.symbol)
                    .font(.system(size: d.size))
                    .foregroundStyle(
                        LinearGradient(colors: [.pink, .purple], startPoint: .top, endPoint: .bottom)
                    )
                    .opacity(d.opacity)
                    .rotationEffect(.degrees(d.rotation))
                    .position(x: geo.size.width * d.x, y: geo.size.height * d.y)
            }
        }
    }
}
