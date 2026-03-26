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

// MARK: - Item Symbol Lookup

private func storeSymbolName(for item: HouseItemDefinition) -> String {
    let id = item.id

    if id.contains("carrot") { return "carrot" }
    if id.contains("cookie") || id.contains("cake") || id.contains("pancakes") { return "birthday.cake" }
    if id.contains("tea") || id.contains("milk") || id.contains("lemonade") || id.contains("smoothie") { return "cup.and.saucer.fill" }
    if id.contains("strawberry") { return "heart.fill" }
    if id.contains("toast") { return "takeoutbag.and.cup.and.straw.fill" }
    if id.contains("bento") || id.contains("soup") { return "takeoutbag.and.cup.and.straw.fill" }
    if id.contains("jam") { return "drop.fill" }
    if id.contains("mochi") { return "sparkles" }

    if id.contains("bowl") { return "bowl.fill" }
    if id.contains("cushion") || id.contains("bed") || id.contains("hammock") { return "sofa.fill" }
    if id.contains("blanket") { return "star.fill" }
    if id.contains("bookshelf") || id.contains("desk") { return "books.vertical.fill" }
    if id.contains("closet") || id.contains("nightstand") { return "cabinet.fill" }
    if id.contains("bath") { return "drop.circle.fill" }
    if id.contains("stool") { return "square.fill" }
    if id.contains("mirror") { return "mirror.side.left.and.heat.waves" }
    if id.contains("screen") { return "rectangle.portrait.on.rectangle.portrait.fill" }

    if id.contains("plant") || id.contains("planter") { return "leaf.fill" }
    if id.contains("lamp") || id.contains("garland") { return "lamp.desk.fill" }
    if id.contains("rug") { return "paintpalette.fill" }
    if id.contains("window") { return "window.vertical.closed" }
    if id.contains("clock") { return "clock.fill" }
    if id.contains("frame") || id.contains("painting") || id.contains("poster") { return "photo.fill" }
    if id.contains("vase") { return "trophy.fill" }
    if id.contains("plush") { return "heart.circle.fill" }
    if id.contains("musicbox") || id.contains("mobile") { return "music.note" }

    if id.contains("crystal") || id.contains("orb") { return "diamond.fill" }
    if id.contains("book") || id.contains("map") { return "book.fill" }
    if id.contains("candle") { return "flame.fill" }
    if id.contains("lotus") { return "sparkles" }
    if id.contains("moon_mirror") { return "moon.stars.fill" }
    if id.contains("fountain") { return "drop.triangle.fill" }
    if id.contains("fairy_jar") { return "lightbulb.max.fill" }
    if id.contains("comet") { return "star.leadinghalf.filled" }
    if id.contains("snow_globe") { return "snowflake" }
    if id.contains("portal") { return "circle.hexagongrid.fill" }

    return "shippingbox.fill"
}

