import SwiftUI
import SpriteKit

// MARK: - HouseView

struct HouseView: View {

    @EnvironmentObject var gameStore: GameStore
    @EnvironmentObject var houseStore: HouseStore

    @State private var scene: HouseScene = {
        let s = HouseScene()
        s.size = CGSize(width: 390, height: 340)
        s.scaleMode = .aspectFill
        return s
    }()

    @State private var showStore = false
    @State private var showInventory = false
    @State private var selectedItem: OwnedItem? = nil
    @State private var showUseConfirm = false
    @EnvironmentObject private var navigationState: NavigationState

    var body: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.92, blue: 0.96),
                    Color(red: 0.92, green: 0.88, blue: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            backgroundDecorations

            switch navigationState.activeSection {
            case .home:
                VStack(spacing: 0) {
                    topBar
                    GeometryReader { geo in
                        SpriteView(scene: scene, options: [.allowsTransparency])
                            .frame(width: geo.size.width, height: geo.size.height)
                            .onAppear {
                                scene.size = CGSize(width: geo.size.width, height: geo.size.height)
                            }
                    }
                    .frame(height: 320)
                    .onChange(of: gameStore.pet.moodRaw) { _, newVal in
                        if let mood = PetMood(rawValue: newVal) {
                            scene.mood = mood
                        }
                    }
                    .onChange(of: houseStore.itemsPlacedInRoom()) { _, placed in
                        scene.placedItems = placed.compactMap { item in
                            guard let x = item.roomPositionX,
                                  let y = item.roomPositionY else { return nil }
                            return (itemID: item.itemID, position: CGPoint(x: x, y: y))
                        }
                    }
                    actionBar
                    Spacer()
                }
            case .garden:
                GardenSectionView()
                    .environmentObject(gameStore)
                    .environmentObject(houseStore)
            case .store:
                ShopSectionView()
                    .environmentObject(gameStore)
                    .environmentObject(houseStore)
            case .inventory:
                Text("Zaino")
                    .font(.largeTitle)
                    .foregroundColor(Color(hex: "#60A5FA"))
                    .padding()
            case .decorate:
                Text("Decora")
                    .font(.largeTitle)
                    .foregroundColor(Color(hex: "#A78BFA"))
                    .padding()
            case .meTime:
                NavigationStack {
                    CareRitualMockupView()
                }
            }

            VStack(spacing: 12) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        HomePetNavButton(icon: "bag.fill", label: "Store", color: Color(hex: "#F87171")) {
                            navigationState.activeSection = .store
                        }
                        HomePetNavButton(icon: "backpack.fill", label: "Zaino", color: Color(hex: "#60A5FA")) {
                            navigationState.activeSection = .inventory
                        }
                        HomePetNavButton(icon: "wand.and.stars", label: "Decora", color: Color(hex: "#A78BFA")) {
                            navigationState.activeSection = .decorate
                        }
                        HomePetNavButton(icon: "sparkles.rectangle.stack.fill", label: "Me Time", color: Color(hex: "#F59E0B")) {
                            navigationState.activeSection = .meTime
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 8)
                }
                .background(Color.white)
                .cornerRadius(24)
                .shadow(color: Color.black.opacity(0.08), radius: 8, y: 2)

                HStack(spacing: 0) {
                    HomePetTabButton(icon: "leaf", label: "Giardino", selected: navigationState.activeSection == .garden) {
                        navigationState.activeSection = .garden
                    }
                    HomePetTabButton(icon: "house.fill", label: "Casa", selected: navigationState.activeSection == .home) {
                        navigationState.activeSection = .home
                    }
                }
                .frame(height: 56)
                .background(Color.white)
                .cornerRadius(18)
                .shadow(color: Color.black.opacity(0.06), radius: 6, y: 1)
                .padding(.horizontal, 32)
                .padding(.bottom, 8)
            }
        }
        .sheet(isPresented: $showStore) {
            StoreSheetView()
                .environmentObject(houseStore)
                .environmentObject(gameStore)
        }
        .sheet(isPresented: $showInventory) {
            InventorySheetView(selectedItem: $selectedItem, showUseConfirm: $showUseConfirm)
                .environmentObject(houseStore)
                .environmentObject(gameStore)
        }
        .confirmationDialog(
            "Usare \(selectedItem?.definition?.name ?? "oggetto")?",
            isPresented: $showUseConfirm,
            titleVisibility: .visible
        ) {
            Button("Usa") {
                if let item = selectedItem {
                    _ = houseStore.useItem(item, on: gameStore)
                }
            }
            Button("Annulla", role: .cancel) {}
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            // Titolo
            Text("🏠 La tua Casa")
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.6))

            Spacer()

            // Wallet
            HStack(spacing: 12) {
                walletBadge(icon: "🪙", value: houseStore.wallet.coins, color: Color(red: 1.0, green: 0.75, blue: 0.2))
                walletBadge(icon: "💎", value: houseStore.wallet.gems, color: Color(red: 0.5, green: 0.3, blue: 0.9))
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    private func walletBadge(icon: String, value: Int, color: Color) -> some View {
        HStack(spacing: 4) {
            Text(icon)
                .font(.system(size: 16))
            Text("\(value)")
                .font(.system(size: 16, weight: .black, design: .rounded))
                .foregroundColor(color)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.7))
        .clipShape(Capsule())
    }

    // MARK: - Action Bar

    private var actionBar: some View {
        HStack(spacing: 16) {
            actionButton(icon: "🛍️", label: "Store", color: Color(red: 0.9, green: 0.4, blue: 0.6)) {
                showStore = true
            }
            actionButton(icon: "🎒", label: "Zaino", color: Color(red: 0.4, green: 0.6, blue: 0.9)) {
                showInventory = true
            }
            actionButton(icon: "✨", label: "Decora", color: Color(red: 0.6, green: 0.4, blue: 0.9)) {
                // TODO: modalità posizionamento oggetti
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }

    private func actionButton(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(icon)
                    .font(.system(size: 28))
                Text(label)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(color)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.white.opacity(0.75))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: color.opacity(0.2), radius: 6, x: 0, y: 3)
        }
    }

    // MARK: - Background Decorations

    private var backgroundDecorations: some View {
        ZStack {
            ForEach(Array(zip(
                ["⭐", "💫", "🌸", "✨", "🌟", "💕", "🌙"],
                [
                    CGPoint(x: 30, y: 80),
                    CGPoint(x: 340, y: 60),
                    CGPoint(x: 60, y: 200),
                    CGPoint(x: 320, y: 180),
                    CGPoint(x: 20, y: 350),
                    CGPoint(x: 360, y: 320),
                    CGPoint(x: 180, y: 50)
                ]
            )), id: \.0) { emoji, pos in
                Text(emoji)
                    .font(.system(size: 18))
                    .opacity(0.25)
                    .position(pos)
            }
        }
    }
}

