import SwiftUI

// MARK: - Shared Helpers
// Utilità condivise tra le sezioni per evitare duplicazione di codice.

enum JoystickDirection: Equatable {
    case idle
    case vector(CGVector)

    var vector: CGVector {
        switch self {
        case .idle:
            return .zero
        case .vector(let vector):
            return vector
        }
    }
}

/// Formatta secondi in mm:ss
func formatTimeString(_ s: Int) -> String {
    String(format: "%02d:%02d", s / 60, s % 60)
}

/// Riga ricompensa usata nei sheet di completamento
func rewardRow(icon: String, label: String, value: String, tint: Color = .secondary) -> some View {
    HStack {
        Text(icon)
        Text(label).font(.subheadline)
        Spacer()
        Text(value).font(.subheadline.weight(.semibold)).foregroundStyle(tint)
    }
}

/// Durata della fase di respiro corrente basata sul nome della fase
func breathPhaseDuration(for phase: String) -> Double {
    switch phase {
    case "Inspira":  4.0
    case "Tieni":    2.0
    case "Espira":   6.0
    default:         2.0
    }
}

/// Fasi del ciclo di respiro con durata e scala
let breathCyclePhases: [(name: String, duration: TimeInterval, scale: CGFloat)] = [
    ("Inspira",  4.0, 1.0),
    ("Tieni",    2.0, 1.0),
    ("Espira",   6.0, 0.6),
    ("Pausa",    2.0, 0.6),
]

/// Avvia un ciclo di respiro ricorsivo. Chiama `onPhase` con ogni fase finché `isRunning()` è true.
@MainActor
func startBreathCycle(isRunning: @escaping () -> Bool,
                      onPhase: @escaping (String, CGFloat) -> Void) {
    var idx = 0
    @MainActor
    func nextPhase() {
        guard isRunning() else { return }
        let phase = breathCyclePhases[idx]
        onPhase(phase.name, phase.scale)
        idx = (idx + 1) % breathCyclePhases.count
        DispatchQueue.main.asyncAfter(deadline: .now() + phase.duration) {
            Task { @MainActor in
                nextPhase()
            }
        }
    }
    nextPhase()
}

struct JoystickControl: View {
    let onMove: (CGVector) -> Void
    let onEnd: () -> Void

    @State private var knobOffset: CGSize = .zero

    private let baseSize: CGFloat = 108
    private let knobSize: CGFloat = 42
    private let maxRadius: CGFloat = 34

    var body: some View {
        ZStack {
            Circle()
                .fill(.white.opacity(0.18))
                .overlay {
                    Circle()
                        .stroke(.white.opacity(0.35), lineWidth: 1)
                }
                .background(
                    Circle()
                        .fill(.black.opacity(0.08))
                        .blur(radius: 14)
                )

            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.95), Color.white.opacity(0.72)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: knobSize, height: knobSize)
                .overlay {
                    Circle()
                        .stroke(Color.black.opacity(0.08), lineWidth: 1)
                }
                .offset(knobOffset)
        }
        .frame(width: baseSize, height: baseSize)
        .contentShape(Circle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    let translation = CGSize(
                        width: value.translation.width,
                        height: value.translation.height
                    )
                    let resolved = clampedOffset(for: translation)
                    knobOffset = resolved

                    let vector = CGVector(
                        dx: resolved.width / maxRadius,
                        dy: -(resolved.height / maxRadius)
                    )
                    onMove(vector)
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.72)) {
                        knobOffset = .zero
                    }
                    onEnd()
                }
        )
        .accessibilityLabel("Joystick movimento")
    }

    private func clampedOffset(for translation: CGSize) -> CGSize {
        let distance = hypot(translation.width, translation.height)
        guard distance > maxRadius, distance > 0 else { return translation }

        let scale = maxRadius / distance
        return CGSize(
            width: translation.width * scale,
            height: translation.height * scale
        )
    }
}
