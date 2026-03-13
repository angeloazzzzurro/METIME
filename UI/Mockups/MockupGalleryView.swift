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

            VStack(spacing: 18) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Buongiorno, Jiayi")
                            .font(.system(size: 30, weight: .black, design: .rounded))
                        Text("Il tuo pet e il tuo giardino stanno crescendo")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }

                HStack(spacing: 10) {
                    StatChip(title: "Calma", value: "82%", tint: .mint)
                    StatChip(title: "Energia", value: "71%", tint: .orange)
                    StatChip(title: "Affetto", value: "94%", tint: .pink)
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
                        .frame(height: 260)
                        .overlay {
                            VStack(spacing: 12) {
                                Text("Pet Garden Stage 2")
                                    .font(.headline)
                                    .foregroundStyle(.white.opacity(0.9))

                                Circle()
                                    .fill(.white.opacity(0.9))
                                    .frame(width: 92, height: 92)
                                    .overlay {
                                        Text("Me")
                                            .font(.system(size: 24, weight: .black, design: .rounded))
                                    }
                                    .shadow(radius: 10)

                                Text("Tap per interagire")
                                    .font(.subheadline)
                                    .foregroundStyle(.white.opacity(0.9))
                            }
                        }

                    HStack(spacing: 10) {
                        ActionPill(icon: "leaf.fill", title: "Nutri", tint: .green)
                        ActionPill(icon: "gamecontroller.fill", title: "Gioca", tint: .blue)
                        ActionPill(icon: "sparkles", title: "Medita", tint: .indigo)
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(20)
        }
        .navigationTitle("Garden")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CareRitualMockupView: View {
    var body: some View {
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

            VStack(spacing: 20) {
                Text("Rituale di Cura")
                    .font(.system(size: 34, weight: .black, design: .rounded))

                Text("4 minuti di respiro guidato per calmare il tuo pet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.white, Color(red: 0.99, green: 0.70, blue: 0.34)],
                            center: .center,
                            startRadius: 10,
                            endRadius: 120
                        )
                    )
                    .frame(width: 240, height: 240)
                    .overlay {
                        VStack(spacing: 4) {
                            Text("Inspira")
                                .font(.title3.weight(.bold))
                            Text("03:12")
                                .font(.system(size: 46, weight: .heavy, design: .rounded))
                        }
                    }
                    .shadow(color: .orange.opacity(0.25), radius: 20, x: 0, y: 12)

                VStack(spacing: 12) {
                    metricRow(label: "Frequenza", value: "6 respiri/min")
                    metricRow(label: "Mood previsto", value: "Calmo +18%")
                    metricRow(label: "Ricompensa", value: "+2 Semi Sereni")
                }
                .padding(18)
                .background(.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 20, style: .continuous))

                Button(action: {}) {
                    Text("Concludi Sessione")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(.black)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
            }
            .padding(20)
        }
        .navigationTitle("Care")
        .navigationBarTitleDisplayMode(.inline)
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
    private let entries = [
        ("Oggi ho dato acqua al pet prima di lavorare", "Molto presente"),
        ("Ho fatto 6 minuti di meditazione guidata", "Più calma"),
        ("Passeggiata breve nel pomeriggio", "Energia in risalita")
    ]

    var body: some View {
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

            VStack(alignment: .leading, spacing: 16) {
                Text("Journal & Insights")
                    .font(.system(size: 32, weight: .black, design: .rounded))

                HStack(spacing: 12) {
                    insightCard(title: "Streak", value: "9 giorni", color: .blue)
                    insightCard(title: "Mood Medio", value: "Sereno", color: .teal)
                }

                Text("Ultime riflessioni")
                    .font(.headline)
                    .padding(.top, 6)

                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(Array(entries.enumerated()), id: \.offset) { _, entry in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(entry.0)
                                    .font(.subheadline.weight(.semibold))
                                Text(entry.1)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(14)
                            .background(.white.opacity(0.75), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                    }
                }
            }
            .padding(20)
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
