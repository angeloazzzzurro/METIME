import SwiftUI

// MARK: - Store Color Tokens (file-private)

private extension Color {
    static let storeBg        = Color(hex: "#E8D5F5")
    static let storePrimary   = Color(hex: "#7B5CC8")
    static let storeDark      = Color(hex: "#3D2080")
    static let storeBtn       = Color(hex: "#5C3D9E")
    static let statGreenBg    = Color(hex: "#C6F0D6")
    static let statGreenFg    = Color(hex: "#1A7A3A")
    static let statPinkBg     = Color(hex: "#FFD6E0")
    static let statPinkFg     = Color(hex: "#A0284A")
    static let statTealBg     = Color(hex: "#C6EEE8")
    static let statTealFg     = Color(hex: "#1A6B5E")
}

// MARK: - Item Emoji Lookup

private func storeEmoji(for item: HouseItemDefinition) -> String {
    switch item.id {
    case "food_carrot":       return "🥕"
    case "food_cookie":       return "🍪"
    case "food_cake":         return "🎂"
    case "food_tea":          return "🍵"
    case "essential_bowl":    return "🥣"
    case "essential_cushion": return "🛋️"
    case "essential_blanket": return "⭐️"
    case "deco_plant":        return "🪴"
    case "deco_lamp":         return "🌙"
    case "deco_rug":          return "🎨"
    case "special_crystal":   return "💜"
    case "special_book":      return "📖"
    case "special_candle":    return "🕯️"
    default:                  return "📦"
    }
}

// MARK: - StoreView

struct StoreView: View {
    @EnvironmentObject private var houseStore: HouseStore
    @EnvironmentObject private var navigationState: NavigationState

    @State private var selectedCategory: ItemCategory = .food
    @State private var showGemSheet = false