// MARK: - House Navigation Buttons

private struct HomePetNavButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(10)
                    .background(color)
                    .clipShape(Capsule())
                Text(label)
                    .font(.headline.weight(.semibold))
                    .foregroundColor(color)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .background(color.opacity(0.12))
            .cornerRadius(18)
        }
        .buttonStyle(.plain)
    }
}

private struct HomePetTabButton: View {
    let icon: String
    let label: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(selected ? Color(hex: "#A78BFA") : Color.gray.opacity(0.6))
                Text(label)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(selected ? Color(hex: "#A78BFA") : Color.gray.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - StoreSheetView

struct StoreSheetView: View {

    @EnvironmentObject var houseStore: HouseStore
    @EnvironmentObject var gameStore: GameStore
    @Environment(\.dismiss) var dismiss

    @State private var selectedCategory: ItemCategory = .food
    @State private var purchaseMessage: String? = nil
    @State private var showGemPacks = false

    var filteredItems: [HouseItemDefinition] {
        HouseItemDefinition.catalog.filter { $0.category == selectedCategory }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                storeBackground.ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        heroSection

                        LazyVGrid(
                            columns: [
                                GridItem(.flexible(), spacing: 18),
                                GridItem(.flexible(), spacing: 18)
                            ],
                            spacing: 22
                        ) {
                            ForEach(filteredItems, id: \.id) { item in
                                StoreItemCard(item: item) {
                                    handlePurchase(item: item)
                                }
                                .environmentObject(houseStore)
                            }
                        }
                        .padding(.horizontal, 22)
                        .padding(.bottom, 34)
                    }
                    .padding(.top, 10)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showGemPacks) {
                GemPackSheetView().environmentObject(houseStore)
            }
        }
    }

    private var storeBackground: some View {
        ZStack {
            Color(hex: "#E8D5F5")

            Circle()
                .fill(Color.white.opacity(0.28))
                .frame(width: 230, height: 230)
                .offset(x: -150, y: -300)

            Circle()
                .fill(Color(hex: "#D9C1F0").opacity(0.55))
                .frame(width: 280, height: 280)
                .offset(x: 140, y: -330)

            Circle()
                .fill(Color.white.opacity(0.22))
                .frame(width: 240, height: 240)
                .offset(x: 150, y: 340)
        }
    }

    private var heroSection: some View {
        VStack(spacing: 16) {
            headerBar
            currencyBar
            if let msg = purchaseMessage {
                feedbackBanner(msg)
            }
            categoryPicker
        }
        .padding(.horizontal, 16)
        .padding(.top, 18)
        .padding(.bottom, 24)
        .background(
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(Color(hex: "#DCC6F0").opacity(0.78))
        )
        .overlay(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(Color.white.opacity(0.38))
                .frame(height: 1)
        }
        .shadow(color: Color(hex: "#9D77D8").opacity(0.14), radius: 22, y: 10)
    }

    private var headerBar: some View {
        HStack(spacing: 10) {
            headerPill(
                title: "💎 Acquista Gemme",
                foreground: .white,
                background: Color(hex: "#7D59C5"),
                border: .clear
            ) {
                showGemPacks = true
            }

            Spacer(minLength: 8)

            Text("🛍️")
                .font(.system(size: 23))
            Text("Store")
                .font(.system(size: 29, weight: .heavy, design: .rounded))
                .foregroundStyle(Color.white)
                .shadow(color: Color(hex: "#8967CF").opacity(0.7), radius: 0, x: 0, y: 1.4)

            Spacer(minLength: 8)

            headerPill(
                title: "Chiudi",
                foreground: Color(hex: "#7D59C5"),
                background: Color.white.opacity(0.98),
                border: Color(hex: "#D2B8EC")
            ) {
                dismiss()
            }
        }
    }

    private func headerPill(
        title: String,
        foreground: Color,
        background: Color,
        border: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .black, design: .rounded))
                .foregroundStyle(foreground)
                .padding(.horizontal, 15)
                .padding(.vertical, 10)
                .background(background)
                .overlay {
                    Capsule().stroke(border, lineWidth: 1.4)
                }
                .clipShape(Capsule())
                .shadow(color: Color(hex: "#9C78D8").opacity(0.18), radius: 10, y: 5)
        }
        .buttonStyle(.plain)
    }

    private var currencyBar: some View {
        HStack(spacing: 0) {
            currencyChip(
                icon: "🪙",
                value: houseStore.wallet.coins,
                accent: Color(hex: "#F0B24D")
            )

            Rectangle()
                .fill(Color(hex: "#E7D8F3"))
                .frame(width: 1, height: 28)
                .padding(.horizontal, 8)

            currencyChip(
                icon: "💎",
                value: houseStore.wallet.gems,
                accent: Color(hex: "#8B5CF6")
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color.white.opacity(0.98))
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color(hex: "#D8C1F0"), lineWidth: 1.5)
        }
        .shadow(color: Color(hex: "#9C78D8").opacity(0.16), radius: 12, y: 6)
    }

    private func currencyChip(icon: String, value: Int, accent: Color) -> some View {
        HStack(spacing: 8) {
            Text(icon)
                .font(.system(size: 22))
            Text("\(value)")
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundStyle(accent)
        }
    }

    private func feedbackBanner(_ msg: String) -> some View {
        Text(msg)
            .font(.system(size: 12, weight: .bold, design: .rounded))
            .foregroundStyle(Color(hex: "#6F52A9"))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(Color.white.opacity(0.94))
            .clipShape(Capsule())
            .overlay {
                Capsule()
                    .stroke(Color(hex: "#D8C2F1"), lineWidth: 1)
            }
            .transition(.opacity.combined(with: .scale))
    }

    // MARK: - Category Picker

    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(ItemCategory.allCases, id: \.self) { cat in
                    Button {
                        withAnimation(.spring(response: 0.26, dampingFraction: 0.85)) {
                            selectedCategory = cat
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text(cat.emoji)
                            Text(cat.displayName)
                                .font(.system(size: 13, weight: .heavy, design: .rounded))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            selectedCategory == cat
                                ? Color(hex: "#8B67D6")
                                : Color.white.opacity(0.96)
                        )
                        .foregroundStyle(
                            selectedCategory == cat
                                ? Color.white
                                : Color(hex: "#6B4E98")
                        )
                        .overlay {
                            Capsule()
                                .stroke(
                                    selectedCategory == cat
                                        ? Color.clear
                                        : Color(hex: "#D3BCEC"),
                                    lineWidth: 1
                                )
                        }
                        .clipShape(Capsule())
                        .shadow(
                            color: selectedCategory == cat
                                ? Color(hex: "#6C44B6").opacity(0.22)
                                : Color(hex: "#A889D8").opacity(0.08),
                            radius: 8,
                            y: 4
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
        }
    }

    // MARK: - Purchase Logic

    private func handlePurchase(item: HouseItemDefinition) {
        if item.currency == .coins {
            let result = houseStore.purchase(item: item)
            switch result {
            case .success:
                showFeedback("✅ \(item.name) acquistato!")
                houseStore.rewardCoins(0) // trigger UI update
            case .insufficientFunds(let needed, _):
                showFeedback("❌ Servono \(needed) monete")
            default:
                break
            }
        } else {
            Task {
                let result = await houseStore.purchaseWithStoreKit(item: item)
                switch result {
                case .success:
                    showFeedback("✅ \(item.name) acquistato!")
                case .storeKitFailed(let err):
                    showFeedback("❌ \(err.localizedDescription)")
                default:
                    break
                }
            }
        }
    }

    private func showFeedback(_ message: String) {
        withAnimation { purchaseMessage = message }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation { purchaseMessage = nil }
        }
    }
}

