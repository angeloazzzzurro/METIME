import SwiftUI
import SpriteKit

// MARK: - GardenSectionView

struct GardenSectionView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var store: GameStore

    @State private var scene: GardenScene = {
        let s = GardenScene(size: UIScreen.main.bounds.size)
        s.scaleMode = .resizeFill
        return s
    }()

    var body: some View {
        ZStack(alignment: .bottom) {
            SpriteView(scene: scene, options: [.allowsTransparency])
                .ignoresSafeArea()
                .onAppear { scene.mood = appState.mood }
                .onChange(of: appState.mood) { _, m in scene.mood = m }

            HStack(spacing: 12) {
                gardenButton(icon: "leaf.fill", label: "Annaffia", color: Color(hex: "#34D399")) { store.feed() }
                gardenButton(icon: "hare.fill",  label: "Gioca",    color: Color(hex: "#60A5FA")) { store.play() }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 34)
        }
    }

    private func gardenButton(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                Text(label)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(color, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: color.opacity(0.4), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
    }
}
