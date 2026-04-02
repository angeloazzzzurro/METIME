import SwiftUI
import SwiftData

struct MeditationView: View {
    @EnvironmentObject private var gameStore: GameStore
    @EnvironmentObject private var houseStore: HouseStore

    @State private var selectedMode: MeditationMode = .breathing
    @State private var selectedDuration: Int = 240
    @State private var elapsedSeconds = 0
    @State private var isRunning = false
    @State private var phaseIndex = 0
    @State private var phaseElapsed = 0
    @State private var completionSummary: MeditationCompletion?
    @State private var timerTask: Task<Void, Never>?

    private let durations = [120, 240, 420]

    private var sessions: [MeditationSession] {
        gameStore.recentSessions(limit: 6)
    }

    var body: some View {
        GeometryReader { proxy in
            let compact = proxy.size.width < 900

            ScrollView {
                VStack(spacing: compact ? 16 : 20) {
                    headerCard

                    modePicker

                    if compact {
                        VStack(spacing: 14) {
                            focusCard(compact: true)
                            sidebarColumn
                        }
                    } else {
                        HStack(alignment: .top, spacing: 16) {
                            focusCard(compact: false)
                                .frame(maxWidth: .infinity)

                            sidebarColumn
                                .frame(width: 300)
                        }
                    }
                }
                .padding(compact ? 14 : 20)
            }
            .background(backgroundGradient.ignoresSafeArea())
            .navigationTitle("Meditazione")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $completionSummary) { summary in
                completionSheet(summary: summary)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
            .onDisappear {
                stopSession(resetClock: true, persist: false)
            }
        }
    }

