import SwiftUI

// ──────────────────────────────────────────────────────────────────────────────
// MARK: - CareRitualSectionView
// Rituale di cura in 3 fasi: Grounding → Breathing → Gratitude.
// Completa il rituale per ottenere ricompense per il pet.
// ──────────────────────────────────────────────────────────────────────────────

struct CareRitualSectionView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var store: GameStore
    @Environment(\.dismiss) private var dismiss

    // MARK: – State

    @State private var currentStep: CareRitualStep = .grounding
    @State private var stepCompleted: Set<CareRitualStep> = []
    @State private var running = false
    @State private var seconds: Int = 0
    @State private var timer: Timer?
    @State private var gratitudeText = ""
    @State private var showReward = false
    @State private var logEntries: [(String, String)] = [("Pronto", "In attesa di avvio.")]

    // Breath state
    @State private var breathPhase = "Inspira"
    @State private var breathScale: CGFloat = 0.6

    var body: some View {
        ZStack {
            // Sfondo caldo rosa-arancio
            LinearGradient(
                colors: [Color(red: 0.99, green: 0.90, blue: 0.88),
                         Color(red: 0.96, green: 0.82, blue: 0.78),
                         Color(red: 0.98, green: 0.88, blue: 0.84)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ).ignoresSafeArea()

            // Cuoricini decorativi
            FloatingHeartsOverlay()

            VStack(spacing: 0) {
                sectionHeader(title: "💗 Rituale di Cura", tint: Color(red: 0.80, green: 0.40, blue: 0.50))

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 18) {
                        // Progress steps
                        stepIndicator

                        // Contenuto fase attuale
                        currentStepContent
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))

                        // Timer sessione
                        sessionTimer

                        // Session log
                        sessionLog

                        Spacer(minLength: 30)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                }
            }
        }
        .sheet(isPresented: $showReward) {
            rewardSheet
        }
    }

    // MARK: – Step Indicator

    private var stepIndicator: some View {
        HStack(spacing: 0) {
            ForEach(CareRitualStep.allCases, id: \.rawValue) { step in
                HStack(spacing: 6) {
                    ZStack {
                        Circle()
                            .fill(stepColor(step))
                            .frame(width: 36, height: 36)
                        if stepCompleted.contains(step) {
                            Image(systemName: "checkmark")
                                .font(.caption.bold())
                                .foregroundStyle(.white)
                        } else {
                            Image(systemName: step.icon)
                                .font(.caption)
                                .foregroundStyle(.white)
                        }
                    }
                    Text(step.title)
                        .font(.caption.weight(currentStep == step ? .bold : .regular))
                        .foregroundStyle(currentStep == step ? .primary : .secondary)
                }
                if step != .gratitude {
                    Spacer()
                    Rectangle()
                        .fill(stepCompleted.contains(step) ? Color.green : Color.gray.opacity(0.3))
                        .frame(height: 2)
                    Spacer()
                }
            }
        }
        .padding(.vertical, 8)
    }

    // MARK: – Step Content

    @ViewBuilder
    private var currentStepContent: some View {
        switch currentStep {
        case .grounding:
            groundingView
        case .breathing:
            breathingView
        case .gratitude:
            gratitudeView
        }
    }

    // ── Grounding ───────────────────────────────────────────────────────
    private var groundingView: some View {
        VStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.white.opacity(0.7))
                .frame(height: 260)
                .overlay {
                    VStack(spacing: 14) {
                        Text("🌿").font(.system(size: 50))

                        Text("Radicamento")
                            .font(.system(.title3, design: .rounded))
                            .fontWeight(.bold)

                        Text(currentStep.instruction)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)

                        // Guida visiva - piedi a terra
                        HStack(spacing: 30) {
                            groundingCircle(delay: 0)
                            groundingCircle(delay: 0.5)
                            groundingCircle(delay: 1.0)
                        }
                    }
                }

            Button {
                completeStep(.grounding)
            } label: {
                Label("Ho rilassato le spalle →", systemImage: "checkmark.circle.fill")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(red: 0.45, green: 0.72, blue: 0.45), in: RoundedRectangle(cornerRadius: 14))
            }
        }
    }

    private func groundingCircle(delay: Double) -> some View {
        Circle()
            .fill(Color.green.opacity(0.3))
            .frame(width: 40, height: 40)
            .overlay {
                Circle()
                    .stroke(Color.green.opacity(0.6), lineWidth: 2)
            }
            .scaleEffect(running ? 1.2 : 0.8)
            .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true).delay(delay), value: running)
            .onAppear { running = true }
    }

    // ── Breathing ───────────────────────────────────────────────────────
    private var breathingView: some View {
        VStack(spacing: 16) {
            ZStack {
                // Cerchio respiro
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.orange.opacity(0.6), Color.pink.opacity(0.2)],
                            center: .center,
                            startRadius: 10,
                            endRadius: 130
                        )
                    )
                    .frame(width: 260, height: 260)
                    .scaleEffect(breathScale)
                    .animation(.easeInOut(duration: breathPhaseDuration(for: breathPhase)), value: breathScale)

                Circle()
                    .stroke(Color.orange.opacity(0.3), lineWidth: 2)
                    .frame(width: 260, height: 260)

                VStack(spacing: 6) {
                    Text(breathPhase)
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(red: 0.60, green: 0.30, blue: 0.20))
                        .animation(.easeInOut(duration: 0.4), value: breathPhase)

                    Text(formatTimeString(seconds))
                        .font(.system(size: 36, weight: .ultraLight, design: .rounded))
                        .foregroundStyle(Color(red: 0.60, green: 0.30, blue: 0.20).opacity(0.7))
                }
            }

            Text("Inspira 4 sec · Espira 6 sec")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Button {
                    if !running {
                        startBreathing()
                    } else {
                        stopBreathing()
                    }
                } label: {
                    Label(running ? "Pausa" : "Avvia Respiro", systemImage: running ? "pause.fill" : "play.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.orange, in: Capsule())
                }

                if seconds >= 30 {
                    Button {
                        stopBreathing()
                        completeStep(.breathing)
                    } label: {
                        Label("Prosegui →", systemImage: "arrow.right.circle.fill")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.green, in: Capsule())
                    }
                }
            }
        }
    }

    // ── Gratitude ───────────────────────────────────────────────────────
    private var gratitudeView: some View {
        VStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.white.opacity(0.7))
                .overlay {
                    VStack(spacing: 14) {
                        Text("❤️").font(.system(size: 50))

                        Text("Gratitudine")
                            .font(.system(.title3, design: .rounded))
                            .fontWeight(.bold)

                        Text(currentStep.instruction)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)

                        TextField("Scrivi qui...", text: $gratitudeText, axis: .vertical)
                            .textFieldStyle(.plain)
                            .padding(12)
                            .background(Color.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 12))
                            .lineLimit(3...6)
                            .padding(.horizontal, 16)

                        // Ultime entry di gratitudine
                        let recent = store.recentGratitude(limit: 3)
                        if !recent.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Ricordi recenti")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.secondary)
                                ForEach(recent, id: \.date) { entry in
                                    HStack(spacing: 6) {
                                        Text("💛").font(.caption2)
                                        Text(entry.text)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(1)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.vertical, 16)
                }
                .frame(minHeight: 300)

            Button {
                completeStep(.gratitude)
                finishRitual()
            } label: {
                Label("Completa Rituale ✨", systemImage: "sparkles")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [Color.pink, Color.orange],
                            startPoint: .leading, endPoint: .trailing
                        ),
                        in: RoundedRectangle(cornerRadius: 14)
                    )
            }
        }
    }

    // MARK: – Session Timer

    private var sessionTimer: some View {
        HStack {
            Image(systemName: "timer")
                .foregroundStyle(.secondary)
            Text("Sessione: \(formatTimeString(seconds))")
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(.secondary)
            Spacer()
            Text("Fase \(currentStep.rawValue + 1)/3")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(.white.opacity(0.5), in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: – Session Log

    private var sessionLog: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Log Sessione")
                .font(.subheadline.weight(.semibold))

            ForEach(logEntries.indices, id: \.self) { i in
                let entry = logEntries[i]
                HStack(alignment: .top, spacing: 8) {
                    Circle()
                        .fill(Color.orange.opacity(0.6))
                        .frame(width: 8, height: 8)
                        .padding(.top, 5)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.0)
                            .font(.caption.weight(.bold))
                        Text(entry.1)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.white.opacity(0.5), in: RoundedRectangle(cornerRadius: 14))
    }

    // MARK: – Reward Sheet

    private var rewardSheet: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("💗").font(.system(size: 60))
            Text("Rituale Completato!")
                .font(.system(.title2, design: .rounded))
                .fontWeight(.bold)
            Text("Il tuo pet si sente amato e sereno")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            VStack(spacing: 10) {
                rewardRow(icon: "🫧", label: "Calma", value: "+40%", tint: .pink)
                rewardRow(icon: "☀️", label: "Felicità", value: "+25%", tint: .pink)
                rewardRow(icon: "🍃", label: "Fame", value: "+10%", tint: .pink)
                rewardRow(icon: "⚡️", label: "Energia", value: "+15%", tint: .pink)
                rewardRow(icon: "🌱", label: "Semi Sereni", value: "+2", tint: .pink)
            }
            .padding()
            .background(Color.pink.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))

            Button("Torna all'isola") {
                showReward = false
                dismiss()
            }
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.horizontal, 40)
            .padding(.vertical, 14)
            .background(
                LinearGradient(colors: [.pink, .orange], startPoint: .leading, endPoint: .trailing),
                in: Capsule()
            )

            Spacer()
        }
        .padding()
        .presentationDetents([.medium])
    }

    // MARK: – Logic

    private func completeStep(_ step: CareRitualStep) {
        withAnimation(.spring(duration: 0.4)) {
            stepCompleted.insert(step)
            addLog(step.title, "Completato ✓")

            // Advance to next
            if let next = CareRitualStep.allCases.first(where: { !stepCompleted.contains($0) }) {
                currentStep = next
            }
        }
    }

    private func startBreathing() {
        running = true
        addLog("Breathing", "Respiro avviato")
        appState.mood = .calm

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            seconds += 1
        }

        startBreathCycle(
            isRunning: { [self] in running },
            onPhase: { [self] name, scale in
                breathPhase = name
                breathScale = scale
            }
        )
    }

    private func stopBreathing() {
        running = false
        timer?.invalidate()
        timer = nil
    }

    private func finishRitual() {
        stopBreathing()
        addLog("Completato", "Rituale terminato. Ricompensa sbloccata!")
        store.completeCareRitual(gratitudeText: gratitudeText)
        appState.mood = .happy
        SoundscapeManager.shared.playBell()
        showReward = true
    }

    private func addLog(_ title: String, _ text: String) {
        logEntries.insert((title, text), at: 0)
        if logEntries.count > 5 {
            logEntries.removeLast()
        }
    }

    // MARK: – Helpers

    private func stepColor(_ step: CareRitualStep) -> Color {
        if stepCompleted.contains(step) { return .green }
        if currentStep == step { return .orange }
        return .gray.opacity(0.4)
    }


}

// MARK: – Floating Hearts Overlay

private struct FloatingHeartsOverlay: View {
    @State private var animate = false

    var body: some View {
        Canvas { context, size in
            let hearts = ["💗", "💖", "🩷", "💕", "🤍"]
            for i in 0..<12 {
                let seed = Double(i * 6571)
                let x = (seed.truncatingRemainder(dividingBy: size.width * 0.94)) + 8
                let baseY = size.height * 0.2 + (seed * 1.7).truncatingRemainder(dividingBy: size.height * 0.7)
                let heartIdx = i % hearts.count

                var txt = context.resolve(Text(hearts[heartIdx]).font(.system(size: 14)))
                context.opacity = 0.25
                context.draw(txt, at: CGPoint(x: x, y: baseY))
                _ = txt // silence warning
            }
        }
        .allowsHitTesting(false)
    }
}
