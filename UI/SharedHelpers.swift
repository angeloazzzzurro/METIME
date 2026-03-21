import SwiftUI

// MARK: - Shared Helpers
// Utilità condivise tra le sezioni per evitare duplicazione di codice.

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
func startBreathCycle(isRunning: @escaping () -> Bool,
                      onPhase: @escaping (String, CGFloat) -> Void) {
    var idx = 0
    func nextPhase() {
        guard isRunning() else { return }
        let phase = breathCyclePhases[idx]
        onPhase(phase.name, phase.scale)
        idx = (idx + 1) % breathCyclePhases.count
        DispatchQueue.main.asyncAfter(deadline: .now() + phase.duration) {
            nextPhase()
        }
    }
    nextPhase()
}
