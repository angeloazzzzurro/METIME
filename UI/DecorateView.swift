import SwiftUI

struct DecorateView: View {
    @EnvironmentObject private var gameStore: GameStore
    @EnvironmentObject private var houseStore: HouseStore
    @EnvironmentObject private var navigationState: NavigationState

    @State private var selectedCategory: ItemCategory = .decorations

    private var placeableItems: [OwnedItem] {
        houseStore.inventory.filter {
            guard let definition = $0.definition else { return false }
            return definition.isPlaceable && definition.category == selectedCategory && $0.quantity > 0
        }
    }

    private var visiblePlaceableItems: [(owned: OwnedItem, definition: HouseItemDefinition)] {
        placeableItems.compactMap { ownedItem in
            guard let definition = ownedItem.definition else { return nil }
            return (ownedItem, definition)
        }
    }

    var body: some View {
        ZStack {
            MTSectionBackground()
            .ignoresSafeArea()

            Group {
                if placeableItems.isEmpty {
                    EmptyStateView(
                        title: "Nessun arredo disponibile",
                        subtitle: "Compra oggetti posizionabili nello Store oppure cambia categoria.",
                        cta: "Vai allo Store"
                    ) {
                        navigationState.activeSection = .store
                    }
                    .padding(.top, 170)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(visiblePlaceableItems, id: \.owned.itemID) { item in
                                decorateCard(ownedItem: item.owned, definition: item.definition)
                                    .scrollTransition(.animated.threshold(.visible(0.9))) { content, phase in
                                        content
                                            .scaleEffect(phase.isIdentity ? 1 : 0.98)
                                            .opacity(phase.isIdentity ? 1 : 0.72)
                                    }
                            }
                        }
                        .padding(.horizontal, 18)
                        .padding(.top, 16)
                        .padding(.bottom, 28)
                    }
                    .scrollBounceBehavior(.basedOnSize)
                }
            }
            .animation(.snappy(duration: 0.24), value: selectedCategory)
        }
        .safeAreaInset(edge: .top) {
            decorateStickyHeader
        }
    }

    private var decorateStickyHeader: some View {
        VStack(spacing: 12) {
            MTSectionHeader(
                eyebrow: "Sezione",
                title: "Decora",
                subtitle: "Gestisci gli arredi già acquistati e la loro posizione.",
                badge: "\(houseStore.itemsPlacedInRoom().count) attivi",
                accent: Color(hex: "#8b6340"),
                icon: "wand.and.stars"
            )

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach([ItemCategory.essentials, .decorations, .specials], id: \.rawValue) { category in
                        MTFilterChip(
                            title: category.displayName,
                            iconText: category.emoji,
                            selected: selectedCategory == category,
                            tint: Color(hex: "#8b6340")
                        ) {
                            withAnimation(.snappy(duration: 0.2)) {
                                selectedCategory = category
                            }
                        }
                    }
                }
            }

            HStack(spacing: 12) {
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color(hex: "#d4884a"))
                    .frame(width: 38, height: 38)
                    .background(.white.opacity(0.92), in: Circle())

                VStack(alignment: .leading, spacing: 3) {
                    Text("Tocca per arredare")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(hex: "#3d2b1f"))
                    Text("Ogni arredo attivo dona un piccolo bonus di benessere al pet e cambia il mood della stanza.")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(hex: "#5e4636"))
                }

                Spacer()
            }
            .padding(14)
            .mtSectionCard(cornerRadius: 22)
        }
        .padding(.horizontal, 18)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background(
            MTSectionBackground()
        )
    }

    private func decorateCard(ownedItem: OwnedItem, definition: HouseItemDefinition) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(hex: rarityBackground(definition.rarity)))
                    .frame(width: 58, height: 58)
                Text(symbol(for: definition))
                    .font(.system(size: 26))
            }

            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(definition.name)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(hex: "#3d2b1f"))
                    Spacer()
                    Text(ownedItem.isPlacedInRoom ? "Attivo" : "Disponibile")
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundStyle(ownedItem.isPlacedInRoom ? Color(hex: "#3A8E6D") : Color(hex: "#8b6340"))
                }

                Text(definition.description)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(hex: "#8a7260"))
                    .lineLimit(2)

                Text(positionDescription(for: ownedItem))
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: "#8a7260"))
            }

            VStack(spacing: 8) {
                Button(ownedItem.isPlacedInRoom ? "Rimuovi" : "Posiziona") {
                    if ownedItem.isPlacedInRoom {
                        houseStore.removeFromRoom(item: ownedItem, on: gameStore)
                    } else {
                        houseStore.place(item: ownedItem, at: suggestedPosition(for: definition), on: gameStore)
                    }
                }
                .buttonStyle(InventoryActionButtonStyle(color: ownedItem.isPlacedInRoom ? Color(hex: "#F87171") : Color(hex: "#d4884a")))
            }
        }
        .padding(14)
        .mtSectionCard(cornerRadius: 22)
        .padding(.horizontal, 18)
    }

    private func suggestedPosition(for definition: HouseItemDefinition) -> CGPoint {
        switch definition.id {
        case "essential_bowl":    return CGPoint(x: -70, y: 12)
        case "essential_bed":     return CGPoint(x: 0, y: -22)
        case "essential_cushion": return CGPoint(x: 56, y: -6)
        case "essential_blanket": return CGPoint(x: 18, y: -28)
        case "deco_plant":        return CGPoint(x: 108, y: 42)
        case "deco_lamp":         return CGPoint(x: 112, y: 64)
        case "deco_rug":          return CGPoint(x: 0, y: -4)
        case "special_crystal":   return CGPoint(x: 76, y: 18)
        case "special_book":      return CGPoint(x: -94, y: 34)
        case "special_candle":    return CGPoint(x: -24, y: 40)
        default:                   return CGPoint(x: 0, y: 0)
        }
    }

    private func positionDescription(for ownedItem: OwnedItem) -> String {
        guard ownedItem.isPlacedInRoom,
              let x = ownedItem.roomPositionX,
              let y = ownedItem.roomPositionY else {
            return "Non ancora posizionato"
        }
        return "Posizione stanza: x \(Int(x)) · y \(Int(y))"
    }
}