    private var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: "#F7F1E6"),
                Color(hex: "#E8D9BE"),
                Color(hex: "#F5EFE4")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Tempio Meditazione")
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundStyle(Color(hex: "#8B6340"))

                    Text("Respira, rallenta e registra le sessioni reali del pet.")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(Color(hex: "#4A3425"))

                    Text(selectedMode.description)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(hex: "#7C6858"))
                }

                Spacer(minLength: 12)

                VStack(alignment: .trailing, spacing: 8) {
                    meditationBadge(icon: "face.smiling.fill", label: gameStore.pet.mood.rawValue.capitalized)
                    meditationBadge(icon: "dollarsign.circle.fill", label: "+\(coinReward) coin")
                }
            }

            HStack(spacing: 10) {
                summaryChip(title: "Calma", value: "+\(calmReward)%")
                summaryChip(title: "Felicita", value: "+15%")
                summaryChip(title: "Energia", value: "+10%")
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.white.opacity(0.76))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.45), lineWidth: 1)
        )
    }

    private var modePicker: some View {
        HStack(spacing: 10) {
            ForEach(MeditationMode.allCases) { mode in
                Button {
                    guard !isRunning else { return }
                    withAnimation(.snappy(duration: 0.22)) {
                        selectedMode = mode
                    }
                } label: {
                    VStack(spacing: 6) {
                        Text(mode.icon)
                            .font(.system(size: 18))
                        Text(mode.title)
                            .font(.system(size: 13, weight: .black, design: .rounded))
                            .lineLimit(1)
                    }
                    .foregroundStyle(selectedMode == mode ? Color(hex: "#4A3425") : Color(hex: "#866B56"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(selectedMode == mode ? Color(hex: "#F0DFC4") : .white.opacity(0.6))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(selectedMode == mode ? Color(hex: "#8B6340") : .clear, lineWidth: 1.5)
                    )
                }
                .buttonStyle(.plain)
                .disabled(isRunning)
            }
        }
    }

    private func focusCard(compact: Bool) -> some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(selectedMode.title)
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundStyle(Color(hex: "#4A3425"))
                    Spacer()
                    Text(durationLabel(selectedDuration))
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .foregroundStyle(Color(hex: "#8B6340"))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(.white.opacity(0.8), in: Capsule())
                }

                Text(selectedMode.instruction(phaseName: phase.name))
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(hex: "#7C6858"))
            }

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "#F5EAD8"), Color(hex: "#8B6340")],
                            center: .center,
                            startRadius: 20,
                            endRadius: compact ? 140 : 160
                        )
                    )
                    .frame(width: compact ? 250 : 300, height: compact ? 250 : 300)
                    .scaleEffect(circleScale)
                    .shadow(color: Color(hex: "#8B6340").opacity(0.22), radius: 20, x: 0, y: 14)
                    .animation(.easeInOut(duration: 0.9), value: phaseIndex)
                    .animation(.easeInOut(duration: 0.2), value: isRunning)

                VStack(spacing: 8) {
                    Text(isRunning ? phase.name : selectedMode.restingLabel)
                        .font(.system(size: compact ? 18 : 20, weight: .black, design: .rounded))
                        .foregroundStyle(.white)

                    Text(formatTimeString(elapsedSeconds))
                        .font(.system(size: compact ? 38 : 46, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)

                    Text(isRunning ? phaseHint : selectedMode.restInstruction)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.82))
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal, 18)
            }
            .frame(maxWidth: .infinity)

            durationPicker

            HStack(spacing: 10) {
                Button(action: startSession) {
                    Label("Inizia", systemImage: "play.fill")
                        .font(.system(size: 15, weight: .black, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(hex: "#E8D5B0"), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .foregroundStyle(Color(hex: "#4A3425"))
                }
                .buttonStyle(.plain)
                .disabled(isRunning)
                .opacity(isRunning ? 0.55 : 1)

                Button(action: { stopSession(resetClock: true, persist: true) }) {
                    Label("Termina", systemImage: "stop.fill")
                        .font(.system(size: 15, weight: .black, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(.white.opacity(0.86), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .foregroundStyle(Color(hex: "#6B4A30"))
                }
                .buttonStyle(.plain)
                .disabled(!isRunning && elapsedSeconds == 0)
                .opacity((!isRunning && elapsedSeconds == 0) ? 0.55 : 1)
            }
        }
        .padding(compact ? 16 : 20)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(.white.opacity(0.82))
        )
    }

    private var durationPicker: some View {
        HStack(spacing: 10) {
            ForEach(durations, id: \.self) { duration in
                Button {
                    guard !isRunning else { return }
                    withAnimation(.snappy(duration: 0.2)) {
                        selectedDuration = duration
                    }
                } label: {
                    VStack(spacing: 4) {
                        Text(durationLabel(duration))
                            .font(.system(size: 13, weight: .black, design: .rounded))
                        Text(durationCaption(duration))
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(selectedDuration == duration ? .white : Color(hex: "#6B4A30"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(selectedDuration == duration ? Color(hex: "#6B4A30") : .white.opacity(0.8))
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var sidebarColumn: some View {
        VStack(spacing: 14) {
            techniqueCard
            rewardsCard
            historyCard
        }
    }

    private var techniqueCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Tecniche")
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundStyle(Color(hex: "#4A3425"))

            ForEach(selectedMode.techniques, id: \.self) { technique in
                VStack(alignment: .leading, spacing: 4) {
                    Text(technique.title)
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundStyle(Color(hex: "#8B6340"))
                    Text(technique.detail)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(hex: "#7C6858"))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(technique.background, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
        .padding(16)
        .background(cardBackground)
    }

    private var rewardsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Ricompense Sessione")
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundStyle(Color(hex: "#4A3425"))

            rewardRow(icon: "🫧", label: "Calma", value: "+\(calmReward)%", tint: Color(hex: "#8B6340"))
            rewardRow(icon: "☀️", label: "Felicita", value: "+15%", tint: Color(hex: "#8B6340"))
            rewardRow(icon: "⚡", label: "Energia", value: "+10%", tint: Color(hex: "#8B6340"))
            rewardRow(icon: "💰", label: "Coin", value: "+\(coinReward)", tint: Color(hex: "#8B6340"))
        }
        .padding(16)
        .background(cardBackground)
    }

    private var historyCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Storico Sessioni")
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundStyle(Color(hex: "#4A3425"))

            if sessions.isEmpty {
                Text("Nessuna sessione salvata. Completa la prima per vedere lo storico qui.")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(hex: "#7C6858"))
            } else {
                ForEach(Array(sessions.enumerated()), id: \.offset) { _, session in
                    HStack(alignment: .top, spacing: 10) {
                        Text(icon(for: session.type))
                            .font(.system(size: 18))

                        VStack(alignment: .leading, spacing: 4) {
                            Text(title(for: session.type))
                                .font(.system(size: 13, weight: .black, design: .rounded))
                                .foregroundStyle(Color(hex: "#4A3425"))
                            Text("\(formatTimeString(session.durationSeconds)) · \(relativeLabel(for: session.date))")
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .foregroundStyle(Color(hex: "#7C6858"))
                        }

                        Spacer()
                    }
                    .padding(.vertical, 6)
                }
            }
        }
        .padding(16)
        .background(cardBackground)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(.white.opacity(0.82))
    }

    private var phase: (name: String, duration: TimeInterval, scale: CGFloat) {
        breathCyclePhases[phaseIndex % breathCyclePhases.count]
    }

    private var circleScale: CGFloat {
        guard isRunning else { return 0.92 }
        switch selectedMode {
        case .breathing:
            return phase.scale
        case .guided:
            return phase.name == "Espira" || phase.name == "Pausa" ? 0.84 : 1.04
        case .free:
            return 1.0
        }
    }

    private var phaseHint: String {
        switch selectedMode {
        case .breathing:
            return "Ciclo 4-2-6-2"
        case .guided:
            return "Lascia scendere le spalle"
        case .free:
            return "Segui il tuo ritmo"
        }
    }

    private var calmReward: Int {
        Int(min(Double(max(elapsedSeconds, selectedDuration)) / 240.0, 1.0) * 35)
    }

    private var coinReward: Int {
        max(2, max(elapsedSeconds, selectedDuration) / 120)
    }

    private func meditationBadge(icon: String, label: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .black))
            Text(label)
                .font(.system(size: 11, weight: .black, design: .rounded))
        }
        .foregroundStyle(Color(hex: "#6B4A30"))
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(.white.opacity(0.8), in: Capsule())
    }

    private func summaryChip(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(Color(hex: "#7C6858"))
            Text(value)
                .font(.system(size: 14, weight: .black, design: .rounded))
                .foregroundStyle(Color(hex: "#4A3425"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func durationLabel(_ duration: Int) -> String {
        duration >= 60 ? "\(duration / 60) min" : formatTimeString(duration)
    }

    private func durationCaption(_ duration: Int) -> String {
        switch duration {
        case 120: return "Quick"
        case 240: return "Focus"
        default: return "Deep"
        }
    }

    private func icon(for type: String) -> String {
        MeditationMode(rawValue: type)?.icon ?? "🧘"
    }

    private func title(for type: String) -> String {
        MeditationMode(rawValue: type)?.title ?? type.replacingOccurrences(of: "_", with: " ").capitalized
    }

    private func relativeLabel(for date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return "Oggi" }
        if calendar.isDateInYesterday(date) { return "Ieri" }
        return date.formatted(date: .abbreviated, time: .omitted)
    }

    private func startSession() {
        guard !isRunning else { return }

        timerTask?.cancel()
        elapsedSeconds = 0
        phaseIndex = 0
        phaseElapsed = 0
        isRunning = true

        timerTask = Task { @MainActor in
            while !Task.isCancelled, isRunning {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled, isRunning else { break }

                elapsedSeconds += 1
                phaseElapsed += 1

                let phaseDuration = max(1, Int(phase.duration.rounded()))
                if phaseElapsed >= phaseDuration {
                    phaseElapsed = 0
                    phaseIndex = (phaseIndex + 1) % breathCyclePhases.count
                }

                if elapsedSeconds >= selectedDuration {
                    stopSession(resetClock: true, persist: true)
                }
            }
        }
    }

    private func stopSession(resetClock: Bool, persist: Bool) {
        let completedDuration = elapsedSeconds

        isRunning = false
        timerTask?.cancel()
        timerTask = nil

        if persist, completedDuration >= 10 {
            gameStore.completeMeditation(durationSeconds: completedDuration, type: selectedMode.rawValue)
            houseStore.rewardCoins(max(2, completedDuration / 120))
            completionSummary = MeditationCompletion(
                modeTitle: selectedMode.title,
                durationSeconds: completedDuration,
                calmReward: Int(min(Double(completedDuration) / 240.0, 1.0) * 35),
                coinsReward: max(2, completedDuration / 120)
            )
        }

        if resetClock {
            elapsedSeconds = 0
            phaseIndex = 0
            phaseElapsed = 0
        }
    }

    private func completionSheet(summary: MeditationCompletion) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Sessione completata")
                .font(.system(size: 26, weight: .black, design: .rounded))

            Text("\(summary.modeTitle) registrata con successo.")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)

            VStack(spacing: 10) {
                rewardRow(icon: "🕒", label: "Durata", value: formatTimeString(summary.durationSeconds), tint: Color(hex: "#8B6340"))
                rewardRow(icon: "🫧", label: "Calma", value: "+\(summary.calmReward)%", tint: Color(hex: "#8B6340"))
                rewardRow(icon: "☀️", label: "Felicita", value: "+15%", tint: Color(hex: "#8B6340"))
                rewardRow(icon: "⚡", label: "Energia", value: "+10%", tint: Color(hex: "#8B6340"))
                rewardRow(icon: "💰", label: "Coin", value: "+\(summary.coinsReward)", tint: Color(hex: "#8B6340"))
            }
            .padding(14)
            .background(Color(hex: "#F7F1E6"), in: RoundedRectangle(cornerRadius: 16, style: .continuous))

            Button("Chiudi") {
                completionSummary = nil
            }
            .font(.system(size: 15, weight: .black, design: .rounded))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(Color.black, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .foregroundStyle(.white)
            .buttonStyle(.plain)
        }
        .padding(20)
    }
}

private enum MeditationMode: String, CaseIterable, Identifiable {
    case breathing
    case guided
    case free

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .breathing: return "🌬️"
        case .guided: return "✨"
        case .free: return "⏱️"
        }
    }

    var title: String {
        switch self {
        case .breathing: return "Respiro"
        case .guided: return "Guidata"
        case .free: return "Libera"
        }
    }

    var description: String {
        switch self {
        case .breathing:
            return "Ciclo visivo 4-2-6-2 per rallentare e aumentare la calma."
        case .guided:
            return "Una sessione morbida con prompt semplici per sciogliere tensione e ritrovare focus."
        case .free:
            return "Solo timer e presenza: medita al tuo ritmo senza guida forzata."
        }
    }

    var restingLabel: String {
        switch self {
        case .breathing: return "Inspira"
        case .guided: return "Ascolta"
        case .free: return "Presenza"
        }
    }

    var restInstruction: String {
        switch self {
        case .breathing: return "Segui il cerchio" 
        case .guided: return "Lascia andare la tensione"
        case .free: return "Quando vuoi, premi Inizia"
        }
    }

    func instruction(phaseName: String) -> String {
        switch self {
        case .breathing:
            return "Inspira ed espira con il cerchio. Fase attuale: \(phaseName.lowercased())."
        case .guided:
            return "Rilassa mandibola, spalle e addome. Procedi un respiro alla volta."
        case .free:
            return "Timer pulito e storico attivo. Nessuna guida, solo continuita."
        }
    }

    var techniques: [(title: String, detail: String, background: Color)] {
        switch self {
        case .breathing:
            return [
                ("4-2-6-2", "Inspira 4s · Tieni 2s · Espira 6s · Pausa 2s", Color(hex: "#F5EAD8")),
                ("Box Breathing", "4s per ogni fase per ritrovare stabilita", Color(hex: "#F0E8D0"))
            ]
        case .guided:
            return [
                ("Scansione corpo", "Porta attenzione da testa a piedi e allenta la tensione", Color(hex: "#F5EAD8")),
                ("Visualizzazione", "Immagina un luogo sicuro e lascia rallentare il respiro", Color(hex: "#F0E8D0"))
            ]
        case .free:
            return [
                ("Silenzio", "Siediti comodo e mantieni il ritmo che senti naturale", Color(hex: "#F5EAD8")),
                ("Journaling dopo", "Chiudi la sessione e registra un pensiero nel diario", Color(hex: "#F0E8D0"))
            ]
        }
    }
}

private struct MeditationCompletion: Identifiable {
    let id = UUID()
    let modeTitle: String
    let durationSeconds: Int
    let calmReward: Int
    let coinsReward: Int
}

#Preview {
    let schema = Schema([
        Pet.self,
        PetNeeds.self,
        OwnedItem.self,
        Wallet.self,
        GardenState.self,
        MeditationSession.self,
        GratitudeEntry.self,
    ])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])
    let context = container.mainContext
    let gameStore = GameStore(modelContext: context)
    let houseStore = HouseStore(modelContext: context)

    return NavigationStack {
        MeditationView()
            .environmentObject(gameStore)
            .environmentObject(houseStore)
    }
    .modelContainer(container)
}