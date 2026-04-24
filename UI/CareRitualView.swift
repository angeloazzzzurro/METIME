import SwiftUI

// MARK: - CareRitualView
// 3-step ritual: Grounding → Breathing → Gratitude
// Palette: warm Animal Crossing (cream/brown/sage)

struct CareRitualView: View {
    @EnvironmentObject private var store: GameStore
    @EnvironmentObject private var houseStore: HouseStore

    @State private var currentStep: Int = 0
    @State private var completed = false
    @State private var showReward = false

    var body: some View {
        GeometryReader { proxy in
            let compact = proxy.size.width < 430
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color(hex: "#b8cdb0"), Color(hex: "#d4e0c8"), Color(hex: "#f5ead8")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: compact ? 16 : 20) {
                        header(compact: compact)
                        stepProgress
                        stepContent(compact: compact)
                        rewardsCard(compact: compact)
                    }
                    .padding(.horizontal, compact ? 14 : 20)
                    .padding(.vertical, 16)
                    .padding(.bottom, 40)
                }

                if showReward {
                    rewardOverlay
                }
            }
        }
    }

    // MARK: - Header

    private func header(compact: Bool) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Rituale")
                .font(.system(size: compact ? 11 : 13, weight: .bold, design: .rounded))
                .foregroundStyle(Color(hex: "#8a7260"))
            Text("Cura del Pet")
                .font(.system(size: compact ? 26 : 32, weight: .black, design: .rounded))
                .foregroundStyle(Color(hex: "#3d2b1f"))
            Text("3 fasi per calmare pet e player. Completa per sbloccare ricompense.")
                .font(.system(size: compact ? 12 : 14, weight: .medium, design: .rounded))
                .foregroundStyle(Color(hex: "#5e4636"))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(hex: "#fdf3e3").opacity(0.88), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(Color(hex: "#c9a96e").opacity(0.5), lineWidth: 1.5))
    }

    // MARK: - Step Progress

    private var stepProgress: some View {
        HStack(spacing: 0) {
            ForEach(0..<3) { i in
                stepDot(index: i)
                if i < 2 {
                    Rectangle()
                        .fill(currentStep > i ? Color(hex: "#8fa882") : Color(hex: "#c9a96e").opacity(0.35))
                        .frame(height: 2)
                        .animation(.easeInOut(duration: 0.3), value: currentStep)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color(hex: "#fdf3e3").opacity(0.88), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color(hex: "#c9a96e").opacity(0.5), lineWidth: 1.5))
    }

    private func stepDot(index: Int) -> some View {
        let icons = ["leaf.fill", "wind", "heart.fill"]
        let labels = ["Grounding", "Respiro", "Gratitudine"]
        let isDone = currentStep > index
        let isActive = currentStep == index

        return VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(isDone ? Color(hex: "#8fa882") : isActive ? Color(hex: "#f5ead8") : Color(hex: "#e8d5b0"))
                    .frame(width: 38, height: 38)
                    .overlay(
                        Circle().stroke(
                            isDone ? Color(hex: "#5a9a2e") : isActive ? Color(hex: "#a67c52") : Color(hex: "#c9a96e").opacity(0.4),
                            lineWidth: 2
                        )
                    )
                Image(systemName: isDone ? "checkmark" : icons[index])
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(isDone ? .white : isActive ? Color(hex: "#a67c52") : Color(hex: "#c9a96e"))
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: currentStep)

            Text(labels[index])
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundStyle(isActive ? Color(hex: "#3d2b1f") : Color(hex: "#8a7260"))
        }
    }

    // MARK: - Step Content

    @ViewBuilder
    private func stepContent(compact: Bool) -> some View {
        switch currentStep {
        case 0:  GroundingStep(onNext: advance)
        case 1:  BreathingStep(onNext: advance)
        case 2:  GratitudeStep(onComplete: complete)
        default: EmptyView()
        }
    }

    // MARK: - Rewards Card

    private func rewardsCard(compact: Bool) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Ricompense")
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundStyle(Color(hex: "#3d2b1f"))
            VStack(spacing: 6) {
                rewardRow(icon: "bubble.left.fill", label: "Calma",    value: "+40%", tint: Color(hex: "#60A5FA"))
                rewardRow(icon: "sun.max.fill",     label: "Felicita", value: "+25%", tint: Color(hex: "#F59E0B"))
                rewardRow(icon: "leaf.fill",         label: "Fame",     value: "+10%", tint: Color(hex: "#8fa882"))
                rewardRow(icon: "bolt.fill",         label: "Energia",  value: "+15%", tint: Color(hex: "#22C55E"))
            }
        }
        .padding(16)
        .background(Color(hex: "#fdf3e3").opacity(0.88), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(Color(hex: "#c9a96e").opacity(0.5), lineWidth: 1.5))
    }

    private func rewardRow(icon: String, label: String, value: String, tint: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(tint)
                .frame(width: 24)
            Text(label)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(hex: "#5e4636"))
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundStyle(tint)
        }
    }

    // MARK: - Reward Overlay

    private var rewardOverlay: some View {
        ZStack {
            Color(hex: "#3d2b1f").opacity(0.55)
                .ignoresSafeArea()
                .onTapGesture { withAnimation { showReward = false } }

            VStack(spacing: 16) {
                Text("Rituale completato!")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(Color(hex: "#3d2b1f"))
                Text("Calma +40% · Felicita +25%\nFame +10% · Energia +15%")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: "#5e4636"))
                    .multilineTextAlignment(.center)
                Button("Continua") {
                    withAnimation { showReward = false }
                }
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 28)
                .padding(.vertical, 12)
                .background(Color(hex: "#a67c52"), in: Capsule())
            }
            .padding(28)
            .background(Color(hex: "#fdf3e3"), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous).stroke(Color(hex: "#c9a96e"), lineWidth: 2))
            .shadow(color: Color(hex: "#3d2b1f").opacity(0.25), radius: 32, y: 12)
            .padding(.horizontal, 32)
            .transition(.scale(scale: 0.85).combined(with: .opacity))
        }
    }

    // MARK: - Actions

    private func advance() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
            currentStep = min(currentStep + 1, 2)
        }
    }

    private func complete() {
        store.meditate()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.65)) {
            showReward = true
            completed = true
            currentStep = 3
        }
    }
}

