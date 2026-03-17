import SwiftUI
import SpriteKit

// ──────────────────────────────────────────────────────────────────────────────
// MARK: - GardenSectionView
// Il giardino esistente con SpriteKit (GardenScene) + azioni rapide.
// ──────────────────────────────────────────────────────────────────────────────

struct GardenSectionView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var store: GameStore
    @Environment(\.dismiss) private var dismiss

    @State private var scene: GardenScene = {
        let s = GardenScene(size: UIScreen.main.bounds.size)
        s.scaleMode = .resizeFill
        return s
    }()

    var body: some View {
        ZStack(alignment: .bottom) {
            SpriteView(scene: scene, options: [.allowsTransparency])
                .ignoresSafeArea()
                .onAppear { scene.mood = appState.mood }
                .onChange(of: appState.mood) { _, m in scene.mood = m }

            VStack(spacing: 0) {
                sectionHeader(title: "🌿 Giardino", tint: .green)

                HStack(spacing: 12) {
                    SectionActionButton(icon: "leaf.fill",          label: "Annaffia", tint: .green)  { store.feed() }
                    SectionActionButton(icon: "hare.fill",          label: "Gioca",    tint: .blue)   { store.play() }
                }
                .padding(.bottom, 34)
                .padding(.horizontal, 20)
            }
        }
    }
}

// ──────────────────────────────────────────────────────────────────────────────
// MARK: - HouseSectionView
// Interno casa: cura del pet, rituale quotidiano, sezione Diario.
// ──────────────────────────────────────────────────────────────────────────────

struct HouseSectionView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var store: GameStore
    @Environment(\.dismiss) private var dismiss

    @State private var breathPhase = ""
    @State private var breathTimer: Timer?
    @State private var breathing = false

    var body: some View {
        ZStack {
            // Sfondo caldo
            LinearGradient(
                colors: [Color(red: 0.99, green: 0.93, blue: 0.86),
                         Color(red: 0.93, green: 0.80, blue: 0.68)],
                startPoint: .top, endPoint: .bottom
            ).ignoresSafeArea()

            VStack(spacing: 20) {
                sectionHeader(title: "🏡 Casa", tint: .orange)

                // Letto con ZZZ animate
                BedPreview()

                // Azioni cura
                HStack(spacing: 12) {
                    SectionActionButton(icon: "fork.knife",    label: "Nutri",   tint: .orange)  { store.feed() }
                    SectionActionButton(icon: "sparkles",      label: "Medita",  tint: .indigo)  {
                        appState.mood = .happy; store.meditate()
                    }
                    SectionActionButton(icon: "moon.zzz.fill", label: "Riposo",  tint: .purple)  {
                        appState.mood = .sleepy
                    }
                }
                .padding(.horizontal, 20)

                // Respiro guidato mini
                BreathWidget(phase: $breathPhase, active: $breathing) {
                    breathPhase = "Inspira"
                    breathing = true
                    var cycleStep = 0
                    let phases = ["Inspira", "Tieni", "Espira", "Pausa"]
                    let durations: [Double] = [4, 4, 4, 2]
                    breathTimer?.invalidate()
                    breathTimer = Timer.scheduledTimer(withTimeInterval: durations[0], repeats: true) { [weak self] t in
                        guard let self else { t.invalidate(); return }
                        cycleStep = (cycleStep + 1) % 4
                        breathPhase = phases[cycleStep]
                    }
                } onStop: {
                    breathTimer?.invalidate()
                    breathTimer = nil
                    breathing = false
                }

                Spacer()
            }
        }
    }
}

// ──────────────────────────────────────────────────────────────────────────────
// MARK: - SeaSectionView
// Meditazione sulla riva del mare.
// ──────────────────────────────────────────────────────────────────────────────

struct SeaSectionView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var store: GameStore
    @Environment(\.dismiss) private var dismiss

    @State private var waveOffset: CGFloat = 0
    @State private var seconds: Int = 0
    @State private var running = false
    @State private var timer: Timer?

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.64, green: 0.84, blue: 0.98),
                         Color(red: 0.44, green: 0.66, blue: 0.94)],
                startPoint: .top, endPoint: .bottom
            ).ignoresSafeArea()

            VStack(spacing: 24) {
                sectionHeader(title: "🌊 Riva del Mare", tint: Color(red: 0.25, green: 0.56, blue: 0.84))

                Spacer()

                // Onde animate
                WaveShape(offset: waveOffset)
                    .fill(Color.white.opacity(0.35))
                    .frame(height: 80)
                    .onAppear {
                        withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                            waveOffset = 1
                        }
                    }

                // Timer meditazione
                Text(timeString(seconds))
                    .font(.system(size: 56, weight: .ultraLight, design: .rounded))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())

                HStack(spacing: 16) {
                    SectionActionButton(
                        icon: running ? "pause.fill" : "play.fill",
                        label: running ? "Pausa" : "Inizia",
                        tint: .white
                    ) {
                        running.toggle()
                        if running {
                            appState.mood = .calm
                            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                                guard let self else { return }
                                seconds += 1
                            }
                        } else {
                            timer?.invalidate()
                        }
                    }

                    SectionActionButton(icon: "arrow.counterclockwise", label: "Reset", tint: .white.opacity(0.8)) {
                        timer?.invalidate(); running = false; seconds = 0
                    }
                }

                Text("Respira con il ritmo delle onde 〜")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.85))

                Spacer()
            }
            .padding(.horizontal, 20)
        }
    }

    private func timeString(_ s: Int) -> String {
        String(format: "%02d:%02d", s / 60, s % 60)
    }
}

