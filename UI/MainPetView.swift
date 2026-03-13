import SwiftUI
import SpriteKit

struct MainPetView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var store: GameStore

    @State private var showJournal = false

    var body: some View {
        ZStack(alignment: .bottom) {
            SceneView(scene: makeScene(), options: [.allowsTransparency])
                .ignoresSafeArea()

            VStack {
                topHUD
                Spacer()
            }
            .padding(.top, 50)
            .padding(.horizontal, 16)

            actionBar
                .padding(.bottom, 30)
                .padding(.horizontal, 20)
        }
        .onChange(of: appState.mood) { _, mood in
            SoundscapeManager.shared.transition(to: mood)
        }
    }

    private var topHUD: some View {
        VStack(spacing: 8) {
            HStack {
                Text(store.pet.name).font(.headline)
                Spacer()
                Text("Mood: \(appState.mood.rawValue)")
            }
            HStack {
                ProgressView(value: Double(store.pet.needs.hunger)).tint(.green)
                ProgressView(value: Double(store.pet.needs.happiness)).tint(.yellow)
                ProgressView(value: Double(store.pet.needs.calm)).tint(.mint)
                ProgressView(value: Double(store.pet.needs.energy)).tint(.orange)
            }
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var actionBar: some View {
        HStack {
            Button("Medita") { appState.mood = .happy }
            Button("Cibo") { store.feed() }
            Button("Gioca") { store.play() }
            Button("Diario") { showJournal.toggle() }
        }
        .buttonStyle(.borderedProminent)
    }

    private func makeScene() -> SKScene {
        let scene = GardenScene(size: UIScreen.main.bounds.size)
        scene.scaleMode = .resizeFill
        scene.mood = appState.mood
        return scene
    }
}
