import SwiftUI
import SpriteKit

// MARK: - HouseView

struct HouseView: View {

    @EnvironmentObject var gameStore: GameStore
    @EnvironmentObject var houseStore: HouseStore

    @State private var scene: HouseScene = {
        let s = HouseScene()
        s.size = CGSize(width: 420, height: 380)
        s.scaleMode = .resizeFill
        return s
    }()

    @EnvironmentObject private var navigationState: NavigationState
    var body: some View {
        GeometryReader { geo in
            content(for: geo.size, safeAreaInsets: geo.safeAreaInsets)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .safeAreaInset(edge: .bottom) {
            dockedActionBar
        }
    }

    private func content(for size: CGSize, safeAreaInsets: EdgeInsets) -> some View {
        ZStack(alignment: .bottom) {
            houseBackground
            backgroundDecorations
            mainColumn(for: size, safeAreaInsets: safeAreaInsets)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var houseBackground: some View {
        LinearGradient(
            colors: [
                Color(red: 1.0, green: 0.95, blue: 0.90),
                Color(red: 0.95, green: 0.89, blue: 0.97),
                Color(red: 0.88, green: 0.90, blue: 1.0)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private func mainColumn(for size: CGSize, safeAreaInsets: EdgeInsets) -> some View {
        let sceneHeight = responsiveSceneHeight(for: size)
        let compact = isCompactWidth(size)
        let topPadding = compact ? safeAreaInsets.top : max(safeAreaInsets.top, 8)

        return ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: compact ? 8 : 10) {
                responsiveSceneView(size: size, sceneHeight: sceneHeight)
                statusCard
                    .padding(.horizontal, compact ? 0 : 18)
            }
            .padding(.top, topPadding)
            .padding(.bottom, 110)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private func responsiveSceneHeight(for size: CGSize) -> CGFloat {
        if isCompactWidth(size) {
            return min(max(size.height * 0.66, 380), size.height * 0.78)
        }
        return min(max(size.height * 0.68, 460), size.height * 0.82)
    }

    private func isCompactWidth(_ size: CGSize) -> Bool {
        size.width < 390
    }

    private func responsiveSceneView(size: CGSize, sceneHeight: CGFloat) -> some View {
        let compact = isCompactWidth(size)
        let horizontalInset: CGFloat = compact ? 0 : 18
        let sceneWidth = max(size.width - (horizontalInset * 2), 0)

        return SpriteView(scene: scene, options: [.allowsTransparency])
            .frame(width: sceneWidth, height: sceneHeight)
            .background(sceneCardBackground)
            .clipped()
            .overlay(alignment: .top) {
                petParametersCard(compact: compact)
                    .padding(.horizontal, compact ? 10 : 14)
                    .padding(.top, compact ? 18 : 22)
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
                .padding(.trailing, compact ? 14 : 22)
                .padding(.bottom, compact ? 14 : 20)
            }
            .padding(.horizontal, horizontalInset)
            .padding(.top, compact ? 6 : 12)
            .onAppear {
                scene.size = CGSize(width: sceneWidth, height: sceneHeight)
                scene.petStage = gameStore.pet.stage
                scene.applyPetColor(gameStore.currentPetColor, animated: false)
                if let mood = PetMood(rawValue: gameStore.pet.moodRaw) {
                    scene.mood = mood
                }
                scene.placedItems = houseStore.itemsPlacedInRoom().compactMap { item in
                    guard let x = item.roomPositionX,
                          let y = item.roomPositionY else { return nil }
                    return (itemID: item.itemID, position: CGPoint(x: x, y: y))
                }
            }
            .onDisappear {
                scene.stopMovement()
            }
            .onChange(of: size) { _, newSize in
                let newInset: CGFloat = isCompactWidth(newSize) ? 0 : 18
                let newWidth = max(newSize.width - (newInset * 2), 0)
                scene.size = CGSize(width: newWidth, height: responsiveSceneHeight(for: newSize))
            }
            .onChange(of: gameStore.pet.stage) { _, newStage in
                scene.petStage = newStage
            }
            .onChange(of: gameStore.pet.colorIndex) { _, _ in
                scene.applyPetColor(gameStore.currentPetColor)
            }
            .onChange(of: gameStore.evolutionTrigger) { _, _ in
                scene.runEvolutionCelebration()
            }
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
    }

    private var sceneCardBackground: some View {
        let compact = isCompactWidth(scene.size)

        return RoundedRectangle(cornerRadius: compact ? 0 : 32, style: .continuous)
            .fill(Color.white.opacity(compact ? 0.08 : 0.18))
            .overlay(
                RoundedRectangle(cornerRadius: compact ? 0 : 32, style: .continuous)
                    .stroke(Color.white.opacity(compact ? 0.18 : 0.35), lineWidth: 1)
            )
    }

    private var statusCard: some View {
        let compact = isCompactWidth(scene.size)

        return VStack(alignment: .leading, spacing: compact ? 8 : 10) {
            HStack(spacing: 8) {
                roomFactPill(title: "Mood", value: gameStore.pet.mood.rawValue.capitalized, tint: Color(hex: "#8B6BB5"))
                roomFactPill(title: "Stile", value: roomStyleName, tint: Color(hex: "#F59E0B"))
                roomFactPill(title: "Cura", value: "\(Int((overallCareScore * 100).rounded()))%", tint: Color(hex: "#EC4899"))
                if !compact {
                    roomFactPill(title: "Relax", value: "\(Int((relaxationScore * 100).rounded()))%", tint: Color(hex: "#60A5FA"))
                }
            }
        }
        .padding(.horizontal, compact ? 12 : 14)
        .padding(.vertical, compact ? 7 : 9)
        .frame(maxWidth: .infinity)
        .background(statusCardBackground(compact: compact))
    }

    private func petParametersCard(compact: Bool) -> some View {
        VStack(spacing: compact ? 6 : 8) {
            HStack(spacing: compact ? 6 : 8) {
                compactParameterChip(
                    title: "Mood",
                    value: gameStore.pet.mood.rawValue.capitalized,
                    tint: Color(hex: "#8B6BB5"),
                    compact: compact
                )
                compactParameterChip(
                    title: "Lv",
                    value: "\(gameStore.pet.stage)",
                    tint: Color(hex: "#F59E0B"),
                    compact: compact
                )
                compactParameterChip(
                    title: "Food",
                    value: "\(gameStore.pet.food)",
                    tint: Color(hex: "#34D399"),
                    compact: compact
                )
            }

            if compact {
                HStack(spacing: 10) {
                    miniStatDot(label: "H", value: gameStore.pet.needs.hunger, tint: Color(hex: "#F97316"))
                    miniStatDot(label: "Ha", value: gameStore.pet.needs.happiness, tint: Color(hex: "#EC4899"))
                    miniStatDot(label: "C", value: gameStore.pet.needs.calm, tint: Color(hex: "#60A5FA"))
                    miniStatDot(label: "E", value: gameStore.pet.needs.energy, tint: Color(hex: "#22C55E"))
                }
                .frame(maxWidth: .infinity)
            } else {
                HStack(spacing: 12) {
                    miniStatDot(label: "Hunger", value: gameStore.pet.needs.hunger, tint: Color(hex: "#F97316"))
                    miniStatDot(label: "Happy", value: gameStore.pet.needs.happiness, tint: Color(hex: "#EC4899"))
                    miniStatDot(label: "Calm", value: gameStore.pet.needs.calm, tint: Color(hex: "#60A5FA"))
                    miniStatDot(label: "Energy", value: gameStore.pet.needs.energy, tint: Color(hex: "#22C55E"))
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, compact ? 10 : 14)
        .padding(.vertical, compact ? 5 : 6)
        .background(.white.opacity(compact ? 0.74 : 0.80), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.7), lineWidth: 1)
        )
    }

    private func compactParameterChip(title: String, value: String, tint: Color, compact: Bool) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: compact ? 8 : 9, weight: .bold, design: .rounded))
                .foregroundStyle(Color(hex: "#8A7AA8"))
            Text(value)
                .font(.system(size: compact ? 11 : 12, weight: .black, design: .rounded))
                .foregroundStyle(tint)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, compact ? 8 : 9)
        .padding(.vertical, compact ? 6 : 8)
        .background(Color.white.opacity(0.82), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func miniStatDot(label: String, value: Float, tint: Color) -> some View {
        VStack(spacing: 5) {
            Text(label)
                .font(.system(size: label.count > 2 ? 9 : 8, weight: .bold, design: .rounded))
                .foregroundStyle(Color(hex: "#8A7AA8"))
            Circle()
                .fill(tint.opacity(0.18))
                .overlay(
                    Circle()
                        .trim(from: 0, to: max(0.08, min(CGFloat(value), 1)))
                        .stroke(tint, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                )
                .overlay {
                    Text("\(Int((value * 100).rounded()))")
                        .font(.system(size: label.count > 2 ? 8 : 7, weight: .black, design: .rounded))
                        .foregroundStyle(tint)
                }
                .frame(width: label.count > 2 ? 42 : 30, height: label.count > 2 ? 42 : 30)
        }
    }

    private func roomFactPill(title: String, value: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(Color(hex: "#8A7AA8"))
            Text(value)
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundStyle(tint)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.78), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    // MARK: - Action Bar

    private var actionBar: some View {
        let compact = isCompactWidth(scene.size)

        return Group {
            if compact {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        actionButton(icon: "bag.fill",       label: "Store",   color: Color(hex: "#F87171")) { navigationState.activeSection = .store }
                        actionButton(icon: "backpack.fill",  label: "Zaino",   color: Color(hex: "#60A5FA")) { navigationState.activeSection = .inventory }
                        actionButton(icon: "wand.and.stars", label: "Decora",  color: Color(hex: "#A78BFA")) { navigationState.activeSection = .decorate }
                        actionButton(icon: "sparkles",       label: "Me Time", color: Color(hex: "#F59E0B")) { navigationState.activeSection = .meTime }
                    }
                    .padding(.horizontal, 10)
                }
            } else {
                HStack(spacing: 12) {
                    actionButton(icon: "bag.fill",       label: "Store",   color: Color(hex: "#F87171")) { navigationState.activeSection = .store }
                    actionButton(icon: "backpack.fill",  label: "Zaino",   color: Color(hex: "#60A5FA")) { navigationState.activeSection = .inventory }
                    actionButton(icon: "wand.and.stars", label: "Decora",  color: Color(hex: "#A78BFA")) { navigationState.activeSection = .decorate }
                    actionButton(icon: "sparkles",       label: "Me Time", color: Color(hex: "#F59E0B")) { navigationState.activeSection = .meTime }
                }
                .padding(.horizontal, 14)
            }
        }
        .padding(.vertical, compact ? 8 : 12)
        .frame(maxWidth: .infinity)
        .background(actionBarBackground(compact: compact))
        .shadow(color: Color.black.opacity(compact ? 0.05 : 0.08), radius: 16, y: 6)
    }

    private var dockedActionBar: some View {
        actionBar
            .padding(.horizontal, isCompactWidth(scene.size) ? 10 : 18)
            .padding(.top, 8)
            .padding(.bottom, 8)
            .background(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0),
                        Color.white.opacity(0.72)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
    }

    private func actionButton(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        let compact = isCompactWidth(scene.size)

        return Button(action: action) {
            VStack(spacing: compact ? 3 : 4) {
                Image(systemName: icon)
                    .font(.system(size: compact ? 15 : 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: compact ? 40 : 48, height: compact ? 40 : 48)
                    .background(
                        LinearGradient(colors: [color.opacity(0.9), color], startPoint: .topLeading, endPoint: .bottomTrailing),
                        in: Circle()
                    )
                    .shadow(color: color.opacity(0.35), radius: 8, y: 4)
                Text(label)
                    .font(.system(size: compact ? 9 : 11, weight: .bold, design: .rounded))
                    .foregroundColor(color)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(width: compact ? 72 : nil)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Background Decorations

    private var backgroundDecorations: some View {
        ZStack {
            ForEach(Array(zip(
                ["⭐", "💫", "🌸", "✨", "🌟", "💕", "🌙"],
                [
                    CGPoint(x: 40, y: 96),
                    CGPoint(x: 330, y: 88),
                    CGPoint(x: 58, y: 220),
                    CGPoint(x: 316, y: 214),
                    CGPoint(x: 28, y: 388),
                    CGPoint(x: 352, y: 344),
                    CGPoint(x: 182, y: 72)
                ]
            )), id: \.0) { emoji, pos in
                Text(emoji)
                    .font(.system(size: 18))
                    .opacity(0.18)
                    .position(pos)
            }
        }
        .allowsHitTesting(false)
    }

    private func statusCardBackground(compact: Bool) -> some View {
        RoundedRectangle(cornerRadius: compact ? 0 : 22, style: .continuous)
            .fill(Color.white.opacity(compact ? 0.62 : 0.72))
            .overlay(
                RoundedRectangle(cornerRadius: compact ? 0 : 22, style: .continuous)
                    .stroke(Color.white.opacity(compact ? 0.24 : 0.6), lineWidth: 1)
            )
    }

    private func actionBarBackground(compact: Bool) -> some View {
        RoundedRectangle(cornerRadius: compact ? 0 : 28, style: .continuous)
            .fill(.white.opacity(compact ? 0.88 : 0.92))
            .overlay(
                RoundedRectangle(cornerRadius: compact ? 0 : 28, style: .continuous)
                    .stroke(Color.white.opacity(compact ? 0.28 : 0.65), lineWidth: 1)
            )
    }

    private var roomStyleName: String {
        switch gameStore.pet.stage {
        case 0: return "Starter Cozy"
        case 1: return "Soft Bloom"
        case 2: return "Sweet Nest"
        case 3: return "Dream Room"
        default: return "Star Haven"
        }
    }

    private var overallCareScore: Float {
        let needs = gameStore.pet.needs
        return min(max((needs.hunger + needs.happiness + needs.calm + needs.energy) / 4, 0), 1)
    }

    private var relaxationScore: Float {
        let needs = gameStore.pet.needs
        return min(max((needs.calm + needs.energy) / 2, 0), 1)
    }
}