// MARK: - StoreItemCard

struct StoreItemCard: View {
    @EnvironmentObject var houseStore: HouseStore
    let item: HouseItemDefinition
    let onBuy: () -> Void

    var isOwned: Bool { houseStore.owns(itemID: item.id) }
    var qty: Int { houseStore.quantity(of: item.id) }

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 6) {
                Text(titleEmoji)
                    .font(.system(size: 14))
                Text(item.name.replacingOccurrences(of: " Magica", with: ""))
                    .font(.system(size: 16, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color(hex: "#4A345D"))
                    .lineLimit(1)
                Spacer()
                if qty > 1 {
                    Text("x\(qty)")
                        .font(.system(size: 9, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 4)
                        .background(Color(hex: "#8B67D6"))
                        .clipShape(Capsule())
                }
                rarityBadge
            }
            .padding(.top, 14)
            .padding(.horizontal, 14)

            Text(centerEmoji)
                .font(.system(size: 60))
                .frame(maxWidth: .infinity)
                .padding(.top, 16)
                .padding(.bottom, 12)

            Text(shortDescription)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(Color(hex: "#5D4A57"))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 18)
                .frame(minHeight: 44)

            effectsBadges
                .padding(.top, 10)

            Spacer(minLength: 12)

            HStack(alignment: .center) {
                Text(priceText)
                    .font(.system(size: 17, weight: .heavy, design: .rounded))
                    .foregroundStyle(priceColor)

                Spacer(minLength: 8)

                Button(action: onBuy) {
                    Text(isOwned && !item.isConsumable ? "Tuo" : "Acquista 🛒")
                        .font(.system(size: 11.5, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 13)
                        .padding(.vertical, 8)
                        .background(isOwned && !item.isConsumable ? Color(hex: "#C3B5DC") : Color(hex: "#8B67D6"))
                        .clipShape(Capsule())
                        .shadow(color: Color(hex: "#8B67D6").opacity(0.22), radius: 6, y: 3)
                }
                .buttonStyle(.plain)
                .disabled(isOwned && !item.isConsumable)
                .opacity(isOwned && !item.isConsumable ? 0.9 : 1)
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 14)
        }
        .frame(maxWidth: .infinity, minHeight: 258)
        .background(Color.white.opacity(0.97))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color(hex: "#CDAEF0"), lineWidth: 1.6)
        }
        .shadow(color: Color(hex: "#A980E2").opacity(0.24), radius: 12, y: 6)
    }

    private var effectsBadges: some View {
        HStack(spacing: 6) {
            if item.hungerBoost > 0    { effectBadge("🍽️", item.hungerBoost) }
            if item.happinessBoost > 0 { effectBadge("😊", item.happinessBoost) }
            if item.calmBoost > 0      { effectBadge("🌿", item.calmBoost) }
            if item.energyBoost > 0    { effectBadge("⚡", item.energyBoost) }
        }
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func effectBadge(_ icon: String, _ value: Double) -> some View {
        HStack(spacing: 4) {
            Text("+\(Int(value * 100))%")
            Text(icon)
        }
        .font(.system(size: 10, weight: .bold, design: .rounded))
        .foregroundStyle(effectColor(icon))
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(effectBackground(icon))
        .clipShape(Capsule())
    }

    private var priceText: String {
        item.currency == .coins ? "🪙 \(item.price)" : "💎 \(item.price)"
    }

    private var priceColor: Color {
        item.currency == .coins ? Color(hex: "#D18B00") : Color(hex: "#7C3AED")
    }

    private var purchaseLabel: String {
        item.currency == .coins ? "Acquista" : "Sblocca"
    }

    private var titleEmoji: String {
        switch item.id {
        case "food_carrot": return "🥕"
        case "food_cookie": return "🍪"
        case "food_cake": return "🎂"
        case "food_tea": return "🍵"
        default: return emojiFor(item)
        }
    }

    private var centerEmoji: String {
        emojiFor(item)
    }

    private var shortDescription: String {
        switch item.id {
        case "food_carrot":
            return "Un gustoso spuntino salutare."
        case "food_cookie":
            return "Perfetto per una pausa dolce."
        case "food_cake":
            return "Una festa per il palato!"
        case "food_tea":
            return "Rilassante e rigenerante."
        default:
            return item.description
        }
    }

    @ViewBuilder
    private var rarityBadge: some View {
        switch item.rarity {
        case .common:
            EmptyView()
        case .rare:
            Text("💜 Raro")
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(Color(hex: "#8B67D6"))
                .clipShape(Capsule())
        case .legendary:
            Text("⭐ Leggendario")
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(Color(hex: "#F2A93B"))
                .clipShape(Capsule())
        }
    }

    private func effectBackground(_ icon: String) -> Color {
        if icon == "😊" {
            return Color(hex: "#FDE1E8")
        }
        return Color(hex: "#E7F4D7")
    }

    private func effectColor(_ icon: String) -> Color {
        if icon == "😊" {
            return Color(hex: "#D65D7A")
        }
        return Color(hex: "#5D9652")
    }

    private func emojiFor(_ def: HouseItemDefinition) -> String {
        switch def.id {
        case "food_carrot":       return "🥕"
        case "food_cookie":       return "🍪"
        case "food_cake":         return "🎂"
        case "food_tea":          return "🍵"
        case "essential_bowl":    return "🥣"
        case "essential_cushion": return "🛋️"
        case "essential_blanket": return "🛏️"
        case "deco_plant":        return "🪴"
        case "deco_lamp":         return "🌙"
        case "deco_rug":          return "🪄"
        case "special_crystal":   return "💎"
        case "special_book":      return "📖"
        case "special_candle":    return "🕯️"
        default:                  return "📦"
        }
    }
}

