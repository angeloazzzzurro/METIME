import SwiftUI

// MainPetView mostra la mappa isola navigabile come schermata principale.
// La navigazione verso Giardino / Casa / Mare / Negozio avviene
// toccando le zone nella scena SpriteKit di IslandMapView.
struct MainPetView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var store: GameStore

    var body: some View {
        IslandMapView()
            .onChange(of: appState.mood) { _, mood in
                SoundscapeManager.shared.transition(to: mood)
            }
    }
}
