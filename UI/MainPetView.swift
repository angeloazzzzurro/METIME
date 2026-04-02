import SwiftUI

// MARK: - MainPetView

/// Homepage principale di METIME.
/// Barra di navigazione fissa in alto (come nel mockup), contenuto sezione sotto.
struct MainPetView: View {

    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var store: GameStore
    @EnvironmentObject private var navigationState: NavigationState
    @EnvironmentObject private var houseStore: HouseStore

    private let sections: [NavigationState.Section] = [.home, .garden, .games, .diary, .store, .inventory, .decorate, .meTime]

    @State private var showJournal = false
    @State private var feedShake: CGFloat = 0

    var body: some View {
        GeometryReader { proxy in
            let compact = proxy.size.width < 430

            Group {
                if compact {
                    VStack(spacing: 0) {
                        compactSelectionBar
                        careFocusPanel(compact: true)
                        currentSectionContent
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                } else {
                    HStack(spacing: 0) {
                        sideSelectionBar

                        VStack(spacing: 0) {
                            careFocusPanel(compact: false)
                            currentSectionContent
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                }
            }
            .background(Color(hex: "#F8F4FF").ignoresSafeArea())
            .simultaneousGesture(
                DragGesture(minimumDistance: 40, coordinateSpace: .local)
                    .onEnded { value in
                        let h = value.translation.width
                        let v = value.translation.height
                        guard abs(h) > abs(v) * 3.2, abs(h) > 72 else { return }
                        let currentIndex = sections.firstIndex(of: navigationState.activeSection) ?? 0
                        if h < 0, currentIndex < sections.count - 1 {
                            withAnimation(.snappy(duration: 0.22)) {
                                navigationState.activeSection = sections[currentIndex + 1]
                            }
                        } else if h > 0, currentIndex > 0 {
                            withAnimation(.snappy(duration: 0.22)) {
                                navigationState.activeSection = sections[currentIndex - 1]
                            }
                        }
                    }
            )
            .onChange(of: store.pet.needs.hunger)    { _, _ in syncMood() }
            .onChange(of: store.pet.needs.happiness) { _, _ in syncMood() }
            .onChange(of: store.pet.needs.calm)      { _, _ in syncMood() }
            .onChange(of: store.pet.needs.energy)    { _, _ in syncMood() }
            .onChange(of: store.feedBlocked) { _, blocked in
                if blocked { triggerShake() }
            }
        }
        .sheet(isPresented: $showJournal) {
            NavigationStack {
                JournalInsightsMockupView()
                    .environmentObject(store)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Chiudi") { showJournal = false }
                        }
                    }
            }
        }
    }

    private var compactSelectionBar: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                Label("METIME", systemImage: "heart.circle.fill")
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundStyle(Color(hex: "#7A57B8"))

                Spacer()

                Button {
                    showJournal = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "book.closed.fill")
                            .font(.system(size: 12, weight: .black))
                        Text("Journey")
                            .font(.system(size: 11, weight: .black, design: .rounded))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 9)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "#F59E0B"), Color(hex: "#EC4899")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        in: Capsule()
                    )
                }
                .buttonStyle(.plain)
            }

            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(sections, id: \.self) { section in
                            CompactTabButton(
                                icon: icon(for: section),
                                label: title(for: section),
                                selected: navigationState.activeSection == section,
                                tint: tint(for: section)
                            ) {
                                withAnimation(.snappy(duration: 0.22)) {
                                    navigationState.activeSection = section
                                }
                            }
                            .id(section)
                        }
                    }
                    .padding(.vertical, 2)
                }
                .onAppear {
                    proxy.scrollTo(navigationState.activeSection, anchor: .center)
                }
                .onChange(of: navigationState.activeSection) { _, section in
                    withAnimation(.snappy(duration: 0.22)) {
                        proxy.scrollTo(section, anchor: .center)
                    }
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.top, 8)
        .padding(.bottom, 10)
        .background(
            LinearGradient(
                colors: [Color.white.opacity(0.97), Color(hex: "#F4ECFF")],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color(hex: "#E6D8FF"))
                .frame(height: 1)
        }
    }

    private var currentSectionContent: some View {
        Group {
            switch navigationState.activeSection {
            case .home:
                HouseView()
                    .environmentObject(store)
                    .environmentObject(houseStore)
                    .environmentObject(navigationState)
            case .garden:
                GardenSectionView()
                    .environmentObject(appState)
                    .environmentObject(store)
                    .environmentObject(houseStore)
            case .games:
                GamesSectionView()
                    .environmentObject(store)
                    .environmentObject(houseStore)
            case .diary:
                NavigationStack {
                    JournalInsightsMockupView()
                        .environmentObject(store)
                }
            case .store:
                StoreView()
                    .environmentObject(houseStore)
                    .environmentObject(navigationState)
            case .inventory:
                InventoryView()
                    .environmentObject(store)
                    .environmentObject(houseStore)
                    .environmentObject(navigationState)
            case .decorate:
                DecorateView()
                    .environmentObject(store)
                    .environmentObject(houseStore)
                    .environmentObject(navigationState)
            case .meTime:
                NavigationStack {
                    MeditationView()
                        .environmentObject(store)
                        .environmentObject(houseStore)
                }
            }
        }
    }

    private func careFocusPanel(compact: Bool) -> some View {
        VStack(spacing: compact ? 10 : 12) {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Cura del pet")
                        .font(.system(size: compact ? 18 : 22, weight: .black, design: .rounded))
                        .foregroundStyle(Color(hex: "#5F467E"))
                    Text(careHeadline)
                        .font(.system(size: compact ? 11 : 13, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(hex: "#8B76A5"))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 8)

                HStack(spacing: compact ? 8 : 10) {
                    careBadge(
                        icon: "face.smiling.fill",
                        label: store.pet.mood.rawValue.capitalized,
                        tint: tint(forMood: store.pet.mood)
                    )
                    careBadge(
                        icon: "sparkles",
                        label: "Lv \(store.pet.stage)",
                        tint: Color(hex: "#F59E0B")
                    )
                }
            }

            if compact {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        careActionButton(icon: "fork.knife", title: "Nutri", tint: Color(hex: "#F97316")) {
                            store.feed()
                        }
                        .offset(x: feedShake)

                        careActionButton(icon: "gamecontroller.fill", title: "Gioca", tint: Color(hex: "#EC4899")) {
                            store.play()
                        }

                        careActionButton(icon: "sparkles", title: "Calma", tint: Color(hex: "#60A5FA")) {
                            store.meditate()
                        }

                        careActionButton(icon: "book.closed.fill", title: "Diario", tint: Color(hex: "#5A8BCF")) {
                            navigationState.activeSection = .diary
                        }

                        careActionButton(icon: "cup.and.saucer.fill", title: "Me Time", tint: Color(hex: "#D36F8E")) {
                            navigationState.activeSection = .meTime
                        }
                    }
                    .padding(.horizontal, 1)
                }
            } else {
                HStack(spacing: 10) {
                    careActionButton(icon: "fork.knife", title: "Nutri", tint: Color(hex: "#F97316")) {
                        store.feed()
                    }
                    .offset(x: feedShake)

                    careActionButton(icon: "gamecontroller.fill", title: "Gioca", tint: Color(hex: "#EC4899")) {
                        store.play()
                    }

                    careActionButton(icon: "sparkles", title: "Calma", tint: Color(hex: "#60A5FA")) {
                        store.meditate()
                    }

                    careActionButton(icon: "book.closed.fill", title: "Diario", tint: Color(hex: "#5A8BCF")) {
                        navigationState.activeSection = .diary
                    }

                    careActionButton(icon: "cup.and.saucer.fill", title: "Me Time", tint: Color(hex: "#D36F8E")) {
                        navigationState.activeSection = .meTime
                    }
                }
            }
        }
        .padding(.horizontal, compact ? 14 : 18)
        .padding(.vertical, compact ? 12 : 14)
        .background(
            LinearGradient(
                colors: [Color.white.opacity(0.96), Color(hex: "#F8F1FF")],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color(hex: "#E6D8FF"))
                .frame(height: 1)
        }
    }

    private var careHeadline: String {
        let pet = store.pet
        if pet.needs.hunger < 0.35 { return "Ha fame: dagli cibo o uno snack." }
        if pet.needs.calm < 0.35 { return "Ha bisogno di calma: diario o Me Time." }
        if pet.needs.energy < 0.35 { return "Energia bassa: rallenta e fai un rituale." }
        if pet.needs.happiness < 0.45 { return "Vuole attenzione: gioca o passa tempo con lui." }
        return "Sta bene. Mantieni il ritmo con cura leggera."
    }

    private func careBadge(icon: String, label: String, tint: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .black))
            Text(label)
                .font(.system(size: 11, weight: .black, design: .rounded))
                .lineLimit(1)
        }
        .foregroundStyle(tint)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.92), in: Capsule())
    }

    private func careActionButton(icon: String, title: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .black))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(
                        LinearGradient(
                            colors: [tint, tint.opacity(0.82)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        in: Circle()
                    )
                Text(title)
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundStyle(tint)
                    .lineLimit(1)
            }
            .frame(width: 70)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Side Bar

    private var sideSelectionBar: some View {
        VStack(spacing: 14) {
            Text("METIME")
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundStyle(Color(hex: "#7A57B8"))
                .rotationEffect(.degrees(-90))
                .frame(height: 40)
                .padding(.top, 10)

            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 10) {
                        ForEach(sections, id: \.self) { section in
                            HomePetTabButton(
                                icon: icon(for: section),
                                label: title(for: section),
                                selected: navigationState.activeSection == section,
                                tint: tint(for: section)
                            ) {
                                withAnimation(.snappy(duration: 0.22)) {
                                    navigationState.activeSection = section
                                }
                            }
                            .id(section)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .scrollBounceBehavior(.basedOnSize, axes: .vertical)
                .onAppear {
                    proxy.scrollTo(navigationState.activeSection, anchor: .center)
                }
                .onChange(of: navigationState.activeSection) { _, section in
                    withAnimation(.snappy(duration: 0.22)) {
                        proxy.scrollTo(section, anchor: .center)
                    }
                }
            }

            Spacer(minLength: 6)

            Button {
                showJournal = true
            } label: {
                VStack(spacing: 6) {
                    Image(systemName: "book.closed.fill")
                        .font(.system(size: 16, weight: .bold))
                    Text("Journey")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                }
                .foregroundStyle(.white)
                .frame(width: 68)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "#F59E0B"), Color(hex: "#EC4899")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                )
            }
            .buttonStyle(.plain)
            .padding(.bottom, 10)
        }
        .frame(width: 92)
        .padding(.horizontal, 10)
        .padding(.vertical, 12)
        .background(
            LinearGradient(
                colors: [Color.white.opacity(0.96), Color(hex: "#F4ECFF")],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .overlay(alignment: .trailing) {
            Rectangle()
                .fill(Color(hex: "#E6D8FF"))
                .frame(width: 1)
        }
    }

    // MARK: - Pill Grid

    private var pillGrid: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                pill(
                    label: "Hunger",
                    color: Color(hex: "#A78BFA"),
                    badge: store.pet.food == 0 ? "!" : nil
                ) {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    store.feed()
                }
                .offset(x: feedShake)

                pill(label: "Happiness", color: Color(hex: "#F87171")) {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    store.play()
                }
            }
            HStack(spacing: 12) {
                pill(label: "Calm", color: Color(hex: "#60A5FA")) {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    store.meditate()
                }
                pill(label: "Energy", color: Color(hex: "#34D399")) {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    showJournal = true
                }
            }
        }
    }

    private func pill(
        label: String,
        color: Color,
        badge: String? = nil,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                Text(label)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        Capsule()
                            .fill(color)
                            .shadow(color: color.opacity(0.45), radius: 8, y: 4)
                    )

                if let badge {
                    Text(badge)
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(.white)
                        .padding(4)
                        .background(Color.red, in: Circle())
                        .offset(x: -4, y: 4)
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private func syncMood() {
        let derived = store.derivedMood()
        if appState.mood != derived { appState.mood = derived }
    }

    private func title(for section: NavigationState.Section) -> String {
        switch section {
        case .home:
            return "Casa"
        case .garden:
            return "Giardino"
        case .games:
            return "Giochi"
        case .diary:
            return "Diario"
        case .store:
            return "Store"
        case .inventory:
            return "Zaino"
        case .decorate:
            return "Decora"
        case .meTime:
            return "Me Time"
        }
    }

    private func icon(for section: NavigationState.Section) -> String {
        switch section {
        case .home:
            return "house.fill"
        case .garden:
            return "tree.fill"
        case .games:
            return "gamecontroller.fill"
        case .diary:
            return "book.pages.fill"
        case .store:
            return "basket.fill"
        case .inventory:
            return "backpack.fill"
        case .decorate:
            return "chair.fill"
        case .meTime:
            return "cup.and.saucer.fill"
        }
    }

    private func tint(for section: NavigationState.Section) -> Color {
        switch section {
        case .home:
            return Color(hex: "#E38A74")
        case .garden:
            return Color(hex: "#53A86A")
        case .games:
            return Color(hex: "#E98A56")
        case .diary:
            return Color(hex: "#5A8BCF")
        case .store:
            return Color(hex: "#C98053")
        case .inventory:
            return Color(hex: "#5E84C9")
        case .decorate:
            return Color(hex: "#A77BC7")
        case .meTime:
            return Color(hex: "#D36F8E")
        }
    }

    private func tint(forMood mood: PetMood) -> Color {
        switch mood {
        case .happy:
            return Color(hex: "#E38A74")
        case .calm:
            return Color(hex: "#5A8BCF")
        case .anxious:
            return Color(hex: "#D36F8E")
        case .sleepy:
            return Color(hex: "#6F78D8")
        case .sick:
            return Color(hex: "#7D8C8B")
        case .evolving:
            return Color(hex: "#A77BC7")
        }
    }

    private func triggerShake() {
        withAnimation(.spring(response: 0.1, dampingFraction: 0.3).repeatCount(4, autoreverses: true)) {
            feedShake = 6
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { feedShake = 0 }
    }
}

// MARK: - HomePetTabButton

private struct HomePetTabButton: View {
    let icon: String
    let label: String
    let selected: Bool
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(selected ? Color.white.opacity(0.24) : tint.opacity(0.14))
                        .frame(width: 34, height: 34)
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(selected ? .white : tint)
                }
                Text(label)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(selected ? .white : Color(hex: "#6E6488"))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(width: 68)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        selected
                            ? LinearGradient(
                                colors: [tint, tint.opacity(0.78)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            : LinearGradient(
                                colors: [Color.white.opacity(0.95), Color(hex: "#F8F1FF")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(selected ? Color.white.opacity(0.18) : tint.opacity(0.14), lineWidth: 1)
            )
            .shadow(color: selected ? tint.opacity(0.28) : Color.black.opacity(0.04), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
    }
}

private struct CompactTabButton: View {
    let icon: String
    let label: String
    let selected: Bool
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 7) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .black))
                Text(label)
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .lineLimit(1)
            }
            .foregroundStyle(selected ? .white : tint)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(
                        selected
                            ? AnyShapeStyle(
                                LinearGradient(
                                    colors: [tint, tint.opacity(0.78)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            : AnyShapeStyle(Color.white.opacity(0.94))
                    )
            )
            .overlay(
                Capsule()
                    .stroke(selected ? Color.white.opacity(0.18) : tint.opacity(0.14), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Color hex helper

extension Color {
    init(hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: h).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >>  8) & 0xFF) / 255
        let b = Double( int        & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

struct GamesSectionView: View {
    @EnvironmentObject private var store: GameStore
    @EnvironmentObject private var houseStore: HouseStore

    @State private var selectedMiniGame: MiniGameDefinition = .cloverHunt
    @State private var comboCount: Int = 0
    @State private var rewardMessage: String?
    @State private var activeMiniGame: MiniGameDefinition?

    var body: some View {
        GeometryReader { proxy in
            let compact = proxy.size.width < 430

            ZStack {
                LinearGradient(
                    colors: [Color(hex: "#FFF6EA"), Color(hex: "#FDEFE8"), Color(hex: "#FFF9F1")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: compact ? 14 : 18) {
                        gamesHeader

                        if compact {
                            VStack(spacing: 12) {
                                featuredGameCard
                                HStack(spacing: 10) {
                                    statBadge(icon: "dollarsign.circle.fill", title: "Coin", value: "\(houseStore.wallet.coins)", tint: Color(hex: "#CF8C2B"))
                                    statBadge(icon: "flame.fill", title: "Combo", value: "\(comboCount)", tint: Color(hex: "#E37858"))
                                    statBadge(icon: "heart.fill", title: "Mood", value: store.pet.mood.rawValue.capitalized, tint: Color(hex: "#D36F8E"))
                                }
                            }
                        } else {
                            HStack(alignment: .top, spacing: 14) {
                                featuredGameCard

                                VStack(spacing: 12) {
                                    statBadge(icon: "dollarsign.circle.fill", title: "Coin", value: "\(houseStore.wallet.coins)", tint: Color(hex: "#CF8C2B"))
                                    statBadge(icon: "flame.fill", title: "Combo", value: "\(comboCount)", tint: Color(hex: "#E37858"))
                                    statBadge(icon: "heart.fill", title: "Mood", value: store.pet.mood.rawValue.capitalized, tint: Color(hex: "#D36F8E"))
                                }
                                .frame(width: 110)
                            }
                        }

                        VStack(spacing: 12) {
                            ForEach(MiniGameDefinition.allCases, id: \.self) { game in
                                gameSelectionCard(for: game)
                            }
                        }

                        if let rewardMessage {
                            Text(rewardMessage)
                                .font(.system(size: 12, weight: .black, design: .rounded))
                                .foregroundStyle(Color(hex: "#7A5130"))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(Color.white.opacity(0.9), in: Capsule())
                                .transition(.opacity.combined(with: .scale))
                        }

                        Button(action: playSelectedGame) {
                            HStack(spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(Color.white.opacity(0.2))
                                        .frame(width: 50, height: 50)
                                    Image(systemName: selectedMiniGame.icon)
                                        .font(.system(size: 22, weight: .black))
                                    Text(selectedMiniGame.badgeText)
                                        .font(.system(size: 11, weight: .black, design: .rounded))
                                        .foregroundStyle(selectedMiniGame.logoTint)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 3)
                                        .background(Color.white, in: Capsule())
                                        .offset(x: 20, y: 20)
                                }

                                VStack(alignment: .leading, spacing: 3) {
                                    Text(selectedMiniGame.actionTitle)
                                        .font(.system(size: 16, weight: .black, design: .rounded))
                                    Text(selectedMiniGame.rewardLine)
                                        .font(.system(size: 12, weight: .bold, design: .rounded))
                                        .foregroundStyle(Color.white.opacity(0.86))
                                }

                                Spacer()

                                VStack(alignment: .trailing, spacing: 3) {
                                    Text("+\(selectedMiniGame.baseCoins + min(comboCount, 4) * 2)")
                                        .font(.system(size: 18, weight: .black, design: .rounded))
                                    Text("coin")
                                        .font(.system(size: 11, weight: .bold, design: .rounded))
                                        .foregroundStyle(Color.white.opacity(0.82))
                                }
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [selectedMiniGame.tint, selectedMiniGame.tint.opacity(0.78)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                in: RoundedRectangle(cornerRadius: 28, style: .continuous)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 28, style: .continuous)
                                    .stroke(Color.white.opacity(0.22), lineWidth: 1)
                            )
                            .shadow(color: selectedMiniGame.tint.opacity(0.24), radius: 16, y: 8)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, compact ? 14 : 20)
                    .padding(.top, compact ? 14 : 18)
                    .padding(.bottom, 20)
                }
            }
        }
        .sheet(item: $activeMiniGame) { game in
            MiniGamePlayView(
                game: game,
                comboCount: comboCount
            ) { playedGame in
                play(game: playedGame)
            }
        }
    }

    private var gamesHeader: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Label("Giochi", systemImage: "gamecontroller.fill")
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundStyle(Color(hex: "#BC6A42"))
                Text("Mini attività rapide per guadagnare coin e migliorare il pet.")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(hex: "#97715A"))
            }

            Spacer()

            Text("Arcade soft")
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundStyle(Color(hex: "#BC6A42"))
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(Color.white.opacity(0.92), in: Capsule())
        }
    }

    private var featuredGameCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(selectedMiniGame.title)
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundStyle(Color(hex: "#72452A"))
                    Text(selectedMiniGame.subtitle)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(hex: "#8A654A"))
                }
                Spacer()
                gameLogo(for: selectedMiniGame, size: 76, selected: true)
            }

            Text(selectedMiniGame.longDescription)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(hex: "#8C6A54"))

            HStack(spacing: 8) {
                perkChip(text: selectedMiniGame.rewardTag, tint: selectedMiniGame.tint)
                perkChip(text: selectedMiniGame.styleTag, tint: selectedMiniGame.logoTint)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            LinearGradient(
                colors: [Color.white.opacity(0.96), selectedMiniGame.surfaceTint],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 30, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(Color.white.opacity(0.7), lineWidth: 1)
        )
        .shadow(color: selectedMiniGame.tint.opacity(0.10), radius: 14, y: 8)
    }

    private func gameSelectionCard(for game: MiniGameDefinition) -> some View {
        let selected = selectedMiniGame == game

        return Button {
            withAnimation(.snappy(duration: 0.18)) {
                selectedMiniGame = game
            }
            activeMiniGame = game
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    gameLogo(for: game, size: 56, selected: selected)
                    Spacer()
                    Text(game.badgeText)
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .foregroundStyle(selected ? game.logoTint : Color.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            selected ? Color.white : game.logoTint,
                            in: Capsule()
                        )
                }

                Text(game.title)
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundStyle(selected ? .white : Color(hex: "#6F472D"))

                Text(game.cardLine)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(selected ? Color.white.opacity(0.84) : Color(hex: "#95735D"))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        selected
                            ? AnyShapeStyle(
                                LinearGradient(
                                    colors: [game.tint, game.tint.opacity(0.78)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            : AnyShapeStyle(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.98), game.surfaceTint],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(selected ? Color.white.opacity(0.2) : game.tint.opacity(0.12), lineWidth: 1)
            )
            .shadow(color: selected ? game.tint.opacity(0.20) : Color.black.opacity(0.04), radius: 10, y: 5)
        }
        .buttonStyle(.plain)
    }

    private func gameLogo(for game: MiniGameDefinition, size: CGFloat, selected: Bool) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                .fill(selected ? Color.white.opacity(0.18) : game.logoTint.opacity(0.14))
                .frame(width: size, height: size)

            VStack(spacing: 4) {
                Image(systemName: game.icon)
                    .font(.system(size: size * 0.34, weight: .black))
                    .foregroundStyle(selected ? .white : game.logoTint)
                Text(game.logoText)
                    .font(.system(size: size * 0.15, weight: .black, design: .rounded))
                    .foregroundStyle(selected ? Color.white.opacity(0.86) : game.logoTint)
                    .tracking(0.6)
            }
        }
    }

    private func statBadge(icon: String, title: String, value: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .black))
                Text(title)
                    .font(.system(size: 10, weight: .black, design: .rounded))
            }
            Text(value)
                .font(.system(size: 15, weight: .black, design: .rounded))
        }
        .foregroundStyle(tint)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.92), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func perkChip(text: String, tint: Color) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .black, design: .rounded))
            .foregroundStyle(tint)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(tint.opacity(0.10), in: Capsule())
    }

    private func playSelectedGame() {
        play(game: selectedMiniGame)
    }

    private func play(game: MiniGameDefinition) {
        let comboBonus = min(comboCount, 4) * 2
        let coins = game.baseCoins + comboBonus

        switch game {
        case .cloverHunt:
            store.applyBoost(hunger: 0, happiness: 0.10, calm: -0.10, energy: -0.02)
        case .bugChase:
            store.applyBoost(hunger: 0, happiness: 0.16, calm: -0.16, energy: -0.08)
        }

        houseStore.rewardCoins(coins)
        comboCount += 1

        withAnimation(.snappy(duration: 0.2)) {
            rewardMessage = "\(game.title): +\(coins) coin, calma \(game.calmImpactLabel)"
        }

        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.8))
            withAnimation(.easeOut(duration: 0.2)) {
                rewardMessage = nil
            }
        }
    }
}