private struct InventoryActionButtonStyle: ButtonStyle {
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(color.opacity(configuration.isPressed ? 0.75 : 1), in: Capsule())
    }
}

private struct EmptyStateView: View {
    let title: String
    let subtitle: String
    let cta: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text("✨")
                .font(.system(size: 42))
            Text(title)
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundStyle(Color(hex: "#5B4B8A"))
            Text(subtitle)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(Color(hex: "#8E84AF"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 26)
            Button(cta, action: action)
                .buttonStyle(InventoryActionButtonStyle(color: Color(hex: "#d4884a")))
        }
        .padding(24)
        .mtSectionCard(cornerRadius: 28)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private func symbol(for definition: HouseItemDefinition) -> String {
    switch definition.id {
    case "food_carrot":       return "🥕"
    case "food_cookie":       return "🍪"
    case "food_cake":         return "🍰"
    case "food_tea":          return "🫖"
    case "essential_bowl":    return "🥣"
    case "essential_bed":     return "🛏️"
    case "essential_cushion": return "🛋️"
    case "essential_blanket": return "🧸"
    case "deco_plant":        return "🪴"
    case "deco_lamp":         return "🌙"
    case "deco_rug":          return "🧶"
    case "special_crystal":   return "🔮"
    case "special_book":      return "📖"
    case "special_candle":    return "🕯️"
    default:                   return "✨"
    }
}

private func rarityBackground(_ rarity: ItemRarity) -> String {
    switch rarity {
    case .common:    return "#fdf3e3"
    case .rare:      return "#f0e6d3"
    case .legendary: return "#FFE6BE"
    }
}
