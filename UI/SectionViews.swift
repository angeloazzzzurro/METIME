import SwiftUI

// ──────────────────────────────────────────────────────────────────────────────
// MARK: - Componenti condivisi tra le sezioni
// Ogni sezione (Garden, House, Sea, Shop, Meditation, CareRitual)
// è ora nel proprio file. Qui restano i componenti riusabili.
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

// MARK: - BedPreview

struct BedPreview: View {
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

// MARK: - BreathWidget

struct BreathWidget: View {
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

// MARK: - WaveShape

struct WaveShape: Shape {
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