// MARK: - InventorySheetView

struct InventorySheetView: View {
    @EnvironmentObject var houseStore: HouseStore
    @EnvironmentObject var gameStore: GameStore
    @Environment(\.dismiss) var dismiss
    @Binding var selectedItem: OwnedItem?
    @Binding var showUseConfirm: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.97, green: 0.94, blue: 1.0).ignoresSafeArea()
                if houseStore.inventory.isEmpty {
                    VStack(spacing: 16) {
                        Text("🎒")
                            .font(.system(size: 64))
                        Text("Il tuo zaino è vuoto!\nVai allo store per acquistare oggetti.")
                            .font(.system(size: 16, design: .rounded))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(houseStore.inventory, id: \.itemID) { item in
                                if let def = item.definition {
                                    Button {
                                        selectedItem = item
                                        showUseConfirm = true
                                        dismiss()
                                    } label: {
                                        VStack(spacing: 6) {
                                            Text(emojiFor(def))
                                                .font(.system(size: 36))
                                            Text(def.name)
                                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                                .foregroundColor(Color(red: 0.3, green: 0.1, blue: 0.5))
                                                .lineLimit(2)
                                                .multilineTextAlignment(.center)
                                            if item.quantity > 1 {
                                                Text("x\(item.quantity)")
                                                    .font(.system(size: 11, weight: .black, design: .rounded))
                                                    .foregroundColor(.white)
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 2)
                                                    .background(Color(red: 0.6, green: 0.3, blue: 0.9))
                                                    .clipShape(Capsule())
                                            }
                                        }
                                        .padding(10)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.white.opacity(0.8))
                                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                    }
                                }
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .navigationTitle("🎒 Il mio Zaino")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Chiudi") { dismiss() }
                }
            }
        }
    }

    private func emojiFor(_ def: HouseItemDefinition) -> String {
        switch def.id {
        case "food_carrot":       return "🥕"
        case "food_cookie":       return "🍪"
        case "food_cake":         return "🎂"
        case "food_tea":          return "🍵"
        case "essential_bowl":    return "🥣"
        case "essential_cushion": return "🛋️"
        case "essential_blanket": return "🛏️"
        case "deco_plant":        return "🪴"
        case "deco_lamp":         return "🌙"
        case "deco_rug":          return "🪄"
        case "special_crystal":   return "💎"
        case "special_book":      return "📖"
        case "special_candle":    return "🕯️"
        default:                  return "📦"
        }
    }
}

