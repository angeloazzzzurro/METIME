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

    @EnvironmentObject private var navigationState: NavigationState

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                LinearGradient(
                    colors: [
                        Color(red: 1.0, green: 0.92, blue: 0.96),
                        Color(red: 0.92, green: 0.88, blue: 1.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                backgroundDecorations

                VStack(spacing: 0) {
                    topBar
                    let sceneHeight = geo.size.height * 0.55
                    SpriteView(scene: scene, options: [.allowsTransparency])
                        .frame(width: geo.size.width, height: sceneHeight)
                        .onAppear {
                            scene.size = CGSize(width: geo.size.width, height: sceneHeight)
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
                    actionBar
                    Spacer()
                }
            }
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            // Titolo
            Label("La tua Casa", systemImage: "house.fill")
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.6))

            Spacer()

            // Wallet
            HStack(spacing: 12) {
                walletBadge(icon: "dollarsign.circle.fill", value: houseStore.wallet.coins, color: Color(red: 1.0, green: 0.75, blue: 0.2))
                walletBadge(icon: "diamond.fill",           value: houseStore.wallet.gems,  color: Color(red: 0.5, green: 0.3, blue: 0.9))
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    private func walletBadge(icon: String, value: Int, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(color)
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
        HStack(spacing: 12) {
            actionButton(icon: "bag.fill",       label: "Store",   color: Color(hex: "#F87171")) { navigationState.activeSection = .store }
            actionButton(icon: "backpack.fill",  label: "Zaino",   color: Color(hex: "#60A5FA")) { navigationState.activeSection = .inventory }
            actionButton(icon: "wand.and.stars", label: "Decora",  color: Color(hex: "#A78BFA")) { navigationState.activeSection = .decorate }
            actionButton(icon: "sparkles",       label: "Me Time", color: Color(hex: "#F59E0B")) { navigationState.activeSection = .meTime }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.08), radius: 8, y: 2)
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
    }

    private func actionButton(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(color, in: Circle())
                Text(label)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(color)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
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
