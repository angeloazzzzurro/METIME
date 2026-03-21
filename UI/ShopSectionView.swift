import SwiftUI

// MARK: - ShopSectionView
// Negozio: acquista cibo e oggetti per il pet.

struct ShopSectionView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var store: GameStore
    @Environment(\.dismiss) private var dismiss

    private let items: [(String, String, String)] = [
        ("🍎", "Mela Rossa",    "+Fame"),
        ("🍩", "Ciambella",     "+Felicità"),
        ("🌿", "Infuso Verde",  "+Calma"),
        ("⚡️", "Energy Drink", "+Energia"),
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.99, green: 0.97, blue: 0.88),
                         Color(red: 0.96, green: 0.88, blue: 0.68)],
                startPoint: .top, endPoint: .bottom
            ).ignoresSafeArea()

            VStack(spacing: 20) {
                sectionHeader(title: "🛒 Negozio", tint: Color(red: 0.80, green: 0.45, blue: 0.20))

                Text("Cibo disponibile: \(store.pet.food)")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                    ForEach(items, id: \.1) { emoji, name, effect in
                        ShopItemCard(emoji: emoji, name: name, effect: effect) {
                            store.feed()
                        }
                    }
                }
                .padding(.horizontal, 16)

                Spacer()
            }
        }
    }
}

// MARK: - ShopItemCard

private struct ShopItemCard: View {
    let emoji: String
    let name: String
    let effect: String
    let onBuy: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            Text(emoji).font(.system(size: 36))
            Text(name).font(.subheadline.weight(.semibold))
            Text(effect).font(.caption).foregroundStyle(.secondary)
            Button("Acquista") { onBuy() }
                .font(.caption.weight(.bold))
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(.orange, in: Capsule())
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(14)
        .background(.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
