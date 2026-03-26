import SwiftUI

struct MockupGalleryView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    mockupLink(
                        title: "Garden Home",
                        subtitle: "Vista principale con pet, progressi e azioni rapide",
                        accent: Color(red: 0.20, green: 0.63, blue: 0.45)
                    ) {
                        GardenHomeMockupView()
                    }

                    mockupLink(
                        title: "Care Ritual",
                        subtitle: "Sessione mindful con timer, respiro e ricompensa",
                        accent: Color(red: 0.93, green: 0.57, blue: 0.19)
                    ) {
                        CareRitualMockupView()
                    }

                    mockupLink(
                        title: "Journal Insights",
                        subtitle: "Mood tracking e riflessioni giornaliere",
                        accent: Color(red: 0.12, green: 0.47, blue: 0.78)
                    ) {
                        JournalInsightsMockupView()
                    }
                }
                .padding(20)
            }
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.96, green: 0.98, blue: 0.95),
                        Color(red: 0.91, green: 0.97, blue: 0.93)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle("METIME Mockups")
        }
    }

    private func mockupLink<Destination: View>(
        title: String,
        subtitle: String,
        accent: Color,
        @ViewBuilder destination: @escaping () -> Destination
    ) -> some View {
        NavigationLink(destination: destination()) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(title)
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    Spacer()
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.white.opacity(0.85))
                }

                Text(subtitle)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.leading)
            }
            .padding(18)
            .frame(maxWidth: .infinity, minHeight: 130, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [accent.opacity(0.95), accent.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(.white.opacity(0.25), lineWidth: 1)
            )
            .shadow(color: accent.opacity(0.25), radius: 18, x: 0, y: 12)
        }
        .buttonStyle(.plain)
    }
}

struct GardenHomeMockupView: View {
    var body: some View {
        GeometryReader { proxy in
            let compact = proxy.size.width < 430

            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.90, green: 0.98, blue: 0.97),
                        Color(red: 0.78, green: 0.92, blue: 0.87)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: compact ? 14 : 18) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Buongiorno, Jiayi")
                                    .font(.system(size: compact ? 24 : 30, weight: .black, design: .rounded))
                                Text("Il tuo pet e il tuo giardino stanno crescendo")
                                    .font(compact ? .caption : .subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }

                        if compact {
                            VStack(spacing: 10) {
                                StatChip(title: "Calma", value: "82%", tint: .mint)
                                StatChip(title: "Energia", value: "71%", tint: .orange)
                                StatChip(title: "Affetto", value: "94%", tint: .pink)
                            }
                        } else {
                            HStack(spacing: 10) {
                                StatChip(title: "Calma", value: "82%", tint: .mint)
                                StatChip(title: "Energia", value: "71%", tint: .orange)
                                StatChip(title: "Affetto", value: "94%", tint: .pink)
                            }
                        }

