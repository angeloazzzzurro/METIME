import SwiftUI

// MARK: - SeaSectionView
// Meditazione sulla riva del mare.

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
                Text(formatTimeString(seconds))
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
                            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
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
}