// ──────────────────────────────────────────────────────────────────────────────
// MARK: - ShopSectionView
// Negozio: acquista cibo e oggetti per il pet.
// ──────────────────────────────────────────────────────────────────────────────

struct ShopSectionView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var store: GameStore
    @Environment(\.dismiss) private var dismiss

    private let items: [(String, String, String)] = [
        ("🍎", "Mela Rossa",    "+Fame"),
        ("🍩", "Ciambella",     "+Felicità"),
        ("🌿", "Infuso Verde",  "+Calma"),
        ("⚡️", "Energy Drink", "+Energia"),
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.99, green: 0.97, blue: 0.88),
                         Color(red: 0.96, green: 0.88, blue: 0.68)],
                startPoint: .top, endPoint: .bottom
            ).ignoresSafeArea()

            VStack(spacing: 20) {
                sectionHeader(title: "🛒 Negozio", tint: Color(red: 0.80, green: 0.45, blue: 0.20))

                Text("Cibo disponibile: \(store.pet.food)")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                    ForEach(items, id: \.1) { emoji, name, effect in
                        ShopItemCard(emoji: emoji, name: name, effect: effect) {
                            store.feed()
                        }
                    }
                }
                .padding(.horizontal, 16)

                Spacer()
            }
        }
    }
}

// ──────────────────────────────────────────────────────────────────────────────
// MARK: - Componenti condivisi
// ──────────────────────────────────────────────────────────────────────────────

// Intestazione sezione con tasto "←" per tornare alla mappa
@ViewBuilder
func sectionHeader(title: String, tint: Color) -> some View {
    HStack {
        Spacer()
        Text(title)
            .font(.system(.title3, design: .rounded))
            .fontWeight(.bold)
        Spacer()
    }
    .overlay(alignment: .leading) {
        DismissButton(tint: tint)
            .padding(.leading, 16)
    }
    .padding(.vertical, 12)
    .background(.ultraThinMaterial)
}

struct DismissButton: View {
    @Environment(\.dismiss) private var dismiss
    let tint: Color

    var body: some View {
        Button {
            dismiss()
        } label: {
            Label("Mappa", systemImage: "map.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(tint)
        }
    }
}

struct SectionActionButton: View {
    let icon: String
    let label: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title2)
                Text(label)
                    .font(.caption.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .foregroundStyle(.white)
            .background(tint, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: tint.opacity(0.3), radius: 8, y: 4)
        }
    }
}

// ── Anteprima letto (SwiftUI, non SpriteKit) ───────────────────────────────
private struct BedPreview: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(red: 0.75, green: 0.56, blue: 0.36))
                .frame(width: 130, height: 70)
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(red: 0.70, green: 0.86, blue: 0.98))
                .frame(width: 120, height: 38)
                .offset(y: 8)
            Ellipse()
                .fill(Color(red: 0.99, green: 0.90, blue: 0.86))
                .frame(width: 50, height: 22)
                .offset(y: -12)
            Text("🌙")
                .font(.system(size: 28))
                .offset(x: 50, y: -40)
        }
        .frame(height: 110)
    }
}

// ── Widget respiro ──────────────────────────────────────────────────────────
private struct BreathWidget: View {
    @Binding var phase: String
    @Binding var active: Bool
    let onStart: () -> Void
    let onStop: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            if active {
                Text(phase)
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundStyle(.orange)
                    .transition(.scale.combined(with: .opacity))
                    .animation(.spring(duration: 0.4), value: phase)
            }
            Button(active ? "Ferma respiro" : "Avvia respiro guidato") {
                active ? onStop() : onStart()
            }
            .font(.subheadline.weight(.medium))
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(.orange.opacity(0.15), in: Capsule())
            .foregroundStyle(.orange)
        }
        .padding(14)
        .background(.white.opacity(0.7), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.horizontal, 20)
    }
}

// ── Forma onda ──────────────────────────────────────────────────────────────
private struct WaveShape: Shape {
    var offset: CGFloat
    var animatableData: CGFloat {
        get { offset }
        set { offset = newValue }
    }
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let waveH: CGFloat = 20
        let wl: CGFloat = rect.width / 2
        path.move(to: CGPoint(x: 0, y: rect.midY))
        for x in stride(from: CGFloat(0), through: rect.width, by: 1) {
            let y = rect.midY + waveH * sin((x / wl + offset) * .pi * 2)
            path.addLine(to: CGPoint(x: x, y: y))
        }
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: 0, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// ── Scheda prodotto negozio ─────────────────────────────────────────────────
private struct ShopItemCard: View {
    let emoji: String
    let name: String
    let effect: String
    let onBuy: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            Text(emoji).font(.system(size: 36))
            Text(name).font(.subheadline.weight(.semibold))
            Text(effect).font(.caption).foregroundStyle(.secondary)
            Button("Acquista") { onBuy() }
                .font(.caption.weight(.bold))
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(.orange, in: Capsule())
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(14)
        .background(.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