private func storeSymbolColor(for item: HouseItemDefinition) -> Color {
    switch item.category {
    case .food:        return Color(hex: "#F97316")
    case .essentials:  return Color(hex: "#3B82F6")
    case .decorations: return Color(hex: "#8B5CF6")
    case .specials:    return Color(hex: "#F59E0B")
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
        GeometryReader { proxy in
            let compact = proxy.size.width < 430

            ZStack {
                Color.storeBg.ignoresSafeArea()

                itemGrid(compact: compact)
            }
            .safeAreaInset(edge: .top) {
                stickyStoreHeader(compact: compact)
            }
            .sheet(isPresented: $showGemSheet) {
                GemPackSheet()
                    .environmentObject(houseStore)
            }
        }
    }

    // MARK: Header Bar

    private func headerBar(compact: Bool) -> some View {
        HStack(spacing: 6) {
            Button { showGemSheet = true } label: {
                HStack(spacing: 4) {
                    Image(systemName: "diamond.fill")
                        .font(.system(size: compact ? 11 : 12))
                    Text(compact ? "Gemme" : "Acquista Gemme")
                        .font(.system(compact ? .caption2 : .caption, design: .rounded).weight(.bold))
                }
                .padding(.horizontal, compact ? 10 : 12)
                .padding(.vertical, compact ? 7 : 8)
                .background(Color.storeBtn, in: Capsule())
                .foregroundStyle(.white)
            }

            Spacer(minLength: 4)

            Label("Store", systemImage: "basket.fill")
                .font(.system(compact ? .headline : .title3, design: .rounded).weight(.heavy))
                .foregroundStyle(Color.storeDark)

            Spacer(minLength: 4)

            Button("Chiudi") {
                navigationState.activeSection = .home
            }
            .font(.system(compact ? .caption : .subheadline, design: .rounded).weight(.semibold))
            .foregroundStyle(Color.storePrimary)
            .padding(.horizontal, compact ? 12 : 16)
            .padding(.vertical, compact ? 7 : 8)
            .background(.white, in: Capsule())
            .overlay(Capsule().strokeBorder(Color.storePrimary, lineWidth: 1.5))
        }
        .padding(.horizontal, compact ? 12 : 16)
    }

    // MARK: Currency Bar

    private func currencyBar(compact: Bool) -> some View {
        HStack(spacing: 0) {
            HStack(spacing: 5) {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.system(size: compact ? 14 : 15))
                    .foregroundStyle(Color(hex: "#F59E0B"))
                Text("\(houseStore.wallet.coins)")
                    .font(.system(compact ? .caption : .subheadline, design: .rounded).weight(.bold))
                    .foregroundStyle(Color.storeDark)
                    .contentTransition(.numericText())
            }
            .frame(maxWidth: .infinity)

            Rectangle()
                .fill(Color.storePrimary.opacity(0.25))
                .frame(width: 1, height: 20)

            HStack(spacing: 5) {
                Image(systemName: "diamond.fill")
                    .font(.system(size: compact ? 12 : 13))
                    .foregroundStyle(Color.storePrimary)
                Text("\(houseStore.wallet.gems)")
                    .font(.system(compact ? .caption : .subheadline, design: .rounded).weight(.bold))
                    .foregroundStyle(Color.storeDark)
                    .contentTransition(.numericText())
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, compact ? 9 : 11)
        .background(.white, in: Capsule())
        .shadow(color: Color.storePrimary.opacity(0.12), radius: 8, y: 3)
    }

    // MARK: Category Tab Bar

    private var categoryTabBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ItemCategory.allCases, id: \.self) { cat in
                    StoreCategoryTab(
                        icon: cat.sfSymbol,
                        label: cat.displayName,
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

    private func itemGrid(compact: Bool) -> some View {
        ScrollView {
            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                Section {
                    LazyVGrid(
                        columns: compact ? [GridItem(.flexible())] : [GridItem(.flexible()), GridItem(.flexible())],
                        spacing: compact ? 12 : 14
                    ) {
                        ForEach(filteredItems) { item in
                            StoreItemCard(item: item)
                                .environmentObject(houseStore)
                        }
                    }
                    .padding(.horizontal, compact ? 12 : 16)
                    .padding(.top, compact ? 12 : 16)
                    .padding(.bottom, 40)
                } header: {
                    Color.clear.frame(height: 1)
                }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: selectedCategory)
        .padding(.top, 10)
    }

    private func stickyStoreHeader(compact: Bool) -> some View {
        VStack(spacing: 0) {
            headerBar(compact: compact)
                .padding(.top, compact ? 6 : 8)

            currencyBar(compact: compact)
                .padding(.horizontal, compact ? 12 : 48)
                .padding(.top, compact ? 8 : 12)

            categoryTabBar
                .padding(.top, compact ? 10 : 14)
                .padding(.bottom, compact ? 8 : 10)
        }
        .background(
            LinearGradient(
                colors: [Color.storeBg, Color.storeBg.opacity(0.95)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

// MARK: - StoreCategoryTab

private struct StoreCategoryTab: View {
    let icon: String
    let label: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(label, systemImage: icon)
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

    private var symbolName: String   { storeSymbolName(for: item) }
    private var symbolColor: Color   { storeSymbolColor(for: item) }
    private var isRare: Bool         { item.rarity != .common }
    private var canAfford: Bool      { houseStore.wallet.canAfford(price: item.price, currency: item.currency) }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            cardContent
                .background(.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(color: Color.storePrimary.opacity(0.09), radius: 8, y: 3)

            if isRare {
                Label("Raro", systemImage: "star.fill")
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
                Image(systemName: symbolName)
                    .font(.system(size: 12))
                    .foregroundStyle(symbolColor)
                Text(item.name)
                    .font(.system(.caption, design: .rounded).weight(.bold))
                    .foregroundStyle(Color.storeDark)
                    .lineLimit(1)
            }

            // Large symbol
            Image(systemName: symbolName)
                .font(.system(size: 48))
                .foregroundStyle(symbolColor)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 4)

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
        let icon: String
        let label: String
        let bg: Color
        let fg: Color
    }

    private var statBadges: [StatBadge] {
        var badges: [StatBadge] = []
        if item.hungerBoost    > 0 { badges.append(.init(icon: "fork.knife",   label: "+\(pct(item.hungerBoost))",    bg: .statGreenBg, fg: .statGreenFg)) }
        if item.happinessBoost > 0 { badges.append(.init(icon: "face.smiling", label: "+\(pct(item.happinessBoost))", bg: .statPinkBg,  fg: .statPinkFg)) }
        if item.calmBoost      > 0 { badges.append(.init(icon: "leaf.fill",    label: "+\(pct(item.calmBoost))",      bg: .statTealBg,  fg: .statTealFg)) }
        if item.energyBoost    > 0 { badges.append(.init(icon: "bolt.fill",    label: "+\(pct(item.energyBoost))",    bg: .statTealBg,  fg: .statTealFg)) }
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
                        Label(badge.label, systemImage: badge.icon)
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
            Image(systemName: item.currency == .coins ? "dollarsign.circle.fill" : "diamond.fill")
                .font(.system(size: 13))
                .foregroundStyle(item.currency == .coins ? Color(hex: "#F59E0B") : Color.storePrimary)
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
                    Text("Acquista")
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

            Label("Acquista Gemme", systemImage: "diamond.fill")
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
                    Image(systemName: "diamond.fill")
                        .foregroundStyle(Color(hex: "#7B5CC8"))
                    Text("\(pack.gems)")
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
                        Text("Acquista")
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