                        VStack(spacing: 14) {
                            RoundedRectangle(cornerRadius: 26, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [Color(red: 0.31, green: 0.75, blue: 0.50), Color(red: 0.13, green: 0.60, blue: 0.39)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(height: compact ? 220 : 260)
                                .overlay {
                                    VStack(spacing: 12) {
                                        Text("Pet Garden Stage 2")
                                            .font(.headline)
                                            .foregroundStyle(.white.opacity(0.9))

                                        Circle()
                                            .fill(.white.opacity(0.9))
                                            .frame(width: compact ? 78 : 92, height: compact ? 78 : 92)
                                            .overlay {
                                                Text("Me")
                                                    .font(.system(size: compact ? 20 : 24, weight: .black, design: .rounded))
                                            }
                                            .shadow(radius: 10)

                                        Text("Tap per interagire")
                                            .font(compact ? .caption : .subheadline)
                                            .foregroundStyle(.white.opacity(0.9))
                                    }
                                }

                            if compact {
                                VStack(spacing: 10) {
                                    ActionPill(icon: "leaf.fill", title: "Nutri", tint: .green)
                                    ActionPill(icon: "gamecontroller.fill", title: "Gioca", tint: .blue)
                                    ActionPill(icon: "sparkles", title: "Medita", tint: .indigo)
                                }
                            } else {
                                HStack(spacing: 10) {
                                    ActionPill(icon: "leaf.fill", title: "Nutri", tint: .green)
                                    ActionPill(icon: "gamecontroller.fill", title: "Gioca", tint: .blue)
                                    ActionPill(icon: "sparkles", title: "Medita", tint: .indigo)
                                }
                            }
                        }
                    }
                    .padding(20)
                }
            }
        }
        .navigationTitle("Garden")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CareRitualMockupView: View {
    @EnvironmentObject private var gameStore: GameStore
    @EnvironmentObject private var houseStore: HouseStore

    @State private var selectedDuration = 240
    @State private var gratitudeText = ""
    @State private var didComplete = false

    private let durations = [120, 240, 360]

    var body: some View {
        GeometryReader { proxy in
            let compact = proxy.size.width < 430

            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.99, green: 0.93, blue: 0.86),
                        Color(red: 0.95, green: 0.82, blue: 0.69)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: compact ? 16 : 20) {
                        breathingOrb(compact: compact)

                        durationPicker(compact: compact)

                        VStack(spacing: 12) {
                            metricRow(label: "Mood attuale", value: gameStore.pet.mood.rawValue.capitalized)
                            metricRow(label: "Calma prevista", value: "+\(predictedCalmBoost)%")
                            metricRow(label: "Ricompensa", value: "+\(coinReward) monete")
                        }
                        .padding(compact ? 14 : 18)
                        .background(.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 20, style: .continuous))

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Gratitudine finale")
                                .font(.headline.weight(.bold))
                            TextField("Scrivi una cosa positiva di oggi", text: $gratitudeText, axis: .vertical)
                                .textFieldStyle(.roundedBorder)
                                .lineLimit(3...5)
                        }
                        .padding(compact ? 14 : 18)
                        .background(.white.opacity(0.82), in: RoundedRectangle(cornerRadius: 20, style: .continuous))

                        Button(action: completeRitual) {
                            Text("Concludi Sessione")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(.black)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                    }
                    .padding(compact ? 14 : 20)
                    .padding(.top, compact ? 96 : 114)
                }
                .scrollBounceBehavior(.basedOnSize)
            }
            .navigationTitle("Care")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .top) {
                careStickyHeader(compact: compact)
            }
            .navigationDestination(isPresented: $didComplete) {
                JournalInsightsMockupView()
                    .environmentObject(gameStore)
            }
        }
    }

    private func breathingOrb(compact: Bool) -> some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [Color.white, Color(red: 0.99, green: 0.70, blue: 0.34)],
                    center: .center,
                    startRadius: 10,
                    endRadius: 120
                )
            )
            .frame(width: compact ? 190 : 240, height: compact ? 190 : 240)
            .overlay {
                VStack(spacing: 6) {
                    Text(selectedDuration >= 240 ? "Inspira ed espira" : "Respira piano")
                        .font((compact ? Font.headline : .title3).weight(.bold))
                    Text(durationLabel(selectedDuration))
                        .font(.system(size: compact ? 32 : 42, weight: .heavy, design: .rounded))
                    Text(gameStore.pet.mood == .anxious ? "Riduci l'ansia del pet" : "Mantieni il ritmo")
                        .font((compact ? Font.caption2 : .caption).weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .shadow(color: .orange.opacity(0.25), radius: 20, x: 0, y: 12)
            .scaleEffect(selectedDuration == 360 ? 1.04 : 1)
            .animation(.easeInOut(duration: 0.28), value: selectedDuration)
    }

    private func durationPicker(compact: Bool) -> some View {
        HStack(spacing: compact ? 8 : 10) {
            ForEach(durations, id: \.self) { duration in
                Button {
                    withAnimation(.snappy(duration: 0.2)) {
                        selectedDuration = duration
                    }
                } label: {
                    VStack(spacing: 4) {
                        Text(durationLabel(duration))
                            .font(.system(size: compact ? 13 : 15, weight: .bold, design: .rounded))
                        Text(duration == 120 ? "Quick" : duration == 240 ? "Care" : "Deep")
                            .font((compact ? Font.caption2 : .caption).weight(.bold))
                    }
                    .foregroundStyle(selectedDuration == duration ? .white : .brown)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, compact ? 9 : 10)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(selectedDuration == duration ? Color.black : Color.white.opacity(0.78))
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .animation(.snappy(duration: 0.22), value: selectedDuration)
    }

    private func careStickyHeader(compact: Bool) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Rituale di Cura")
                        .font(.system(size: compact ? 22 : 30, weight: .black, design: .rounded))
                    Text("Un micro-rituale reale che calma il pet, migliora l'umore e salva la sessione.")
                        .font(.system(size: compact ? 11 : 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(gameStore.pet.mood.rawValue.capitalized)
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(.white.opacity(0.85), in: Capsule())
                    Text(durationLabel(selectedDuration))
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(.brown)
                }
            }

            durationPicker(compact: compact)
        }
        .padding(.horizontal, compact ? 14 : 20)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.99, green: 0.93, blue: 0.86),
                    Color(red: 0.97, green: 0.88, blue: 0.78)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private var predictedCalmBoost: Int {
        Int(min(Double(selectedDuration) / 240.0, 1.0) * 35)
    }

    private var coinReward: Int {
        max(2, selectedDuration / 120)
    }

    private func durationLabel(_ duration: Int) -> String {
        let minutes = duration / 60
        return "\(minutes) min"
    }

    private func completeRitual() {
        gameStore.completeRelaxRitual(durationSeconds: selectedDuration, gratitudeText: gratitudeText)
        houseStore.rewardCoins(coinReward)
        didComplete = true
    }

    private func metricRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .fontWeight(.semibold)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.orange)
        }
    }
}

