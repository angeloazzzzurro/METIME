import SwiftUI
import SpriteKit

// MARK: - GardenSectionView
// Il giardino esistente con SpriteKit (GardenScene) + azioni rapide.

struct GardenSectionView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var store: GameStore
    @Environment(\.dismiss) private var dismiss

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

            VStack(spacing: 0) {
                sectionHeader(title: "🌿 Giardino", tint: .green)

                HStack(spacing: 12) {
                    SectionActionButton(icon: "leaf.fill",          label: "Annaffia", tint: .green)  { store.feed() }
                    SectionActionButton(icon: "hare.fill",          label: "Gioca",    tint: .blue)   { store.play() }
                }
                .padding(.bottom, 34)
                .padding(.horizontal, 20)
            }
        }
    }
}
