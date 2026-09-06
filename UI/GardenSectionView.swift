import SwiftUI
import SpriteKit

// MARK: - GardenSectionView

struct GardenSectionView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var store: GameStore
    @EnvironmentObject private var houseStore: HouseStore

    @State private var scene: GardenScene = {
        let s = GardenScene(size: UIScreen.main.bounds.size)
        s.scaleMode = .resizeFill
        return s
    }()
    @State private var gardenPurchaseMessage: String?

    var body: some View {
        GeometryReader { proxy in
            let compact = proxy.size.width < 430

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: compact ? 10 : 14) {
                    SpriteView(scene: scene, options: [.allowsTransparency])
                        .frame(maxWidth: .infinity)
                        .frame(height: compact ? min(max(proxy.size.height * 0.54, 320), 420) : min(max(proxy.size.height * 0.56, 360), 520))
                        .background(
                            RoundedRectangle(cornerRadius: compact ? 28 : 34, style: .continuous)
                                .fill(Color.white.opacity(0.08))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: compact ? 28 : 34, style: .continuous)
                                .stroke(Color.white.opacity(0.18), lineWidth: 1)
                        )
                        .overlay(alignment: .topLeading) {
                            gardenSceneHeader(compact: compact)
                                .padding(.leading, compact ? 14 : 18)
                                .padding(.top, compact ? 14 : 18)
                        }
                        .overlay(alignment: .topTrailing) {
                            gardenResourceStrip(compact: compact)
                                .padding(.trailing, compact ? 14 : 18)
                                .padding(.top, compact ? 14 : 18)
                        }
                        .overlay(alignment: .bottomLeading) {
                            gardenProgressOverlay(compact: compact)
                                .padding(.leading, compact ? 14 : 18)
                                .padding(.bottom, compact ? 14 : 18)
                        }
                        .overlay(alignment: .bottomTrailing) {
                            JoystickControl(
                                onMove: { vector in
                                    scene.setMovementVector(vector)
                                },
                                onEnd: {
                                    scene.stopMovement()
                                }
                            )
                            .padding(.trailing, compact ? 14 : 18)
                            .padding(.bottom, compact ? 14 : 18)
                        }
                        .clipped()
                        .padding(.horizontal, compact ? 12 : 18)
                        .padding(.top, compact ? 8 : 12)
                        .onAppear {
                            scene.mood = appState.mood
                            scene.applyPetColor(store.currentPetColor, animated: false)
                            scene.unlockedPlotCount = houseStore.unlockedGardenPlots
                            scene.terrainExpansionLevel = houseStore.gardenTerrainExpansionLevel
                        }
                        .onDisappear {
                            scene.stopMovement()
                        }
                        .onChange(of: appState.mood) { _, m in scene.mood = m }
                        .onChange(of: store.pet.colorIndex) { _, _ in
                            scene.applyPetColor(store.currentPetColor)
                        }
                        .onChange(of: houseStore.unlockedGardenPlots) { _, newCount in
                            scene.unlockedPlotCount = newCount
                        }
                        .onChange(of: houseStore.gardenTerrainExpansionLevel) { _, newLevel in
                            scene.terrainExpansionLevel = newLevel
                        }

                    gardenOverviewPanel(compact: compact)
                        .padding(.horizontal, compact ? 12 : 18)

                    gardenBottomDock(compact: compact)
                        .padding(.horizontal, compact ? 12 : 18)
                        .padding(.bottom, compact ? 12 : 16)
                }
                .frame(maxWidth: .infinity, alignment: .top)
            }
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.98, green: 0.96, blue: 0.89),
                        Color(red: 0.87, green: 0.96, blue: 0.86),
                        Color(red: 0.78, green: 0.89, blue: 0.79)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
    }

    private func gardenHeroCard(compact: Bool) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Giardino")
                .font(.system(size: compact ? 22 : 24, weight: .black, design: .rounded))
                .foregroundStyle(Color(hex: "#2E5F3C"))

            Text(gardenHeadline)
                .font(.system(size: compact ? 11 : 12, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(hex: "#5D8462"))
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 8) {
                tagChip(icon: "leaf.fill", text: "Relax")
                tagChip(icon: "sparkles", text: "Cura")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.99, green: 0.97, blue: 0.90, opacity: 0.90),
                    Color(red: 0.84, green: 0.95, blue: 0.82, opacity: 0.82)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 28, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.62), lineWidth: 1)
        )
        .shadow(color: Color(hex: "#7AA36B").opacity(0.14), radius: 16, y: 8)
    }

    private func gardenSceneHeader(compact: Bool) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Gardening")
                .font(.system(size: compact ? 11 : 12, weight: .black, design: .rounded))
                .foregroundStyle(Color(hex: "#406947"))
            Text(gardenStatusTitle)
                .font(.system(size: compact ? 17 : 20, weight: .black, design: .rounded))
                .foregroundStyle(Color(hex: "#2E5F3C"))
                .lineLimit(2)
            Text(gardenHeadline)
                .font(.system(size: compact ? 10 : 11, weight: .bold, design: .rounded))
                .foregroundStyle(Color(hex: "#5D8462"))
                .lineLimit(3)
        }
        .padding(.horizontal, compact ? 12 : 14)
        .padding(.vertical, compact ? 10 : 12)
        .frame(maxWidth: compact ? 190 : 220, alignment: .leading)
        .background(Color.white.opacity(0.78), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.58), lineWidth: 1)
        )
    }

    private func gardenProgressCard(compact: Bool) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Progressi")
                .font(.system(size: compact ? 16 : 18, weight: .black, design: .rounded))
                .foregroundStyle(Color(hex: "#2E5F3C"))

            progressRow(
                title: "Zollette",
                value: "\(houseStore.unlockedGardenPlots)/\(HouseStore.maxGardenPlots)",
                progress: Double(houseStore.unlockedGardenPlots) / Double(HouseStore.maxGardenPlots),
                tint: Color(hex: "#53A86A")
            )
            progressRow(
                title: "Terreno",
                value: "\(houseStore.gardenTerrainExpansionLevel)/\(HouseStore.maxGardenTerrainExpansions)",
                progress: Double(houseStore.gardenTerrainExpansionLevel) / Double(HouseStore.maxGardenTerrainExpansions),
                tint: Color(hex: "#6E8CFF")
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            Color.white.opacity(0.80),
            in: RoundedRectangle(cornerRadius: 24, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.6), lineWidth: 1)
        )
    }

    private func gardenOverviewPanel(compact: Bool) -> some View {
        Group {
            if compact {
                VStack(spacing: 10) {
                    gardenStatsRow
                    gardenProgressCard(compact: true)
                }
            } else {
                HStack(alignment: .top, spacing: 12) {
                    gardenProgressCard(compact: false)
                    gardenStatsColumn
                }
            }
        }
    }

    private func gardenResourceStrip(compact: Bool) -> some View {
        Group {
            if compact {
                HStack(spacing: 8) {
                    compactStatPill(icon: "dollarsign.circle.fill", value: "\(houseStore.wallet.coins)", tint: Color(hex: "#D69A2A"))
                    compactStatPill(icon: "square.grid.2x2.fill", value: "\(houseStore.unlockedGardenPlots)/\(HouseStore.maxGardenPlots)", tint: Color(hex: "#53A86A"))
                }
            } else {
                HStack(spacing: 8) {
                    compactStatPill(icon: "dollarsign.circle.fill", value: "\(houseStore.wallet.coins)", tint: Color(hex: "#D69A2A"))
                    compactStatPill(icon: "square.grid.2x2.fill", value: "\(houseStore.unlockedGardenPlots)/\(HouseStore.maxGardenPlots)", tint: Color(hex: "#53A86A"))
                    compactStatPill(icon: "arrow.up.left.and.arrow.down.right", value: "\(houseStore.gardenTerrainExpansionLevel)/\(HouseStore.maxGardenTerrainExpansions)", tint: Color(hex: "#6E8CFF"))
                }
                .frame(maxWidth: 270)
            }
        }
    }

    private func gardenProgressOverlay(compact: Bool) -> some View {
        HStack(spacing: 8) {
            overlayMetric(title: "Plot", value: "\(houseStore.unlockedGardenPlots)/\(HouseStore.maxGardenPlots)", tint: Color(hex: "#53A86A"))
            overlayMetric(title: "Land", value: "\(houseStore.gardenTerrainExpansionLevel)/\(HouseStore.maxGardenTerrainExpansions)", tint: Color(hex: "#6E8CFF"))
        }
        .padding(.horizontal, compact ? 10 : 12)
        .padding(.vertical, compact ? 8 : 10)
        .background(Color.white.opacity(0.78), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.56), lineWidth: 1)
        )
    }

    private var gardenStatsColumn: some View {
        VStack(spacing: 10) {
            statPill(icon: "dollarsign.circle.fill", title: "Coin", value: "\(houseStore.wallet.coins)", tint: Color(hex: "#D69A2A"))
            statPill(icon: "square.grid.2x2.fill", title: "Plot", value: "\(houseStore.unlockedGardenPlots)/\(HouseStore.maxGardenPlots)", tint: Color(hex: "#53A86A"))
            statPill(icon: "arrow.up.left.and.arrow.down.right", title: "Land", value: "\(houseStore.gardenTerrainExpansionLevel)/\(HouseStore.maxGardenTerrainExpansions)", tint: Color(hex: "#6E8CFF"))
        }
    }

    private var gardenStatsRow: some View {
        HStack(spacing: 8) {
            compactStatPill(icon: "dollarsign.circle.fill", value: "\(houseStore.wallet.coins)", tint: Color(hex: "#D69A2A"))
            compactStatPill(icon: "square.grid.2x2.fill", value: "\(houseStore.unlockedGardenPlots)/\(HouseStore.maxGardenPlots)", tint: Color(hex: "#53A86A"))
            compactStatPill(icon: "arrow.up.left.and.arrow.down.right", value: "\(houseStore.gardenTerrainExpansionLevel)/\(HouseStore.maxGardenTerrainExpansions)", tint: Color(hex: "#6E8CFF"))
        }
    }

    private func gardenBottomDock(compact: Bool) -> some View {
        let dockContent = VStack(spacing: 12) {
            if let gardenPurchaseMessage {
                Text(gardenPurchaseMessage)
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(Color(hex: "#4D6A52"))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 9)
                    .background(Color.white.opacity(0.82), in: Capsule())
                    .transition(.opacity.combined(with: .scale))
            }

            VStack(spacing: 10) {
                Button(action: purchasePlot) {
                    HStack(spacing: 10) {
                        Image(systemName: "plus.square.on.square")
                            .font(.system(size: 15, weight: .black))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(houseStore.canPurchaseGardenPlot ? "Compra una nuova zolletta" : "Giardino completo")
                                .font(.system(size: 14, weight: .black, design: .rounded))
                            Text(houseStore.canPurchaseGardenPlot ? "Espandi lo spazio coltivabile" : "Hai sbloccato tutto il terreno")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.white.opacity(0.86))
                        }
                        Spacer(minLength: 8)
                        if houseStore.canPurchaseGardenPlot {
                            Text("\(houseStore.nextGardenPlotCost)")
                                .font(.system(size: 12, weight: .black, design: .rounded))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.white.opacity(0.24), in: Capsule())
                        }
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: houseStore.canPurchaseGardenPlot
                                ? [Color(hex: "#8CBF65"), Color(hex: "#4F9C79")]
                                : [Color(hex: "#B9C3B4"), Color(hex: "#9BA69A")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        in: RoundedRectangle(cornerRadius: 24, style: .continuous)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(Color.white.opacity(0.24), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .disabled(!houseStore.canPurchaseGardenPlot)

                Button(action: purchaseTerrain) {
                    HStack(spacing: 10) {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .font(.system(size: 15, weight: .black))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(houseStore.canPurchaseGardenTerrain ? "Espandi il terreno" : "Terreno al massimo")
                                .font(.system(size: 14, weight: .black, design: .rounded))
                            Text(houseStore.canPurchaseGardenTerrain ? "Allarga il prato e dai piu respiro al giardino" : "Hai gia raggiunto la dimensione massima")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.white.opacity(0.86))
                        }
                        Spacer(minLength: 8)
                        if houseStore.canPurchaseGardenTerrain {
                            Text("\(houseStore.nextGardenTerrainCost)")
                                .font(.system(size: 12, weight: .black, design: .rounded))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.white.opacity(0.24), in: Capsule())
                        }
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: houseStore.canPurchaseGardenTerrain
                                ? [Color(hex: "#73A8FF"), Color(hex: "#5876F2")]
                                : [Color(hex: "#B9C3B4"), Color(hex: "#9BA69A")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        in: RoundedRectangle(cornerRadius: 24, style: .continuous)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(Color.white.opacity(0.24), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .disabled(!houseStore.canPurchaseGardenTerrain)

                if compact {
                    VStack(spacing: 10) {
                        gardenButton(icon: "drop.fill", label: "Annaffia", subtitle: "Cura il prato", color: Color(hex: "#34C99A")) { store.feed() }
                        gardenButton(icon: "figure.run", label: "Gioca", subtitle: "Alza il mood", color: Color(hex: "#5C9AF7")) { store.play() }
                    }
                } else {
                    HStack(spacing: 10) {
                        gardenButton(icon: "drop.fill", label: "Annaffia", subtitle: "Cura il prato", color: Color(hex: "#34C99A")) { store.feed() }
                        gardenButton(icon: "figure.run", label: "Gioca", subtitle: "Alza il mood", color: Color(hex: "#5C9AF7")) { store.play() }
                    }
                }
            }
        }

        return Group {
            if compact {
                ScrollView(.vertical, showsIndicators: false) {
                    dockContent
                }
                .frame(maxHeight: 260)
            } else {
                dockContent
            }
        }
    }

    private func statPill(icon: String, title: String, value: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .black))
                Text(title.uppercased())
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .tracking(0.5)
            }
            Text(value)
                .font(.system(size: 15, weight: .black, design: .rounded))
        }
        .foregroundStyle(tint)
        .frame(width: 86, alignment: .leading)
        .padding(.horizontal, 11)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.88), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.55), lineWidth: 1)
        )
        .shadow(color: tint.opacity(0.10), radius: 10, y: 5)
    }

    private func compactStatPill(icon: String, value: String, tint: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .black))
            Text(value)
                .font(.system(size: 12, weight: .black, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .foregroundStyle(tint)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 8)
        .padding(.vertical, 9)
        .background(Color.white.opacity(0.88), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.55), lineWidth: 1)
        )
    }

    private func overlayMetric(title: String, value: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 9, weight: .black, design: .rounded))
                .foregroundStyle(Color(hex: "#6A8A67"))
            Text(value)
                .font(.system(size: 11, weight: .black, design: .rounded))
                .foregroundStyle(tint)
        }
    }

    private func tagChip(icon: String, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .black))
            Text(text)
                .font(.system(size: 11, weight: .black, design: .rounded))
        }
        .foregroundStyle(Color(hex: "#55785B"))
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(Color.white.opacity(0.76), in: Capsule())
        .overlay(
            Capsule()
                .stroke(Color.white.opacity(0.58), lineWidth: 1)
        )
    }

    private func progressRow(title: String, value: String, progress: Double, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(Color(hex: "#406947"))
                Spacer()
                Text(value)
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(tint)
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(hex: "#E4EEDB"))
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [tint, tint.opacity(0.72)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: proxy.size.width * max(0.04, min(progress, 1.0)))
                }
            }
            .frame(height: 10)
        }
    }

    private var gardenHeadline: String {
        if houseStore.gardenTerrainExpansionLevel == HouseStore.maxGardenTerrainExpansions,
           houseStore.unlockedGardenPlots == HouseStore.maxGardenPlots {
            return "Il giardino e completo: piu profondo, piu ricco e pronto per il relax del pet."
        }

        if houseStore.gardenTerrainExpansionLevel > 0 || houseStore.unlockedGardenPlots > 3 {
            return "Uno spazio che cresce con il pet: nuove aiuole, piu respiro e dettagli ambientali."
        }

        return "Uno spazio piu arioso con aiuole, sentiero e nuove zollette da sbloccare."
    }

    private var gardenStatusTitle: String {
        if houseStore.gardenTerrainExpansionLevel == HouseStore.maxGardenTerrainExpansions,
           houseStore.unlockedGardenPlots == HouseStore.maxGardenPlots {
            return "Bloom Sanctuary"
        }

        if houseStore.gardenTerrainExpansionLevel >= 2 || houseStore.unlockedGardenPlots >= 6 {
            return "Growing Retreat"
        }

        return "Soft Garden"
    }

    private func purchasePlot() {
        switch houseStore.purchaseGardenPlot() {
        case .success:
            withAnimation(.snappy(duration: 0.2)) {
                gardenPurchaseMessage = "Nuova zolletta sbloccata"
            }
        case .insufficientFunds(let needed, _):
            withAnimation(.snappy(duration: 0.2)) {
                gardenPurchaseMessage = "Servono \(needed) monete"
            }
        case .alreadyOwned:
            withAnimation(.snappy(duration: 0.2)) {
                gardenPurchaseMessage = "Hai gia tutte le zollette"
            }
        default:
            withAnimation(.snappy(duration: 0.2)) {
                gardenPurchaseMessage = "Acquisto non disponibile"
            }
        }

        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.8))
            withAnimation(.easeOut(duration: 0.2)) {
                gardenPurchaseMessage = nil
            }
        }
    }

    private func purchaseTerrain() {
        switch houseStore.purchaseGardenTerrainExpansion() {
        case .success:
            withAnimation(.snappy(duration: 0.2)) {
                gardenPurchaseMessage = "Terreno espanso"
            }
        case .insufficientFunds(let needed, _):
            withAnimation(.snappy(duration: 0.2)) {
                gardenPurchaseMessage = "Servono \(needed) monete"
            }
        case .alreadyOwned:
            withAnimation(.snappy(duration: 0.2)) {
                gardenPurchaseMessage = "Terreno gia al massimo"
            }
        default:
            withAnimation(.snappy(duration: 0.2)) {
                gardenPurchaseMessage = "Espansione non disponibile"
            }
        }

        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.8))
            withAnimation(.easeOut(duration: 0.2)) {
                gardenPurchaseMessage = nil
            }
        }
    }


    private func gardenButton(icon: String, label: String, subtitle: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .black))
                    .foregroundColor(.white)
                    .frame(width: 34, height: 34)
                    .background(Color.white.opacity(0.18), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.85))
                }

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    colors: [color, color.opacity(0.82)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: 18, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(0.22), lineWidth: 1)
            )
            .shadow(color: color.opacity(0.32), radius: 10, y: 5)
        }
        .buttonStyle(.plain)
    }
}