struct JournalInsightsMockupView: View {
    @EnvironmentObject private var gameStore: GameStore
    @State private var journalText = ""
    @State private var didSaveEntry = false

    private var sessions: [MeditationSession] {
        gameStore.recentSessions(limit: 3)
    }

    private var gratitudeEntries: [GratitudeEntry] {
        gameStore.recentGratitude(limit: 3)
    }

    var body: some View {
        GeometryReader { proxy in
            let compact = proxy.size.width < 430

            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.90, green: 0.94, blue: 1.0),
                        Color(red: 0.80, green: 0.88, blue: 0.98)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: compact ? 14 : 16) {
                        Text("Journal & Insights")
                            .font(.system(size: compact ? 24 : 32, weight: .black, design: .rounded))

                        if compact {
                            VStack(spacing: 10) {
                                insightCard(title: "Mood", value: gameStore.pet.mood.rawValue.capitalized, color: .blue)
                                insightCard(title: "Stage", value: "Lv \(gameStore.pet.stage)", color: .teal)
                            }
                        } else {
                            HStack(spacing: 12) {
                                insightCard(title: "Mood", value: gameStore.pet.mood.rawValue.capitalized, color: .blue)
                                insightCard(title: "Stage", value: "Lv \(gameStore.pet.stage)", color: .teal)
                            }
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Scrivi nel diario")
                                    .font(.headline)
                                Spacer()
                                Text("+18% calma")
                                    .font(.system(size: 11, weight: .black, design: .rounded))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(.white.opacity(0.82), in: Capsule())
                            }

                            TextField("Scrivi come ti senti o una riflessione breve", text: $journalText, axis: .vertical)
                                .textFieldStyle(.roundedBorder)
                                .lineLimit(4...7)

                            Button {
                                gameStore.writeDiaryEntry(journalText)
                                journalText = ""
                                withAnimation(.snappy(duration: 0.18)) {
                                    didSaveEntry = true
                                }
                                Task { @MainActor in
                                    try? await Task.sleep(for: .seconds(1.4))
                                    withAnimation(.easeOut(duration: 0.2)) {
                                        didSaveEntry = false
                                    }
                                }
                            } label: {
                                Text("Salva nel diario")
                                    .font(.system(size: 15, weight: .black, design: .rounded))
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 13)
                                    .background(Color.black, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            }
                            .buttonStyle(.plain)
                            .disabled(journalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            .opacity(journalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.55 : 1)

                            if didSaveEntry {
                                Text("Diario salvato. Il pet recupera calma.")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundStyle(.blue)
                            }
                        }
                        .padding(compact ? 14 : 16)
                        .background(.white.opacity(0.78), in: RoundedRectangle(cornerRadius: 18, style: .continuous))

                        if !sessions.isEmpty {
                            Text("Ultime sessioni")
                                .font(.headline)
                                .padding(.top, 6)

                            VStack(spacing: 10) {
                                ForEach(Array(sessions.enumerated()), id: \.offset) { _, session in
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(session.type.replacingOccurrences(of: "_", with: " ").capitalized)
                                            .font(.subheadline.weight(.semibold))
                                        Text("\(session.durationSeconds / 60) min · \(session.date.formatted(date: .abbreviated, time: .shortened))")
                                            .font(.footnote)
                                            .foregroundStyle(.secondary)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(14)
                                    .background(.white.opacity(0.75), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                                }
                            }
                        }

                        if !gratitudeEntries.isEmpty {
                            Text("Ultime riflessioni")
                                .font(.headline)
                                .padding(.top, 6)

                            VStack(spacing: 10) {
                                ForEach(Array(gratitudeEntries.enumerated()), id: \.offset) { _, entry in
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(entry.text)
                                            .font(.subheadline.weight(.semibold))
                                        Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                                            .font(.footnote)
                                            .foregroundStyle(.secondary)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(14)
                                    .background(.white.opacity(0.75), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                                }
                            }
                        } else {
                            Text("Concludi un rituale con una nota di gratitudine per vedere i tuoi insight qui.")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.secondary)
                                .padding(.top, 8)
                        }
                    }
                    .padding(compact ? 14 : 20)
                }
            }
        }
        .navigationTitle("Journal")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func insightCard(title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3.weight(.heavy))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(color.opacity(0.16), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct StatChip: View {
    let title: String
    let value: String
    let tint: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline.weight(.heavy))
                .foregroundStyle(tint)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(.white.opacity(0.74), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct ActionPill: View {
    let icon: String
    let title: String
    let tint: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.headline)
            Text(title)
                .font(.caption.weight(.semibold))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .foregroundStyle(.white)
        .background(tint, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

#Preview("Mockup Gallery") {
    MockupGalleryView()
}

#Preview("Garden Home") {
    NavigationStack {
        GardenHomeMockupView()
    }
}

#Preview("Care Ritual") {
    NavigationStack {
        CareRitualMockupView()
    }
}

#Preview("Journal Insights") {
    NavigationStack {
        JournalInsightsMockupView()
    }
}