private struct MiniGamePlayView: View {
    let game: MiniGameDefinition
    let comboCount: Int
    let onPlay: (MiniGameDefinition) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var hasPlayed = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.white, game.surfaceTint, game.surfaceTint.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                HStack {
                    Button("Chiudi") { dismiss() }
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(game.logoTint)

                    Spacer()

                    Text(game.badgeText)
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(game.logoTint, in: Capsule())
                }

                ZStack {
                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [game.tint.opacity(0.18), game.logoTint.opacity(0.10)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 240)

                    VStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.92))
                                .frame(width: 106, height: 106)
                            Image(systemName: game.icon)
                                .font(.system(size: 40, weight: .black))
                                .foregroundStyle(game.logoTint)
                        }

                        Text(game.title)
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundStyle(Color(hex: "#6F472D"))

                        Text(game.longDescription)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color(hex: "#8C6A54"))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 22)
                    }
                }

                HStack(spacing: 12) {
                    miniGameInfo(title: "Reward", value: "+\(game.baseCoins + min(comboCount, 4) * 2) coin", tint: game.tint)
                    miniGameInfo(title: "Style", value: game.styleTag, tint: game.logoTint)
                    miniGameInfo(title: "Calm", value: game.calmImpactLabel, tint: Color(hex: "#D36F8E"))
                }

                Button {
                    guard !hasPlayed else { return }
                    hasPlayed = true
                    onPlay(game)
                } label: {
                    Text(hasPlayed ? "Giocato" : game.actionTitle)
                        .font(.system(size: 17, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [game.tint, game.tint.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            in: RoundedRectangle(cornerRadius: 24, style: .continuous)
                        )
                }
                .buttonStyle(.plain)
                .disabled(hasPlayed)

                Spacer()
            }
            .padding(.horizontal, 22)
            .padding(.top, 18)
            .padding(.bottom, 24)
        }
    }

    private func miniGameInfo(title: String, value: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.system(size: 10, weight: .black, design: .rounded))
            Text(value)
                .font(.system(size: 13, weight: .black, design: .rounded))
        }
        .foregroundStyle(tint)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private enum MiniGameDefinition: CaseIterable, Identifiable {
    case cloverHunt
    case bugChase

    var id: String { title }

    var title: String {
        switch self {
        case .cloverHunt: "Cerca trifogli"
        case .bugChase: "Lucciole sprint"
        }
    }

    var subtitle: String {
        switch self {
        case .cloverHunt: "Un gioco calmo per trovare fortuna e far respirare il pet."
        case .bugChase: "Una corsa luminosa per fare punti e alzare l'energia emotiva."
        }
    }

    var longDescription: String {
        switch self {
        case .cloverHunt: "Cerca i trifogli fortunati nel prato. Ricompensa soft, ritmo lento e bonus su calma e felicita."
        case .bugChase: "Segui le lucciole tra i sentieri. Ricompensa piu alta, ma il pet spende un po' di energia."
        }
    }

    var cardLine: String {
        switch self {
        case .cloverHunt: "Coin leggere, mood piu sereno"
        case .bugChase: "Più reward, ritmo piu attivo"
        }
    }

    var actionTitle: String {
        switch self {
        case .cloverHunt: "Gioca a Cerca trifogli"
        case .bugChase: "Gioca a Lucciole sprint"
        }
    }

    var rewardLine: String {
        switch self {
        case .cloverHunt: "Bonus calm + happiness"
        case .bugChase: "Più coin, energia in cambio"
        }
    }

    var rewardTag: String {
        switch self {
        case .cloverHunt: "Relax reward"
        case .bugChase: "Sprint reward"
        }
    }

    var calmImpactLabel: String {
        switch self {
        case .cloverHunt: "-10%"
        case .bugChase: "-16%"
        }
    }

    var styleTag: String {
        switch self {
        case .cloverHunt: "Soft play"
        case .bugChase: "Fast play"
        }
    }

    var icon: String {
        switch self {
        case .cloverHunt: "leaf.fill"
        case .bugChase: "sparkles"
        }
    }

    var logoText: String {
        switch self {
        case .cloverHunt: "CLOVER"
        case .bugChase: "LIGHT"
        }
    }

    var badgeText: String {
        switch self {
        case .cloverHunt: "LV"
        case .bugChase: "GO"
        }
    }

    var baseCoins: Int {
        switch self {
        case .cloverHunt: 10
        case .bugChase: 14
        }
    }

    var tint: Color {
        switch self {
        case .cloverHunt: Color(hex: "#7DBA57")
        case .bugChase: Color(hex: "#E48A5B")
        }
    }

    var logoTint: Color {
        switch self {
        case .cloverHunt: Color(hex: "#4E8B3A")
        case .bugChase: Color(hex: "#C8614D")
        }
    }

    var surfaceTint: Color {
        switch self {
        case .cloverHunt: Color(hex: "#F3FAEB")
        case .bugChase: Color(hex: "#FFF1E8")
        }
    }
}

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
            LinearGradient(
                colors: [Color(hex: "#EEF4FF"), Color(hex: "#F7EEFF")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 4) {
                        Label("Zaino", systemImage: "backpack.fill")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundStyle(Color(hex: "#365B9C"))
                        Text("Usa consumabili o prepara gli oggetti da stanza")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color(hex: "#6E85B7"))
                    }

                    Spacer()

                    Text("\(houseStore.inventory.reduce(0) { $0 + $1.quantity }) ogg.")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(hex: "#365B9C"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.white.opacity(0.9), in: Capsule())
                }
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
        Button(action: action) {
            HStack(spacing: 6) {
                Text(emoji)
                Text(title)
            }
            .font(.system(size: 13, weight: .bold, design: .rounded))
            .foregroundStyle(selected ? .white : Color(hex: "#5D6DAA"))
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                selected
                    ? LinearGradient(
                        colors: [Color(hex: "#7C8BFF"), Color(hex: "#5CA5F3")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    : LinearGradient(
                        colors: [Color.white.opacity(0.95), Color(hex: "#F4F7FF")],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                in: Capsule()
            )
            .overlay(
                Capsule()
                    .stroke(selected ? Color.white.opacity(0.2) : Color(hex: "#D6E2FF"), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
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
                        .foregroundStyle(Color(hex: "#3E356B"))
                    Spacer()
                    Text("x\(ownedItem.quantity)")
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundStyle(Color(hex: "#6E59A5"))
                }

                Text(definition.description)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(hex: "#7C7A9A"))
                    .lineLimit(2)

                HStack(spacing: 8) {
                    badge(text: definition.category.displayName, tint: Color(hex: "#B8A6F7"))
                    if ownedItem.isPlacedInRoom {
                        badge(text: "In stanza", tint: Color(hex: "#8FD5B6"))
                    } else if definition.isConsumable {
                        badge(text: "Consumabile", tint: Color(hex: "#F7B0A8"))
                    } else if definition.isPlaceable {
                        badge(text: "Posizionabile", tint: Color(hex: "#9CC7FF"))
                    }
                }
            }

            VStack(spacing: 8) {
                if definition.isConsumable {
                    Button("Usa") {
                        _ = houseStore.useItem(ownedItem, on: gameStore)
                    }
                    .buttonStyle(InventoryActionButtonStyle(color: Color(hex: "#60A5FA")))
                }

                if definition.isPlaceable {
                    Button(ownedItem.isPlacedInRoom ? "Sposta" : "Decora") {
                        navigationState.activeSection = .decorate
                    }
                    .buttonStyle(InventoryActionButtonStyle(color: Color(hex: "#A78BFA")))
                }
            }
        }
        .padding(14)
        .background(.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.7), lineWidth: 1)
        )
        .shadow(color: Color(hex: "#AFC3EC").opacity(0.18), radius: 12, y: 6)
        .padding(.horizontal, 18)
    }

    private func badge(text: String, tint: Color) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .foregroundStyle(Color(hex: "#4D4870"))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(tint.opacity(0.35), in: Capsule())
    }
}

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
            LinearGradient(
                colors: [Color(hex: "#F7EEFF"), Color(hex: "#FCEFD9")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
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
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Decora")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(Color(hex: "#7C4FCB"))
                    Text("Gestisci gli arredi già acquistati e la loro posizione")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(hex: "#9A79D4"))
                }

                Spacer()

                Text("\(houseStore.itemsPlacedInRoom().count) attivi")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: "#7C4FCB"))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.white.opacity(0.92), in: Capsule())
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach([ItemCategory.essentials, .decorations, .specials], id: \.rawValue) { category in
                        Button {
                            withAnimation(.snappy(duration: 0.2)) {
                                selectedCategory = category
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Text(category.emoji)
                                Text(category.displayName)
                            }
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(selectedCategory == category ? .white : Color(hex: "#7A68A8"))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(selectedCategory == category ? Color(hex: "#A78BFA") : .white.opacity(0.88), in: Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            HStack(spacing: 12) {
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color(hex: "#A78BFA"))
                    .frame(width: 38, height: 38)
                    .background(.white.opacity(0.92), in: Circle())

                VStack(alignment: .leading, spacing: 3) {
                    Text("Tocca per arredare")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(hex: "#5D427E"))
                    Text("Ogni arredo attivo dona un piccolo bonus di benessere al pet e cambia il mood della stanza.")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(hex: "#8C76A8"))
                }

                Spacer()
            }
            .padding(14)
            .background(.white.opacity(0.82), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
        .padding(.horizontal, 18)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background(
            LinearGradient(
                colors: [Color(hex: "#F7EEFF"), Color(hex: "#F7EEFF").opacity(0.94)],
                startPoint: .top,
                endPoint: .bottom
            )
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
                        .foregroundStyle(Color(hex: "#4B356C"))
                    Spacer()
                    Text(ownedItem.isPlacedInRoom ? "Attivo" : "Disponibile")
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundStyle(ownedItem.isPlacedInRoom ? Color(hex: "#3A8E6D") : Color(hex: "#7B5CC8"))
                }

                Text(definition.description)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(hex: "#84779C"))
                    .lineLimit(2)

                Text(positionDescription(for: ownedItem))
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: "#A087C8"))
            }

            VStack(spacing: 8) {
                Button(ownedItem.isPlacedInRoom ? "Rimuovi" : "Posiziona") {
                    if ownedItem.isPlacedInRoom {
                        houseStore.removeFromRoom(item: ownedItem, on: gameStore)
                    } else {
                        houseStore.place(item: ownedItem, at: suggestedPosition(for: definition), on: gameStore)
                    }
                }
                .buttonStyle(InventoryActionButtonStyle(color: ownedItem.isPlacedInRoom ? Color(hex: "#F87171") : Color(hex: "#A78BFA")))
            }
        }
        .padding(14)
        .background(.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .padding(.horizontal, 18)
    }

    private func suggestedPosition(for definition: HouseItemDefinition) -> CGPoint {
        switch definition.id {
        case "essential_bowl":    return CGPoint(x: -70, y: 12)
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
                .buttonStyle(InventoryActionButtonStyle(color: Color(hex: "#A78BFA")))
        }
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
    case .common:    return "#E9E5FF"
    case .rare:      return "#E2D4FF"
    case .legendary: return "#FFE6BE"
    }
}
