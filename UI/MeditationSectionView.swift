import SwiftUI

// ──────────────────────────────────────────────────────────────────────────────
// MARK: - MeditationSectionView
// Tempio della meditazione: respiro guidato, meditazione libera e cronologia.
// ──────────────────────────────────────────────────────────────────────────────

struct MeditationSectionView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var store: GameStore
    @Environment(\.dismiss) private var dismiss

    // MARK: – State

    enum MeditationMode: String, CaseIterable {
        case breathing = "Respiro"
        case guided    = "Guidata"
        case free      = "Libera"

        var icon: String {
            switch self {
            case .breathing: "wind"
            case .guided:    "sparkles"
            case .free:      "timer"
            }
        }

        var description: String {
            switch self {
            case .breathing: "Inspira ed espira con il cerchio"
            case .guided:    "4 minuti di serenità guidata"
            case .free:      "Medita al tuo ritmo"
            }
        }
    }

    @State private var mode: MeditationMode = .breathing
    @State private var running = false
    @State private var seconds: Int = 0
    @State private var timer: Timer?
    @State private var breathPhase: String = "Inspira"
    @State private var breathScale: CGFloat = 0.6
    @State private var showComplete = false
    @State private var showHistory = false

    // Guided duration (4 min)
    private let guidedDuration = 240

    var body: some View {
        ZStack {
            // Sfondo tempio
            LinearGradient(
                colors: [Color(red: 0.26, green: 0.20, blue: 0.42),
                         Color(red: 0.42, green: 0.28, blue: 0.60),
                         Color(red: 0.22, green: 0.16, blue: 0.36)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ).ignoresSafeArea()

            // Stelle decorative
            StarsOverlay()

            VStack(spacing: 16) {
                sectionHeader(title: "🧘 Meditazione", tint: .purple)

                // Mode picker
                modePicker

                Spacer()

                // Centro visuale
                meditationCenter

                Spacer()

                // Timer
                timerDisplay

                // Controlli
                controlButtons

                Spacer(minLength: 20)
            }
        }
        .sheet(isPresented: $showComplete) {
            completionSheet
        }
        .sheet(isPresented: $showHistory) {
            historySheet
        }
    }

    // MARK: – Mode Picker

    private var modePicker: some View {
        HStack(spacing: 8) {
            ForEach(MeditationMode.allCases, id: \.rawValue) { m in
                Button {
                    guard !running else { return }
                    mode = m
                    seconds = 0
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: m.icon)
                            .font(.title3)
                        Text(m.rawValue)
                            .font(.caption.weight(.semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .foregroundStyle(mode == m ? .white : .white.opacity(0.6))
                    .background(
                        mode == m ? Color.white.opacity(0.2) : Color.clear,
                        in: RoundedRectangle(cornerRadius: 12)
                    )
                }
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: – Meditation Center Visual

    private var meditationCenter: some View {
        ZStack {
            // Cerchio respiro animato
            Circle()
                .fill(
                    RadialGradient(
                        colors: [breathColor.opacity(0.7), breathColor.opacity(0.15)],
                        center: .center,
                        startRadius: 10,
                        endRadius: 140
                    )
                )
                .frame(width: 280, height: 280)
                .scaleEffect(breathScale)
                .animation(.easeInOut(duration: breathPhaseDuration(for: breathPhase)), value: breathScale)

            // Anello esterno
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: 2)
                .frame(width: 280, height: 280)

            // Testo fase
            VStack(spacing: 8) {
                if running {
                    Text(breathPhase)
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.5), value: breathPhase)
                } else {
                    Image(systemName: mode.icon)
                        .font(.system(size: 40))
                        .foregroundStyle(.white.opacity(0.7))
                }

                Text(mode.description)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .frame(width: 160)
            }
        }
    }

    // MARK: – Timer Display

    private var timerDisplay: some View {
        VStack(spacing: 4) {
            Text(formatTimeString(seconds))
                .font(.system(size: 52, weight: .ultraLight, design: .rounded))
                .foregroundStyle(.white)
                .contentTransition(.numericText())

            if mode == .guided {
                // Progress bar
                GeometryReader { geo in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.white.opacity(0.15))
                        .overlay(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.purple.opacity(0.8))
                                .frame(width: geo.size.width * progress)
                        }
                }
                .frame(height: 4)
                .padding(.horizontal, 40)
            }
        }
    }

    // MARK: – Controls

    private var controlButtons: some View {
        HStack(spacing: 16) {
            // History
            Button {
                showHistory = true
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.title3)
                    Text("Storico")
                        .font(.caption2)
                }
                .foregroundStyle(.white.opacity(0.7))
            }

            // Main action
            SectionActionButton(
                icon: running ? "pause.fill" : "play.fill",
                label: running ? "Pausa" : "Inizia",
                tint: .purple
            ) {
                toggleMeditation()
            }

            // Stop / Complete
            if running || seconds > 0 {
                SectionActionButton(
                    icon: "stop.fill",
                    label: "Termina",
                    tint: .indigo
                ) {
                    completeMeditation()
                }
            } else {
                // Spacer to balance
                Color.clear.frame(width: 70)
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: – Completion Sheet

    private var completionSheet: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("🧘").font(.system(size: 60))
            Text("Sessione Completata")
                .font(.system(.title2, design: .rounded))
                .fontWeight(.bold)
            Text("Durata: \(formatTimeString(seconds))")
                .font(.title3)
                .foregroundStyle(.secondary)

            VStack(spacing: 8) {
                rewardRow(icon: "🫧", label: "Calma", value: "+\(Int(calmBonus * 100))%", tint: .purple)
                rewardRow(icon: "☀️", label: "Felicità", value: "+15%", tint: .purple)
                rewardRow(icon: "⚡️", label: "Energia", value: "+10%", tint: .purple)
            }
            .padding()
            .background(.purple.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))

            Button("Continua") {
                showComplete = false
                seconds = 0
            }
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.horizontal, 40)
            .padding(.vertical, 14)
            .background(.purple, in: Capsule())

            Spacer()
        }
        .padding()
        .presentationDetents([.medium])
    }

    // MARK: – History Sheet

    private var historySheet: some View {
        NavigationStack {
            List {
                let sessions = store.recentSessions(limit: 20)
                if sessions.isEmpty {
                    Text("Nessuna sessione registrata")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(sessions, id: \.date) { session in
                        HStack {
                            Image(systemName: sessionIcon(session.type))
                                .foregroundStyle(.purple)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(sessionLabel(session.type))
                                    .font(.subheadline.weight(.medium))
                                Text(session.date, style: .date)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(formatTimeString(session.durationSeconds))
                                .font(.subheadline.monospacedDigit())
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Storico Meditazione")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium, .large])
    }

    // MARK: – Logic

    private func toggleMeditation() {
        running.toggle()
        if running {
            appState.mood = .calm
            startBreathCycle()
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                seconds += 1
                if mode == .guided && seconds >= guidedDuration {
                    completeMeditation()
                }
            }
        } else {
            timer?.invalidate()
        }
    }

    private func completeMeditation() {
        timer?.invalidate()
        timer = nil
        running = false
        if seconds > 5 {
            store.completeMeditation(durationSeconds: seconds, type: mode.rawValue)
            SoundscapeManager.shared.playBell()
            showComplete = true
        }
    }

    private func startBreathCycle() {
        METIME.startBreathCycle(
            isRunning: { [self] in running },
            onPhase: { [self] name, scale in
                breathPhase = name
                breathScale = scale
            }
        )
    }

    // MARK: – Helpers

    private var progress: CGFloat {
        guard guidedDuration > 0 else { return 0 }
        return min(CGFloat(seconds) / CGFloat(guidedDuration), 1.0)
    }

    private var calmBonus: Float {
        min(Float(seconds) / 240.0, 1.0) * 0.35
    }

    private var breathColor: Color {
        switch breathPhase {
        case "Inspira": .cyan
        case "Tieni":   .blue
        case "Espira":  .purple
        default:        .indigo
        }
    }



    private func sessionIcon(_ type: String) -> String {
        switch type {
        case "Respiro":     "wind"
        case "Guidata":     "sparkles"
        case "care_ritual": "heart.fill"
        default:            "timer"
        }
    }

    private func sessionLabel(_ type: String) -> String {
        switch type {
        case "Respiro":     "Respiro Guidato"
        case "Guidata":     "Meditazione Guidata"
        case "care_ritual": "Rituale di Cura"
        default:            "Meditazione Libera"
        }
    }
}

// MARK: – Stars Overlay

private struct StarsOverlay: View {
    @State private var opacity: Double = 0.3

    var body: some View {
        Canvas { context, size in
            let starCount = 30
            for i in 0..<starCount {
                let seed = Double(i * 7919) // Deterministic pseudo-random
                let x = (seed.truncatingRemainder(dividingBy: size.width * 0.97)) + 4
                let y = (seed * 1.3).truncatingRemainder(dividingBy: size.height * 0.6) + size.height * 0.05
                let starSize = CGFloat((seed * 0.7).truncatingRemainder(dividingBy: 2.5)) + 1

                context.fill(
                    Path(ellipseIn: CGRect(x: x, y: y, width: starSize, height: starSize)),
                    with: .color(.white.opacity(0.6))
                )
            }
        }
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                opacity = 0.8
            }
        }
        .allowsHitTesting(false)
    }
}
