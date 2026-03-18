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

    var body: some View {
        ZStack {
            // Sfondo gradiente kawaii
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.92, blue: 0.96),
                    Color(red: 0.92, green: 0.88, blue: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Decorazioni sfondo
            backgroundDecorations

            VStack(spacing: 0) {
                // MARK: Top Bar
                topBar

                // MARK: Stanza isometrica
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

                // MARK: Action Bar
                actionBar

                Spacer()
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
                LinearGradient(
                    colors: [Color(red: 0.98, green: 0.94, blue: 1.0), Color(red: 0.94, green: 0.90, blue: 1.0)],
                    startPoint: .top, endPoint: .bottom
                ).ignoresSafeArea()

                VStack(spacing: 0) {
                    // Wallet header
                    walletHeader

                    // Messaggio feedback acquisto
                    if let msg = purchaseMessage {
                        Text(msg)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color(red: 0.4, green: 0.7, blue: 0.4))
                            .clipShape(Capsule())
                            .padding(.top, 8)
                            .transition(.opacity)
                    }

                    // Filtro categorie
                    categoryPicker

                    // Griglia oggetti
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(filteredItems, id: \.id) { item in
                                StoreItemCard(item: item) {
                                    handlePurchase(item: item)
                                }
                                .environmentObject(houseStore)
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .navigationTitle("🛍️ Store")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("💎 Acquista Gemme") { showGemPacks = true }
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.5, green: 0.3, blue: 0.9))
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Chiudi") { dismiss() }
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                }
            }
            .sheet(isPresented: $showGemPacks) {
                GemPackSheetView().environmentObject(houseStore)
            }
        }
    }

    // MARK: - Wallet Header

    private var walletHeader: some View {
        HStack(spacing: 20) {
            Label("\(houseStore.wallet.coins)", systemImage: "circle.fill")
                .symbolRenderingMode(.palette)
                .foregroundStyle(Color(red: 1.0, green: 0.75, blue: 0.2), .clear)
                .font(.system(size: 18, weight: .black, design: .rounded))
            Label("\(houseStore.wallet.gems)", systemImage: "diamond.fill")
                .symbolRenderingMode(.palette)
                .foregroundStyle(Color(red: 0.5, green: 0.3, blue: 0.9), .clear)
                .font(.system(size: 18, weight: .black, design: .rounded))
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 24)
        .background(Color.white.opacity(0.7))
        .clipShape(Capsule())
        .padding(.top, 12)
    }

    // MARK: - Category Picker

    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(ItemCategory.allCases, id: \.self) { cat in
                    Button {
                        selectedCategory = cat
                    } label: {
                        HStack(spacing: 6) {
                            Text(cat.emoji)
                            Text(cat.displayName)
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(selectedCategory == cat
                            ? Color(red: 0.6, green: 0.3, blue: 0.9)
                            : Color.white.opacity(0.6))
                        .foregroundColor(selectedCategory == cat ? .white : Color(red: 0.4, green: 0.2, blue: 0.6))
                        .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
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
        VStack(spacing: 10) {
            // Icona emoji grande
            Text(emojiFor(item))
                .font(.system(size: 48))

            // Nome
            Text(item.name)
                .font(.system(size: 14, weight: .black, design: .rounded))
                .foregroundColor(Color(red: 0.3, green: 0.1, blue: 0.5))
                .multilineTextAlignment(.center)
                .lineLimit(2)

            // Descrizione
            Text(item.description)
                .font(.system(size: 11, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            // Effetti
            effectsBadges

            // Prezzo + Acquisto
            HStack {
                Text(item.currency == .coins ? "🪙 \(item.price)" : "💎 \(item.price)")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundColor(item.currency == .coins
                        ? Color(red: 0.8, green: 0.55, blue: 0.1)
                        : Color(red: 0.4, green: 0.2, blue: 0.8))

                Spacer()

                Button(action: onBuy) {
                    Text(isOwned && !item.isConsumable ? "✓ Hai" : "Acquista")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(isOwned && !item.isConsumable
                            ? Color.gray.opacity(0.5)
                            : Color(red: 0.6, green: 0.3, blue: 0.9))
                        .clipShape(Capsule())
                }
                .disabled(isOwned && !item.isConsumable)
            }
        }
        .padding(14)
        .background(Color.white.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color(red: 0.6, green: 0.3, blue: 0.9).opacity(0.1), radius: 8, x: 0, y: 4)
        .overlay(
            // Badge rarità
            Text(item.rarity == .legendary ? "⭐ Leggendario" : item.rarity == .rare ? "💜 Raro" : "")
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(item.rarity == .legendary ? Color(red: 0.9, green: 0.6, blue: 0.1) : Color(red: 0.5, green: 0.2, blue: 0.8))
                .clipShape(Capsule())
                .padding(8),
            alignment: .topTrailing
        )
    }

    private var effectsBadges: some View {
        HStack(spacing: 4) {
            if item.hungerBoost > 0    { effectBadge("🍽️", item.hungerBoost) }
            if item.happinessBoost > 0 { effectBadge("😊", item.happinessBoost) }
            if item.calmBoost > 0      { effectBadge("🌿", item.calmBoost) }
            if item.energyBoost > 0    { effectBadge("⚡", item.energyBoost) }
        }
    }

    private func effectBadge(_ icon: String, _ value: Double) -> some View {
        Text("\(icon)+\(Int(value * 100))%")
            .font(.system(size: 9, weight: .bold, design: .rounded))
            .foregroundColor(Color(red: 0.3, green: 0.6, blue: 0.3))
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(Color(red: 0.9, green: 1.0, blue: 0.9))
            .clipShape(Capsule())
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
                LinearGradient(
                    colors: [Color(red: 0.15, green: 0.05, blue: 0.3), Color(red: 0.3, green: 0.1, blue: 0.5)],
                    startPoint: .top, endPoint: .bottom
                ).ignoresSafeArea()

                VStack(spacing: 24) {
                    Text("💎")
                        .font(.system(size: 64))
                    Text("Acquista Gemme")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    Text("Le gemme ti permettono di acquistare oggetti rari e leggendari per la tua casa.")
                        .font(.system(size: 15, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)

                    if let msg = purchaseMessage {
                        Text(msg)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.green.opacity(0.6))
                            .clipShape(Capsule())
                    }

                    VStack(spacing: 12) {
                        ForEach(GemPack.all) { pack in
                            gemPackRow(pack)
                        }
                    }
                    .padding(.horizontal, 24)

                    Spacer()
                }
                .padding(.top, 32)
            }
            .navigationTitle("Gemme")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Chiudi") { dismiss() }
                        .foregroundColor(.white)
                }
            }
        }
    }

    private func gemPackRow(_ pack: GemPack) -> some View {
        let product = houseStore.storeKitProducts.first { $0.id == pack.id }

        return HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text("💎 \(pack.gems) Gemme")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    if let bonus = pack.bonusLabel {
                        Text(bonus)
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.3))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color(red: 0.8, green: 0.5, blue: 0.1).opacity(0.4))
                            .clipShape(Capsule())
                    }
                }
                if let product {
                    Text(product.displayPrice)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                } else {
                    Text("Caricamento...")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.white.opacity(0.5))
                }
            }

            Spacer()

            Button {
                Task { await buyGemPack(pack) }
            } label: {
                Text(product?.displayPrice ?? "—")
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundColor(Color(red: 0.3, green: 0.1, blue: 0.5))
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(Color(red: 1.0, green: 0.85, blue: 0.3))
                    .clipShape(Capsule())
            }
            .disabled(product == nil || houseStore.isPurchasing)
        }
        .padding(16)
        .background(Color.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
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
