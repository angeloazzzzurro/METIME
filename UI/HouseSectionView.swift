import SwiftUI

// MARK: - HouseSectionView
// Interno casa: cura del pet, rituale quotidiano, sezione Diario.

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
                    let durations: [Double] = [4, 2, 6, 2]
                    breathTimer?.invalidate()
                    breathTimer = Timer.scheduledTimer(withTimeInterval: durations[0], repeats: true) { t in
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