    private var filteredItems: [HouseItemDefinition] {
        HouseItemDefinition.catalog.filter { $0.category == selectedCategory }
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color.storeBg.ignoresSafeArea()

            VStack(spacing: 0) {
                headerBar
                    .padding(.top, 8)

                currencyBar
                    .padding(.horizontal, 48)
                    .padding(.top, 12)

                categoryTabBar
                    .padding(.top, 14)

                itemGrid
            }
        }
        .sheet(isPresented: $showGemSheet) {
            GemPackSheet()
                .environmentObject(houseStore)
        }
    }

    // MARK: Header Bar

    private var headerBar: some View {
        HStack(spacing: 6) {
            // Left: Acquista Gemme
            Button { showGemSheet = true } label: {
                HStack(spacing: 4) {
                    Text("💎")
                        .font(.system(size: 13))
                    Text("Acquista Gemme")
                        .font(.system(.caption, design: .rounded).weight(.bold))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.storeBtn, in: Capsule())
                .foregroundStyle(.white)
            }

            Spacer(minLength: 4)

            // Center: Title
            Text("🛍️ Store")
                .font(.system(.title3, design: .rounded).weight(.heavy))
                .foregroundStyle(Color.storeDark)

            Spacer(minLength: 4)

            // Right: Chiudi
            Button("Chiudi") {
                navigationState.activeSection = .home
            }
            .font(.system(.subheadline, design: .rounded).weight(.semibold))
            .foregroundStyle(Color.storePrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(.white, in: Capsule())
            .overlay(Capsule().strokeBorder(Color.storePrimary, lineWidth: 1.5))
        }
        .padding(.horizontal, 16)
    }

    // MARK: Currency Bar

    private var currencyBar: some View {
        HStack(spacing: 0) {
            HStack(spacing: 5) {
                Text("🪙")
                    .font(.system(size: 15))
                Text("\(houseStore.wallet.coins)")
                    .font(.system(.subheadline, design: .rounded).weight(.bold))
                    .foregroundStyle(Color.storeDark)
                    .contentTransition(.numericText())
            }
            .frame(maxWidth: .infinity)

            Rectangle()
                .fill(Color.storePrimary.opacity(0.25))
                .frame(width: 1, height: 20)

            HStack(spacing: 5) {
                Text("💎")
                    .font(.system(size: 15))
                Text("\(houseStore.wallet.gems)")
                    .font(.system(.subheadline, design: .rounded).weight(.bold))
                    .foregroundStyle(Color.storeDark)
                    .contentTransition(.numericText())
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 11)
        .background(.white, in: Capsule())
        .shadow(color: Color.storePrimary.opacity(0.12), radius: 8, y: 3)
    }

    // MARK: Category Tab Bar

    private var categoryTabBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ItemCategory.allCases, id: \.self) { cat in
                    StoreCategoryTab(
                        label: "\(cat.emoji) \(cat.displayName)",
                        isActive: cat == selectedCategory
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedCategory = cat
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: Item Grid

    private var itemGrid: some View {
        ScrollView {
            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: 14
            ) {
                ForEach(filteredItems) { item in
                    StoreItemCard(item: item)
                        .environmentObject(houseStore)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
        .animation(.easeInOut(duration: 0.25), value: selectedCategory)
        .padding(.top, 10)
    }
}

// MARK: - StoreCategoryTab

private struct StoreCategoryTab: View {
    let label: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(.subheadline, design: .rounded).weight(.semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .foregroundStyle(isActive ? .white : Color.storePrimary)
                .background {
                    if isActive {
                        Capsule().fill(Color.storePrimary)
                    } else {
                        Capsule()
                            .fill(.white)
                            .overlay(Capsule().strokeBorder(Color.storePrimary, lineWidth: 1.5))
                    }
                }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - StoreItemCard

struct StoreItemCard: View {
    let item: HouseItemDefinition
    @EnvironmentObject private var houseStore: HouseStore

    @State private var purchasing = false

    private var emoji: String      { storeEmoji(for: item) }
    private var isRare: Bool       { item.rarity != .common }
    private var canAfford: Bool    { houseStore.wallet.canAfford(price: item.price, currency: item.currency) }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            cardContent
                .background(.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(color: Color.storePrimary.opacity(0.09), radius: 8, y: 3)

            if isRare {
                Text("💜 Raro")
                    .font(.system(.caption2, design: .rounded).weight(.bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.storePrimary, in: Capsule())
                    .foregroundStyle(.white)
                    .offset(x: 8, y: -8)
            }
        }
    }

    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Name row
            HStack(spacing: 4) {
                Text(emoji)
                    .font(.system(size: 13))
                Text(item.name)
                    .font(.system(.caption, design: .rounded).weight(.bold))
                    .foregroundStyle(Color.storeDark)
                    .lineLimit(1)
            }

            // Large emoji
            Text(emoji)
                .font(.system(size: 54))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 2)

            // Description
            Text(item.description)
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(maxWidth: .infinity)

            // Stat badges
            statBadgesRow

            // Footer
            HStack(alignment: .center, spacing: 6) {
                priceLabel
                Spacer()
                buyButton
            }
            .padding(.top, 2)
        }
        .padding(12)
    }

    // MARK: Stat Badges

    private struct StatBadge: Identifiable {
        let id = UUID()
        let label: String
        let bg: Color
        let fg: Color
    }

    private var statBadges: [StatBadge] {
        var badges: [StatBadge] = []
        if item.hungerBoost    > 0 { badges.append(.init(label: "+\(pct(item.hungerBoost)) 🍴",    bg: .statGreenBg, fg: .statGreenFg)) }
        if item.happinessBoost > 0 { badges.append(.init(label: "+\(pct(item.happinessBoost)) 😊", bg: .statPinkBg,  fg: .statPinkFg)) }
        if item.calmBoost      > 0 { badges.append(.init(label: "+\(pct(item.calmBoost)) 🌿",      bg: .statTealBg,  fg: .statTealFg)) }
        if item.energyBoost    > 0 { badges.append(.init(label: "+\(pct(item.energyBoost)) ⚡️",   bg: .statTealBg,  fg: .statTealFg)) }
        return badges
    }

    private func pct(_ v: Double) -> String { "\(Int(v * 100))%" }

    @ViewBuilder
    private var statBadgesRow: some View {
        let badges = statBadges
        if !badges.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(badges) { badge in
                        Text(badge.label)
                            .font(.system(.caption2, design: .rounded).weight(.semibold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(badge.bg, in: Capsule())
                            .foregroundStyle(badge.fg)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: Price & Buy

    private var priceLabel: some View {
        HStack(spacing: 3) {
            Text(item.currency == .coins ? "🪙" : "💎")
                .font(.system(size: 13))
            Text("\(item.price)")
                .font(.system(.subheadline, design: .rounded).weight(.bold))
                .foregroundStyle(Color.storeDark)
        }
    }

    private var buyButton: some View {
        Button {
            Task { await doPurchase() }
        } label: {
            Group {
                if purchasing {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(0.75)
                        .frame(width: 60)
                } else {
                    Text("Acquista 🛒")
                }
            }
            .font(.system(.caption, design: .rounded).weight(.bold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .frame(minWidth: 80)
            .background(
                (canAfford && !purchasing) ? Color.storeBtn : Color.gray.opacity(0.35),
                in: Capsule()
            )
            .foregroundStyle(.white)
        }
        .disabled(!canAfford || purchasing)
        .buttonStyle(.plain)
    }

    private func doPurchase() async {
        guard canAfford, !purchasing else { return }
        if item.currency == .coins {
            _ = houseStore.purchase(item: item)
        } else {
            purchasing = true
            _ = await houseStore.purchaseWithStoreKit(item: item)
            purchasing = false
        }
    }
}

// MARK: - GemPackSheet

private struct GemPackSheet: View {
    @EnvironmentObject private var houseStore: HouseStore
    @Environment(\.dismiss) private var dismiss

    @State private var purchasing: String?

    var body: some View {
        VStack(spacing: 0) {
            // Handle
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.storePrimary.opacity(0.25))
                .frame(width: 36, height: 5)
                .padding(.top, 14)
                .padding(.bottom, 20)

            Text("💎 Acquista Gemme")
                .font(.system(.title2, design: .rounded).weight(.heavy))
                .foregroundStyle(Color.storeDark)

            Text("Le gemme ti permettono di\nacquistare oggetti speciali per il tuo pet!")
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.top, 8)

            VStack(spacing: 12) {
                ForEach(GemPack.all) { pack in
                    GemPackRow(pack: pack, purchasing: $purchasing) {
                        Task {
                            purchasing = pack.id
                            _ = await houseStore.purchaseGemPack(pack)
                            purchasing = nil
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 28)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.storeBg.ignoresSafeArea())
    }
}

private struct GemPackRow: View {
    let pack: GemPack
    @Binding var purchasing: String?
    let onBuy: () -> Void

    private var isBuying: Bool { purchasing == pack.id }

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text("💎 \(pack.gems)")
                        .font(.system(.headline, design: .rounded).weight(.bold))
                        .foregroundStyle(Color.storeDark)
                    if let bonus = pack.bonusLabel {
                        Text(bonus)
                            .font(.system(.caption, design: .rounded).weight(.semibold))
                            .padding(.horizontal, 7)
                            .padding(.vertical, 2)
                            .background(Color.statTealBg, in: Capsule())
                            .foregroundStyle(Color.statTealFg)
                    }
                }
                Text("Gemme")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button(action: onBuy) {
                Group {
                    if isBuying {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(0.85)
                            .frame(width: 90)
                    } else {
                        Text("Acquista 🛒")
                    }
                }
                .font(.system(.subheadline, design: .rounded).weight(.bold))
                .padding(.horizontal, 18)
                .padding(.vertical, 11)
                .frame(minWidth: 110)
                .background(Color.storeBtn, in: Capsule())
                .foregroundStyle(.white)
            }
            .disabled(purchasing != nil)
            .buttonStyle(.plain)
        }
        .padding(14)
        .background(.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.storePrimary.opacity(0.08), radius: 6, y: 2)
    }
}
