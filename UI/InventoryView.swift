import SwiftUI

struct InventoryView: View {
    @EnvironmentObject private var gameStore: GameStore
    @EnvironmentObject private var houseStore: HouseStore
    @EnvironmentObject private var navigationState: NavigationState

    @State private var selectedCategory: ItemCategory? = nil

    private var filteredItems: [OwnedItem] {
        let base = houseStore.inventory.filter { $0.quantity > 0 }
        guard let selectedCategory else { return base }
        return base.filter { $0.definition?.category == selectedCategory }
    }

    private var visibleInventoryItems: [(owned: OwnedItem, definition: HouseItemDefinition)] {
        filteredItems.compactMap { ownedItem in
            guard let definition = ownedItem.definition else { return nil }
            return (ownedItem, definition)
        }
    }

    var body: some View {
        ZStack {
            MTSectionBackground()
            .ignoresSafeArea()

            VStack(spacing: 16) {
                MTSectionHeader(
                    eyebrow: "Sezione",
                    title: "Zaino",
                    subtitle: "Usa consumabili o prepara gli oggetti da stanza.",
                    badge: "\(houseStore.inventory.reduce(0) { $0 + $1.quantity }) ogg.",
                    accent: Color(hex: "#8b6340"),
                    icon: "backpack.fill"
                )
                .padding(.horizontal, 18)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        inventoryFilter(title: "Tutti", emoji: "🎒", selected: selectedCategory == nil) {
                            selectedCategory = nil
                        }

                        ForEach(ItemCategory.allCases, id: \.rawValue) { category in
                            inventoryFilter(title: category.displayName, emoji: category.emoji, selected: selectedCategory == category) {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal, 18)
                }

                if filteredItems.isEmpty {
                    EmptyStateView(
                        title: "Zaino vuoto",
                        subtitle: "Compra oggetti nello Store per usarli o decorarci la stanza.",
                        cta: "Apri Store"
                    ) {
                        navigationState.activeSection = .store
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(visibleInventoryItems, id: \.owned.itemID) { item in
                                inventoryCard(ownedItem: item.owned, definition: item.definition)
                            }
                        }
                        .padding(.horizontal, 18)
                        .padding(.bottom, 24)
                    }
                }
            }
            .padding(.top, 12)
        }
    }

    private func inventoryFilter(title: String, emoji: String, selected: Bool, action: @escaping () -> Void) -> some View {
        MTFilterChip(title: title, iconText: emoji, selected: selected, tint: Color(hex: "#8b6340"), action: action)
    }

    private func inventoryCard(ownedItem: OwnedItem, definition: HouseItemDefinition) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(hex: rarityBackground(definition.rarity)))
                    .frame(width: 58, height: 58)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.white.opacity(0.55), lineWidth: 1)
                    )
                Text(symbol(for: definition))
                    .font(.system(size: 24))
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(definition.name)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(hex: "#3d2b1f"))
                    Spacer()
                    Text("x\(ownedItem.quantity)")
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundStyle(Color(hex: "#5e4636"))
                }

                Text(definition.description)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(hex: "#8a7260"))
                    .lineLimit(2)

                HStack(spacing: 8) {
                    badge(text: definition.category.displayName, tint: Color(hex: "#c9a96e"))
                    if ownedItem.isPlacedInRoom {
                        badge(text: "In stanza", tint: Color(hex: "#8FD5B6"))
                    } else if definition.isConsumable {
                        badge(text: "Consumabile", tint: Color(hex: "#F7B0A8"))
                    } else if definition.isPlaceable {
                        badge(text: "Posizionabile", tint: Color(hex: "#a8c9a0"))
                    }
                }
            }

            VStack(spacing: 8) {
                if definition.isConsumable {
                    Button("Usa") {
                        _ = houseStore.useItem(ownedItem, on: gameStore)
                    }
                    .buttonStyle(InventoryActionButtonStyle(color: Color(hex: "#a8c9a0")))
                }

                if definition.isPlaceable {
                    Button(ownedItem.isPlacedInRoom ? "Sposta" : "Decora") {
                        navigationState.activeSection = .decorate
                    }
                    .buttonStyle(InventoryActionButtonStyle(color: Color(hex: "#d4884a")))
                }
            }
        }
        .padding(14)
        .mtSectionCard(cornerRadius: 22)
        .padding(.horizontal, 18)
    }

    private func badge(text: String, tint: Color) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .foregroundStyle(Color(hex: "#5e4636"))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(tint.opacity(0.35), in: Capsule())
    }
}