// MARK: - GemPackSheetView

struct GemPackSheetView: View {
    @EnvironmentObject var houseStore: HouseStore
    @Environment(\.dismiss) var dismiss
    @State private var purchaseMessage: String? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                ZStack {
                    Color(hex: "#E8D5F5")

                    Circle()
                        .fill(Color.white.opacity(0.26))
                        .frame(width: 230, height: 230)
                        .offset(x: -150, y: -300)

                    Circle()
                        .fill(Color(hex: "#D9C1F0").opacity(0.55))
                        .frame(width: 260, height: 260)
                        .offset(x: 140, y: -300)
                }
                .ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 18) {
                        VStack(spacing: 16) {
                            HStack {
                                Text("💎 Gemme")
                                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                                    .foregroundStyle(Color.white)
                                    .shadow(color: Color(hex: "#8967CF").opacity(0.7), radius: 0, x: 0, y: 1.4)

                                Spacer()

                                Button("Chiudi") { dismiss() }
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color(hex: "#7D59C5"))
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 10)
                                    .background(Color.white.opacity(0.96))
                                    .overlay {
                                        Capsule().stroke(Color(hex: "#D2B8EC"), lineWidth: 1.4)
                                    }
                                    .clipShape(Capsule())
                            }

                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Acquista Gemme")
                                        .font(.system(size: 21, weight: .heavy, design: .rounded))
                                        .foregroundStyle(Color(hex: "#53357E"))
                                    Text("Pacchetti premium per sbloccare item rari e leggendari.")
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .foregroundStyle(Color(hex: "#8668B2"))
                                        .fixedSize(horizontal: false, vertical: true)
                                }

                                Spacer()

                                Text("💎")
                                    .font(.system(size: 42))
                            }
                            .padding(16)
                            .background(Color.white.opacity(0.96))
                            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                            .overlay {
                                RoundedRectangle(cornerRadius: 26, style: .continuous)
                                    .stroke(Color(hex: "#D8C1F0"), lineWidth: 1.5)
                            }
                            .shadow(color: Color(hex: "#9C78D8").opacity(0.16), radius: 12, y: 6)

                            if let msg = purchaseMessage {
                                Text(msg)
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color(hex: "#6F52A9"))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.white.opacity(0.94))
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 18)
                        .padding(.bottom, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 34, style: .continuous)
                                .fill(Color(hex: "#DCC6F0").opacity(0.78))
                        )
                        .padding(.horizontal, 16)

                        VStack(spacing: 14) {
                            ForEach(GemPack.all) { pack in
                                gemPackRow(pack)
                            }
                        }
                        .padding(.horizontal, 22)
                        .padding(.bottom, 28)
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private func gemPackRow(_ pack: GemPack) -> some View {
        let product = houseStore.storeKitProducts.first { $0.id == pack.id }

        return HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color(hex: "#F5EDFF"))
                    .frame(width: 58, height: 58)
                Text("💎")
                    .font(.system(size: 28))
            }

            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 6) {
                    Text("\(pack.gems) Gemme")
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color(hex: "#4A345D"))
                    if let bonus = pack.bonusLabel {
                        Text(bonus)
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(hex: "#8B67D6"))
                            .clipShape(Capsule())
                    }
                }
                if let product {
                    Text(product.displayPrice)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(Color(hex: "#8668B2"))
                } else {
                    Text("Caricamento...")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(Color(hex: "#B09ACF"))
                }
            }

            Spacer()

            Button {
                Task { await buyGemPack(pack) }
            } label: {
                Text(product?.displayPrice ?? "—")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(hex: "#8B67D6"))
                    .clipShape(Capsule())
                    .shadow(color: Color(hex: "#8B67D6").opacity(0.22), radius: 6, y: 3)
            }
            .buttonStyle(.plain)
            .disabled(product == nil || houseStore.isPurchasing)
            .opacity((product == nil || houseStore.isPurchasing) ? 0.7 : 1)
        }
        .padding(16)
        .background(Color.white.opacity(0.97))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color(hex: "#CDAEF0"), lineWidth: 1.6)
        }
        .shadow(color: Color(hex: "#A980E2").opacity(0.22), radius: 12, y: 6)
    }

    private func buyGemPack(_ pack: GemPack) async {
        let result = await houseStore.purchaseGemPack(pack)
        switch result {
        case .success:
            withAnimation { purchaseMessage = "✅ \(pack.gems) gemme aggiunte!" }
        case .storeKitFailed(let err):
            withAnimation { purchaseMessage = "❌ \(err.localizedDescription)" }
        default:
            break
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation { purchaseMessage = nil }
        }
    }
}
