import SwiftUI
import SpriteKit

struct MainPetView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var store: GameStore

    @State private var showJournal = false

    // La scena viene creata una sola volta e mantenuta stabile.
    // Usare @StateObject-like pattern con @State + classe evita che
    // makeScene() venga ri-chiamata ad ogni re-render, il che causerebbe
    // un loop di rendering che blocca l'UI.
    @State private var scene: GardenScene = {
        let s = GardenScene(size: UIScreen.main.bounds.size)
        s.scaleMode = .resizeFill
        return s
    }()

    var body: some View {
        ZStack(alignment: .bottom) {
            SceneView(scene: scene, options: [.allowsTransparency])
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
        .onAppear {
            scene.mood = appState.mood
        }
        .onChange(of: appState.mood) { _, mood in
            scene.mood = mood
            SoundscapeManager.shared.transition(to: mood)
        }
    }

    // MARK: - HUD

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

    // MARK: - Action Bar

    private var actionBar: some View {
        HStack {
            Button("Medita") {
                appState.mood = .happy
                store.meditate()
            }
            Button("Cibo")   { store.feed() }
            Button("Gioca")  { store.play() }
            Button("Diario") { showJournal.toggle() }
        }
        .buttonStyle(.borderedProminent)
    }
}
