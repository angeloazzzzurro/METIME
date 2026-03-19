import SwiftUI
import SpriteKit
import SwiftData

// MARK: - HouseView

struct HouseView: View {

    @EnvironmentObject var gameStore: GameStore
    @EnvironmentObject var houseStore: HouseStore
    @EnvironmentObject private var navigationState: NavigationState

    @State private var scene: HouseScene = {
        let s = HouseScene()
        s.size = CGSize(width: 350, height: 500)
        s.scaleMode = .resizeFill
        return s
    }()

    @State private var showInventory = false
    @State private var selectedItem: OwnedItem? = nil
    @State private var showUseConfirm = false
    @State private var roomSize: CGSize = CGSize(width: 390, height: 520)
    @State private var floatingDecorPhase = false
    @State private var roomZoom: CGFloat = 1.15
    @State private var pinchZoom: CGFloat = 1.0
    @State private var roomPan: CGSize = .zero
    @State private var dragPan: CGSize = .zero

    var body: some View {
        GeometryReader { proxy in
            let safeTop = proxy.safeAreaInsets.top
            let safeBottom = max(proxy.safeAreaInsets.bottom, 10)
            let metrics = layoutMetrics(for: proxy.size, safeTop: safeTop, safeBottom: safeBottom)

            ZStack {
                houseBackground
                    .ignoresSafeArea()

                backgroundDecorations(in: proxy.size)

                if metrics.usesWideLayout {
                    VStack(spacing: 0) {
                        HStack(alignment: .top, spacing: metrics.horizontalPadding) {
                            VStack(spacing: 0) {
                                topBar(safeTop: safeTop, metrics: metrics)

                                actionButtonsBar(compact: true, metrics: metrics)
                                    .padding(.horizontal, metrics.horizontalPadding)
                                    .padding(.top, 8)

                                Spacer(minLength: 0)
                            }
                            .frame(width: metrics.sidePanelWidth, alignment: .top)

                            roomStage(width: metrics.stageWidth, roomHeight: metrics.roomHeight, metrics: metrics)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                .padding(.top, max(safeTop, metrics.stageTopPadding))
                        }
                        .padding(.horizontal, metrics.horizontalPadding)

                        bottomTabBar(bottomInset: safeBottom, metrics: metrics)
                    }
                } else {
                    VStack(spacing: 0) {
                        topBar(safeTop: safeTop, metrics: metrics)

                        roomStage(width: metrics.stageWidth, roomHeight: metrics.roomHeight, metrics: metrics)
                            .padding(.top, metrics.stageTopPadding)

                        Spacer(minLength: metrics.contentSpacing)

                        actionButtonsBar(compact: metrics.compactActions, metrics: metrics)
                            .padding(.horizontal, metrics.horizontalPadding)
                            .padding(.bottom, metrics.actionsBottomPadding)

                        bottomTabBar(bottomInset: safeBottom, metrics: metrics)
                    }
                }
            }
            .onAppear {
                floatingDecorPhase = true
                syncScene(stageWidth: metrics.stageWidth, roomHeight: metrics.roomHeight)
            }
            .onChange(of: proxy.size) { _, newSize in
                let updatedMetrics = layoutMetrics(for: newSize, safeTop: safeTop, safeBottom: safeBottom)
                syncScene(
                    stageWidth: updatedMetrics.stageWidth,
                    roomHeight: updatedMetrics.roomHeight
                )
            }
            .onChange(of: gameStore.pet.moodRaw) { _, newVal in
                if let mood = PetMood(rawValue: newVal) {
                    scene.mood = mood
                }
            }
            .onChange(of: gameStore.pet.colorIndex) { _, newValue in
                scene.petColor = PetColor(rawValue: newValue) ?? .cream
            }
            .onChange(of: gameStore.pet.stage) { _, newValue in
                scene.petStage = newValue
            }
            .onChange(of: houseStore.itemsPlacedInRoom()) { _, placed in
                scene.placedItems = placed.compactMap { item in
                    guard let x = item.roomPositionX,
                          let y = item.roomPositionY else { return nil }
                    return (itemID: item.itemID, position: CGPoint(x: x, y: y))
                }
            }
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

    private func topBar(safeTop: CGFloat, metrics: HouseLayoutMetrics) -> some View {
        VStack(spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Image(systemName: "house.fill")
                            .font(.system(size: metrics.titleIconSize, weight: .black))
                        Text("La tua Casa")
                            .font(.system(size: metrics.titleFontSize, weight: .black, design: .rounded))
                    }
                    .foregroundStyle(.white)
                    .shadow(color: Color(hex: "#7B57C8").opacity(0.92), radius: 0, x: 2, y: 2)
                    .shadow(color: Color(hex: "#7B57C8").opacity(0.35), radius: 8, y: 3)

                    Text("Uno spazio cozy per \(gameStore.pet.sanitizedName)")
                        .font(.system(size: metrics.subtitleFontSize, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.88))
                }

                Spacer()

                HStack(spacing: 8) {
                    currencyBadge(icon: "🪙", value: houseStore.wallet.coins,
                                  bg: Color(hex: "#F5C842"), fg: Color(hex: "#3B2063"))
                    currencyBadge(icon: "💎", value: houseStore.wallet.gems,
                                  bg: Color(hex: "#9F7AEA"), fg: .white)
                }
            }

            HStack(spacing: 10) {
                houseInfoChip(
                    icon: "sparkles",
                    title: "Mood",
                    value: gameStore.pet.mood.rawValue.capitalized,
                    tint: Color(hex: "#F19BC5"),
                    metrics: metrics
                )
                houseInfoChip(
                    icon: "leaf.fill",
                    title: "Stage",
                    value: stageLabel,
                    tint: Color(hex: "#76C893"),
                    metrics: metrics
                )
            }
        }
        .padding(.horizontal, metrics.horizontalPadding)
        .padding(.top, max(12, safeTop + 4))
        .padding(.bottom, metrics.headerBottomPadding)
    }

    private func currencyBadge(icon: String, value: Int, bg: Color, fg: Color) -> some View {
        HStack(spacing: 4) {
            Text(icon).font(.system(size: 14))
            Text("\(value)")
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundColor(fg)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(bg)
        )
        .clipShape(Capsule())
        .shadow(color: bg.opacity(0.28), radius: 5, y: 3)
    }

    private func houseInfoChip(icon: String, title: String, value: String, tint: Color, metrics: HouseLayoutMetrics) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: metrics.infoIconSize, weight: .black))
                .foregroundStyle(tint)
                .frame(width: metrics.infoBadgeSize, height: metrics.infoBadgeSize)
                .background(Color.white.opacity(0.28), in: Circle())

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: metrics.infoCaptionSize, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.72))
                Text(value)
                    .font(.system(size: metrics.infoValueSize, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
            }
        }
        .padding(.horizontal, metrics.infoHorizontalPadding)
        .padding(.vertical, metrics.infoVerticalPadding)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.14))
        )
    }

    // MARK: - Action Buttons Bar

    private func actionButtonsBar(compact: Bool, metrics: HouseLayoutMetrics) -> some View {
        Group {
            if compact {
                VStack(spacing: metrics.actionSpacing) {
                    HStack(spacing: metrics.actionSpacing) {
                        actionPill(icon: "bag.fill", label: "Store", color: Color(hex: "#E985A7"), metrics: metrics) {
                            navigationState.navigate(to: .store)
                        }
                        actionPill(icon: "backpack.fill", label: "Zaino", color: Color(hex: "#6D98E8"), metrics: metrics) { showInventory = true }
                    }
                    actionPill(icon: "wand.and.stars", label: "Decora", color: Color(hex: "#9C7EE6"), metrics: metrics) { }
                }
            } else {
                HStack(spacing: metrics.actionSpacing) {
                    actionPill(icon: "bag.fill", label: "Store", color: Color(hex: "#E985A7"), metrics: metrics) {
                        navigationState.navigate(to: .store)
                    }
                    actionPill(icon: "backpack.fill", label: "Zaino", color: Color(hex: "#6D98E8"), metrics: metrics) { showInventory = true }
                    actionPill(icon: "wand.and.stars", label: "Decora", color: Color(hex: "#9C7EE6"), metrics: metrics) { }
                }
            }
        }
        .padding(metrics.actionsContainerPadding)
        .background(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.96), Color(hex: "#FFF4FE").opacity(0.92)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .shadow(color: Color(hex: "#8A70CC").opacity(0.12), radius: 22, y: 10)
    }

    private func actionPill(icon: String, label: String, color: Color, metrics: HouseLayoutMetrics, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 7) {
                Image(systemName: icon)
                    .font(.system(size: metrics.actionIconSize, weight: .black))
                    .frame(width: metrics.actionBadgeSize, height: metrics.actionBadgeSize)
                    .background(Color.white.opacity(0.22), in: Circle())
                Text(label)
                    .font(.system(size: metrics.actionTextSize, weight: .black, design: .rounded))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: metrics.actionHeight)
            .background(
                LinearGradient(
                    colors: [color.opacity(0.82), color],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: color.opacity(0.22), radius: 5, y: 3)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Bottom Tab Bar

    private func bottomTabBar(bottomInset: CGFloat, metrics: HouseLayoutMetrics) -> some View {
        HStack(spacing: 0) {
            tabButton(icon: "leaf.fill",  label: "Giardino", active: false, metrics: metrics) {
                navigationState.navigate(to: .garden)
            }
            tabButton(icon: "house.fill", label: "Casa",     active: true, metrics: metrics) { }
        }
        .frame(height: metrics.tabBarHeight + bottomInset)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.white.opacity(0.97))
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private func tabButton(icon: String, label: String, active: Bool, metrics: HouseLayoutMetrics, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: metrics.tabIconSize))
                    .foregroundColor(active ? Color(hex: "#7B57C8") : Color.gray.opacity(0.5))
                Text(label)
                    .font(.system(size: metrics.tabTextSize, weight: .semibold, design: .rounded))
                    .foregroundColor(active ? Color(hex: "#7B57C8") : Color.gray.opacity(0.5))
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Background Decorations

    private func backgroundDecorations(in size: CGSize) -> some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.28))
                .frame(width: 260, height: 260)
                .blur(radius: 40)
                .offset(x: -size.width * 0.18, y: -size.height * 0.18)

            Circle()
                .fill(Color(hex: "#F7D8E9").opacity(0.26))
                .frame(width: 220, height: 220)
                .blur(radius: 36)
                .offset(x: size.width * 0.25, y: size.height * 0.06)

            RoundedRectangle(cornerRadius: 60, style: .continuous)
                .fill(Color.white.opacity(0.10))
                .frame(width: size.width * 0.74, height: 120)
                .blur(radius: 10)
                .offset(y: size.height * 0.12)

            ForEach(Array(houseBackgroundIcons.enumerated()), id: \.offset) { index, item in
                Text(item.symbol)
                    .font(.system(size: item.size))
                    .foregroundStyle(item.color)
                    .opacity(item.opacity)
                    .scaleEffect(floatingDecorPhase ? item.maxScale : item.minScale)
                    .position(x: size.width * item.x, y: size.height * item.y)
                    .animation(
                        .easeInOut(duration: item.duration)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.08),
                        value: floatingDecorPhase
                    )
            }
        }
    }

    private func roomStage(width: CGFloat, roomHeight: CGFloat, metrics: HouseLayoutMetrics) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 36, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.64),
                            Color(hex: "#F9F1FF").opacity(0.24)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                        )
                )

            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.30),
                            Color(hex: "#FFF3FB").opacity(0.08)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .padding(12)

            SpriteView(scene: scene, options: [.allowsTransparency])
                .frame(width: width - 8, height: roomHeight - 8)
                .scaleEffect(currentZoom)
                .offset(currentPan)
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .simultaneousGesture(zoomGesture)
                .simultaneousGesture(panGesture)
                .onTapGesture(count: 2) {
                    withAnimation(.spring(duration: 0.28)) {
                        roomZoom *= 1.2
                    }
                }

            VStack(alignment: .leading, spacing: 8) {
                Text("Angolo del pet")
                    .font(.system(size: metrics.stageTitleSize, weight: .black, design: .rounded))
                    .foregroundStyle(Color(hex: "#7D58C9"))
                Text("Interagisci con la stanza e personalizza il suo rifugio.")
                    .font(.system(size: metrics.stageSubtitleSize, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(hex: "#9B88C8"))
            }
            .padding(.horizontal, metrics.stageBadgeHorizontalPadding)
            .padding(.vertical, metrics.stageBadgeVerticalPadding)
            .background(.white.opacity(0.82), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .padding(metrics.stageOverlayPadding)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

            VStack(alignment: .leading, spacing: 4) {
                Text("Stanza Cozy")
                    .font(.system(size: metrics.stageHintTitleSize, weight: .black, design: .rounded))
                    .foregroundStyle(Color(hex: "#7D58C9"))
                Text("Tocca il pet, trascina la scena e prova lo zoom")
                    .font(.system(size: metrics.stageHintSubtitleSize, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(hex: "#9B88C8"))
            }
            .padding(.horizontal, metrics.stageBadgeHorizontalPadding)
            .padding(.vertical, metrics.stageHintVerticalPadding)
            .background(.white.opacity(0.82), in: Capsule())
            .padding(metrics.stageOverlayPadding)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)

            zoomControls
                .padding(metrics.stageOverlayPadding)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        }
        .frame(width: width, height: roomHeight)
        .frame(height: roomHeight)
        .clipped()
        .shadow(color: Color(hex: "#8A70CC").opacity(0.20), radius: 22, y: 10)
    }

    private func updateSceneSize(to size: CGSize) {
        guard roomSize != size else { return }
        roomSize = size
        scene.size = size
    }

    private func syncScene(stageWidth: CGFloat, roomHeight: CGFloat) {
        updateSceneSize(to: CGSize(width: stageWidth, height: roomHeight))
        scene.mood = gameStore.pet.mood
        scene.petColor = PetColor(rawValue: gameStore.pet.colorIndex) ?? .cream
        scene.petStage = gameStore.pet.stage
        scene.placedItems = houseStore.itemsPlacedInRoom().compactMap { item in
            guard let x = item.roomPositionX,
                  let y = item.roomPositionY else { return nil }
            return (itemID: item.itemID, position: CGPoint(x: x, y: y))
        }
    }

    private func houseRoomHeight(for screenHeight: CGFloat, safeTop: CGFloat, safeBottom: CGFloat) -> CGFloat {
        let availableHeight = screenHeight - safeTop - safeBottom
        return min(max(availableHeight * 0.66, 420), 680)
    }

    private func houseStageWidth(for screenWidth: CGFloat) -> CGFloat {
        min(max(screenWidth * 0.98, 360), 560)
    }

    private var currentZoom: CGFloat {
        roomZoom * pinchZoom
    }

    private var currentPan: CGSize {
        CGSize(width: roomPan.width + dragPan.width, height: roomPan.height + dragPan.height)
    }

    private var zoomGesture: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                pinchZoom = value.magnification
            }
            .onEnded { value in
                roomZoom *= value.magnification
                pinchZoom = 1.0
            }
    }

    private var panGesture: some Gesture {
        DragGesture(minimumDistance: 4)
            .onChanged { value in
                dragPan = value.translation
            }
            .onEnded { value in
                roomPan = CGSize(
                    width: roomPan.width + value.translation.width,
                    height: roomPan.height + value.translation.height
                )
                dragPan = .zero
            }
    }

    private var zoomControls: some View {
        VStack(spacing: 10) {
            zoomButton(systemName: "plus") {
                withAnimation(.spring(duration: 0.22)) {
                    roomZoom += 0.15
                }
            }

            zoomButton(systemName: "minus") {
                withAnimation(.spring(duration: 0.22)) {
                    roomZoom = max(0.25, roomZoom - 0.15)
                }
            }

            zoomButton(systemName: "arrow.counterclockwise") {
                withAnimation(.spring(duration: 0.22)) {
                    roomZoom = 1.15
                    pinchZoom = 1.0
                    roomPan = .zero
                    dragPan = .zero
                }
            }
        }
    }

    private func zoomButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 14, weight: .black))
                .foregroundStyle(Color(hex: "#7B57C8"))
                .frame(width: 38, height: 38)
                .background(Color.white.opacity(0.94), in: Circle())
                .overlay(Circle().stroke(Color(hex: "#E8D8FA"), lineWidth: 1.2))
                .shadow(color: Color(hex: "#8A70CC").opacity(0.18), radius: 6, y: 3)
        }
        .buttonStyle(.plain)
    }

    private var houseBackgroundIcons: [(symbol: String, x: CGFloat, y: CGFloat, size: CGFloat, opacity: Double, minScale: CGFloat, maxScale: CGFloat, duration: Double, color: Color)] {
        [
            ("✦", 0.16, 0.18, 20, 0.55, 0.92, 1.08, 2.6, Color(hex: "#FFF4A8")),
            ("★", 0.84, 0.19, 22, 0.54, 0.88, 1.14, 2.8, Color(hex: "#FFE487")),
            ("♥", 0.80, 0.13, 16, 0.34, 0.94, 1.12, 2.3, .white),
            ("✦", 0.10, 0.26, 18, 0.48, 0.90, 1.15, 2.4, Color(hex: "#FFF1A0")),
            ("•", 0.07, 0.32, 18, 0.26, 0.95, 1.05, 2.9, .white),
            ("✧", 0.87, 0.27, 14, 0.30, 0.92, 1.08, 2.7, .white),
            ("★", 0.08, 0.58, 22, 0.55, 0.88, 1.12, 2.5, Color(hex: "#FFE487")),
            ("♥", 0.18, 0.72, 14, 0.36, 0.90, 1.10, 3.1, .white),
            ("✧", 0.12, 0.84, 12, 0.28, 0.96, 1.06, 2.2, .white),
            ("•", 0.83, 0.69, 15, 0.25, 0.94, 1.05, 2.6, .white),
            ("★", 0.89, 0.54, 18, 0.38, 0.92, 1.12, 2.8, Color(hex: "#FFF0A2"))
        ]
    }

    private var houseBackground: some View {
        LinearGradient(
            colors: [
                Color(hex: "#F9C7D8"),
                Color(hex: "#E8D2F5"),
                Color(hex: "#CFC4F2")
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var stageLabel: String {
        switch gameStore.pet.stage {
        case ..<1: return "Cucciolo"
        case 1: return "Germoglio"
        case 2: return "Bloom"
        case 3: return "Magico"
        default: return "Evoluto"
        }
    }

    private func layoutMetrics(for size: CGSize, safeTop: CGFloat, safeBottom: CGFloat) -> HouseLayoutMetrics {
        let isLandscape = size.width > size.height
        let isNarrowPhone = size.width < 390
        let isLargeScreen = size.width >= 700
        let usesWideLayout = isLandscape && size.width >= 600
        let basePadding = max(14, min(size.width * 0.045, 24))
        let availableHeight = size.height - safeTop - safeBottom

        let roomHeight: CGFloat
        if usesWideLayout {
            roomHeight = min(max(availableHeight * 0.72, 520), 860)
        } else if isLandscape {
            roomHeight = min(max(availableHeight * 0.50, 230), 360)
        } else if isNarrowPhone {
            roomHeight = min(max(availableHeight * 0.52, 340), 520)
        } else {
            roomHeight = min(max(availableHeight * (isLargeScreen ? 0.68 : 0.58), isLargeScreen ? 520 : 390), isLargeScreen ? 860 : 620)
        }

        let stageWidth: CGFloat
        if usesWideLayout {
            let sidePanelWidth = min(max(size.width * 0.27, 280), 360)
            stageWidth = max(size.width - sidePanelWidth - (basePadding * 3), 620)
        } else if isLandscape {
            stageWidth = min(max(size.width * 0.62, 360), 540)
        } else {
            stageWidth = min(max(size.width * (isLargeScreen ? 0.88 : 0.96), isLargeScreen ? 700 : 330), isLargeScreen ? 980 : 560)
        }

        return HouseLayoutMetrics(
            isLandscape: isLandscape,
            isLargeScreen: isLargeScreen,
            usesWideLayout: usesWideLayout,
            horizontalPadding: basePadding,
            sidePanelWidth: usesWideLayout ? min(max(size.width * 0.27, 280), 360) : 0,
            headerBottomPadding: isLandscape ? 8 : 14,
            titleIconSize: isLargeScreen ? 26 : (isLandscape ? 20 : (isNarrowPhone ? 22 : 24)),
            titleFontSize: isLargeScreen ? 28 : (isLandscape ? 22 : (isNarrowPhone ? 23 : 24)),
            subtitleFontSize: isLargeScreen ? 14 : (isLandscape ? 10 : 12),
            infoIconSize: isLargeScreen ? 14 : (isLandscape ? 11 : 13),
            infoBadgeSize: isLargeScreen ? 32 : (isLandscape ? 24 : 28),
            infoCaptionSize: isLargeScreen ? 11 : (isLandscape ? 9 : 10),
            infoValueSize: isLargeScreen ? 14 : (isLandscape ? 11 : 12),
            infoHorizontalPadding: isLargeScreen ? 14 : (isLandscape ? 10 : 12),
            infoVerticalPadding: isLargeScreen ? 10 : (isLandscape ? 7 : 9),
            roomHeight: roomHeight,
            stageWidth: stageWidth,
            stageTopPadding: isLargeScreen ? 10 : (isLandscape ? 4 : 8),
            stageOverlayPadding: isLargeScreen ? 24 : (isLandscape ? 12 : 18),
            stageTitleSize: isLargeScreen ? 18 : (isLandscape ? 13 : 15),
            stageSubtitleSize: isLargeScreen ? 13 : (isLandscape ? 10 : 11),
            stageHintTitleSize: isLargeScreen ? 16 : (isLandscape ? 12 : 13),
            stageHintSubtitleSize: isLargeScreen ? 13 : (isLandscape ? 10 : 11),
            stageBadgeHorizontalPadding: isLargeScreen ? 18 : (isLandscape ? 12 : 16),
            stageBadgeVerticalPadding: isLargeScreen ? 14 : (isLandscape ? 10 : 12),
            stageHintVerticalPadding: isLargeScreen ? 12 : (isLandscape ? 8 : 10),
            compactActions: isLandscape || isNarrowPhone,
            actionsContainerPadding: isLargeScreen ? 14 : (isLandscape ? 10 : 12),
            actionSpacing: isLargeScreen ? 12 : (isLandscape ? 8 : 10),
            actionHeight: isLargeScreen ? 56 : (isLandscape ? 44 : 50),
            actionIconSize: isLargeScreen ? 15 : (isLandscape ? 12 : 14),
            actionBadgeSize: isLargeScreen ? 30 : (isLandscape ? 24 : 28),
            actionTextSize: isLargeScreen ? 14 : (isLandscape ? 12 : 13),
            actionsBottomPadding: isLargeScreen ? 20 : (isLandscape ? 10 : 18),
            contentSpacing: isLargeScreen ? 18 : (isLandscape ? 10 : 16),
            tabBarHeight: isLargeScreen ? 66 : (isLandscape ? 48 : 58),
            tabIconSize: isLargeScreen ? 24 : (isLandscape ? 18 : 22),
            tabTextSize: isLargeScreen ? 12 : (isLandscape ? 10 : 11)
        )
    }
}

private struct HouseLayoutMetrics {
    let isLandscape: Bool
    let isLargeScreen: Bool
    let usesWideLayout: Bool
    let horizontalPadding: CGFloat
    let sidePanelWidth: CGFloat
    let headerBottomPadding: CGFloat
    let titleIconSize: CGFloat
    let titleFontSize: CGFloat
    let subtitleFontSize: CGFloat
    let infoIconSize: CGFloat
    let infoBadgeSize: CGFloat
    let infoCaptionSize: CGFloat
    let infoValueSize: CGFloat
    let infoHorizontalPadding: CGFloat
    let infoVerticalPadding: CGFloat
    let roomHeight: CGFloat
    let stageWidth: CGFloat
    let stageTopPadding: CGFloat
    let stageOverlayPadding: CGFloat
    let stageTitleSize: CGFloat
    let stageSubtitleSize: CGFloat
    let stageHintTitleSize: CGFloat
    let stageHintSubtitleSize: CGFloat
    let stageBadgeHorizontalPadding: CGFloat
    let stageBadgeVerticalPadding: CGFloat
    let stageHintVerticalPadding: CGFloat
    let compactActions: Bool
    let actionsContainerPadding: CGFloat
    let actionSpacing: CGFloat
    let actionHeight: CGFloat
    let actionIconSize: CGFloat
    let actionBadgeSize: CGFloat
    let actionTextSize: CGFloat
    let actionsBottomPadding: CGFloat
    let contentSpacing: CGFloat
    let tabBarHeight: CGFloat
    let tabIconSize: CGFloat
    let tabTextSize: CGFloat
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

// MARK: - Preview

struct HouseView_Previews: PreviewProvider {
    static var previews: some View {
        let container = try! ModelContainer(for: Pet.self, PetNeeds.self, OwnedItem.self, Wallet.self,
                                            configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = container.mainContext
        HouseView()
            .environmentObject(GameStore(modelContext: context))
            .environmentObject(HouseStore(modelContext: context))
            .environmentObject(NavigationState())
            .modelContainer(container)
    }
}