// MARK: - Step 1: Grounding

private struct GroundingStep: View {
    let onNext: () -> Void
    @State private var pulseScale: CGFloat = 1.0

    var body: some View {
        VStack(spacing: 18) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Grounding")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(Color(hex: "#3d2b1f"))
                Text("Siediti comodo e rilassa le spalle. Senti i piedi a terra.")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(hex: "#5e4636"))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 16) {
                ForEach(0..<3) { i in
                    Circle()
                        .fill(Color(hex: "#8fa882").opacity(0.3))
                        .overlay(Circle().stroke(Color(hex: "#8fa882").opacity(0.5), lineWidth: 2))
                        .frame(width: 42, height: 42)
                        .scaleEffect(pulseScale)
                        .animation(
                            .easeInOut(duration: 2).repeatForever(autoreverses: true).delay(Double(i) * 0.5),
                            value: pulseScale
                        )
                }
            }
            .onAppear { pulseScale = 1.12 }

            Button(action: onNext) {
                Text("Ho rilassato le spalle")
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(colors: [Color(hex: "#a8c9a0"), Color(hex: "#8fa882")],
                                       startPoint: .leading, endPoint: .trailing),
                        in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .background(Color(hex: "#fdf3e3").opacity(0.88), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(Color(hex: "#c9a96e").opacity(0.5), lineWidth: 1.5))
    }
}

// MARK: - Step 2: Breathing

private struct BreathingStep: View {
    let onNext: () -> Void

    @State private var isRunning = false
    @State private var elapsed = 0
    @State private var phaseIdx = 0
    @State private var phaseElapsed = 0
    @State private var breathScale: CGFloat = 1.0
    @State private var timerTask: Task<Void, Never>?

    private let phases = ["Inspira", "Tieni", "Espira", "Pausa"]
    private let durations = [4, 2, 6, 2]
    private var canProceed: Bool { elapsed >= 30 }

