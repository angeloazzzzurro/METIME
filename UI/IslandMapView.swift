import SwiftUI
import SpriteKit

// MARK: - IslandMapView
// Mappa isola intera con navigazione verso le 4 sezioni.

struct IslandMapView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var store: GameStore

    @State private var destination: IslandZone?
    @State private var showJournal = false

    @State private var scene: IslandMapScene = {
        let s = IslandMapScene(size: UIScreen.main.bounds.size)
        s.scaleMode = .resizeFill
        return s
    }()

    var body: some View {
        ZStack(alignment: .top) {
            // ── Scena SpriteKit ────────────────────────────────────────────
            SpriteView(scene: scene, options: [.allowsTransparency])
                .ignoresSafeArea()
                .onAppear {
                    scene.onZoneTapped = { zone in
                        destination = zone
                    }
                }

            // ── HUD top ────────────────────────────────────────────────────
            topHUD
                .padding(.top, 54)
                .padding(.horizontal, 16)
        }
        // ── Navigazione verso ogni sezione ─────────────────────────────────
        .fullScreenCover(item: $destination) { zone in
            destinationView(for: zone)
        }
    }

    // MARK: – HUD

    private var topHUD: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(store.pet.name)
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.bold)
                    Text(appState.mood.rawValue.capitalized)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                stageEmoji
            }

            HStack(spacing: 6) {
                NeedBar(value: Double(store.pet.needs.hunger),    icon: "🍃", tint: .green)
                NeedBar(value: Double(store.pet.needs.happiness), icon: "☀️", tint: .yellow)
                NeedBar(value: Double(store.pet.needs.calm),      icon: "🫧", tint: .mint)
                NeedBar(value: Double(store.pet.needs.energy),    icon: "⚡️", tint: .orange)
            }
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
    }

    private var stageEmoji: some View {
        let emojis = ["🥚", "🌱", "🌸", "✨", "👑"]
        let idx = max(0, min(store.pet.stage, emojis.count - 1))
        return Text(emojis[idx])
            .font(.system(size: 30))
    }

    // MARK: – Destination router

    @ViewBuilder
    private func destinationView(for zone: IslandZone) -> some View {
        switch zone {
        case .garden:
            GardenSectionView()
                .environmentObject(appState)
                .environmentObject(store)
        case .house:
            HouseSectionView()
                .environmentObject(appState)
                .environmentObject(store)
        case .sea:
            SeaSectionView()
                .environmentObject(appState)
                .environmentObject(store)
        case .shop:
            ShopSectionView()
                .environmentObject(appState)
                .environmentObject(store)
        }
    }
}

// MARK: - IslandZone: Identifiable
// Necessario per fullScreenCover(item:)

extension IslandZone: Identifiable {
    var id: String { rawValue }
}

// MARK: - NeedBar

private struct NeedBar: View {
    let value: Double
    let icon: String
    let tint: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(icon).font(.caption2)
            GeometryReader { geo in
                RoundedRectangle(cornerRadius: 3)
                    .fill(tint.opacity(0.25))
                    .overlay(alignment: .bottom) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(tint)
                            .frame(height: geo.size.height * value)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 3))
            }
            .frame(width: 8, height: 28)
        }
    }
}