    var body: some View {
        VStack(spacing: 18) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Breathing")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(Color(hex: "#3d2b1f"))
                Text("Inspira 4 sec · Tieni 2 · Espira 6 sec · Pausa 2. Minimo 30 sec.")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(hex: "#5e4636"))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Breathing circle
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "#fff7eb"), Color(hex: "#f2a044")],
                            center: .init(x: 0.4, y: 0.35),
                            startRadius: 10, endRadius: 130
                        )
                    )
                    .frame(width: 180, height: 180)
                    .scaleEffect(breathScale)
                    .shadow(color: Color(hex: "#7f4310").opacity(0.22), radius: 18, y: 10)
                    .animation(.easeInOut(duration: Double(durations[phaseIdx])), value: breathScale)

                VStack(spacing: 4) {
                    Text(isRunning ? phases[phaseIdx] : "Pronto")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(hex: "#3d2b1f"))
                    Text(formatTime(elapsed))
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(Color(hex: "#3d2b1f"))
                }
            }
            .padding(.vertical, 8)

            HStack(spacing: 12) {
                Button(isRunning ? "Pausa" : "Avvia Respiro") {
                    isRunning ? stopTimer() : startTimer()
                }
                .font(.system(size: 14, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(colors: [Color(hex: "#d4a76a"), Color(hex: "#a67c52")],
                                   startPoint: .leading, endPoint: .trailing),
                    in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                )
                .buttonStyle(.plain)

                if canProceed {
                    Button("Prosegui") {
                        stopTimer()
                        onNext()
                    }
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(hex: "#8fa882"), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .buttonStyle(.plain)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
        }
        .padding(18)
        .background(Color(hex: "#fdf3e3").opacity(0.88), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(Color(hex: "#c9a96e").opacity(0.5), lineWidth: 1.5))
        .onDisappear { stopTimer() }
    }

    private func startTimer() {
        isRunning = true
        timerTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard !Task.isCancelled else { break }
                await MainActor.run {
                    elapsed += 1
                    phaseElapsed += 1
                    if phaseElapsed >= durations[phaseIdx] {
                        phaseElapsed = 0
                        phaseIdx = (phaseIdx + 1) % 4
                        updateBreath()
                    }
                }
            }
        }
        updateBreath()
    }

    private func stopTimer() {
        isRunning = false
        timerTask?.cancel()
        timerTask = nil
    }

    private func updateBreath() {
        withAnimation(.easeInOut(duration: Double(durations[phaseIdx]))) {
            breathScale = phaseIdx == 0 ? 1.2 : phaseIdx == 2 ? 0.88 : 1.0
        }
    }

    private func formatTime(_ s: Int) -> String {
        String(format: "%02d:%02d", s / 60, s % 60)
    }
}

// MARK: - Step 3: Gratitude

private struct GratitudeStep: View {
    let onComplete: () -> Void
    @State private var text = ""

    var body: some View {
        VStack(spacing: 18) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Gratitudine")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(Color(hex: "#3d2b1f"))
                Text("Scrivi una cosa positiva della tua giornata.")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(hex: "#5e4636"))
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            TextEditor(text: $text)
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(Color(hex: "#3d2b1f"))
                .scrollContentBackground(.hidden)
                .background(Color(hex: "#fdf3e3").opacity(0.7))
                .frame(minHeight: 100)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color(hex: "#fdf3e3").opacity(0.7))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color(hex: "#c9a96e").opacity(0.6), lineWidth: 1.5)
                        )
                )

            Button(action: onComplete) {
                Text("Completa Rituale")
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(colors: [Color(hex: "#e8a0a0"), Color(hex: "#d36f8e")],
                                       startPoint: .leading, endPoint: .trailing),
                        in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                    )
            }
            .buttonStyle(.plain)
            .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .opacity(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
        }
        .padding(18)
        .background(Color(hex: "#fdf3e3").opacity(0.88), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(Color(hex: "#c9a96e").opacity(0.5), lineWidth: 1.5))
    }
}
