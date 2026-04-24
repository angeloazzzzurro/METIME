import SwiftUI

// MARK: - GamesSectionView

struct GamesSectionView: View {
    @EnvironmentObject private var store: GameStore
    @EnvironmentObject private var houseStore: HouseStore

    @State private var selectedMiniGame: MiniGameDefinition = .starCatch
    @State private var totalTokens: Int = 0
    @State private var rewardMessage: String?
    @State private var activeMiniGame: MiniGameDefinition?

    var body: some View {
        GeometryReader { proxy in
            let compact = proxy.size.width < 430

            ZStack {
                MTSectionBackground()
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: compact ? 14 : 18) {
                        gamesHeader

                        if compact {
                            VStack(spacing: 12) {
                                featuredGameCard
                                HStack(spacing: 10) {
                                    MTStatPill(icon: "dollarsign.circle.fill", title: "Coin", value: "\(houseStore.wallet.coins)", tint: Color(hex: "#CF8C2B"))
                                    MTStatPill(icon: "seal.fill", title: "Token", value: "\(totalTokens)", tint: Color(hex: "#d4884a"))
                                    MTStatPill(icon: "heart.fill", title: "Mood", value: store.pet.mood.rawValue.capitalized, tint: Color(hex: "#D36F8E"))
                                }
                            }
                        } else {
                            HStack(alignment: .top, spacing: 14) {
                                featuredGameCard
                                VStack(spacing: 12) {
                                    MTStatPill(icon: "dollarsign.circle.fill", title: "Coin", value: "\(houseStore.wallet.coins)", tint: Color(hex: "#CF8C2B"))
                                    MTStatPill(icon: "seal.fill", title: "Token", value: "\(totalTokens)", tint: Color(hex: "#d4884a"))
                                    MTStatPill(icon: "heart.fill", title: "Mood", value: store.pet.mood.rawValue.capitalized, tint: Color(hex: "#D36F8E"))
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

                        Button {
                            activeMiniGame = selectedMiniGame
                        } label: {
                            HStack(spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(Color.white.opacity(0.2))
                                        .frame(width: 50, height: 50)
                                    Image(systemName: selectedMiniGame.icon)
                                        .font(.system(size: 22, weight: .black))
                                        .foregroundStyle(.white)
                                }

                                VStack(alignment: .leading, spacing: 3) {
                                    Text(selectedMiniGame.actionTitle)
                                        .font(.system(size: 16, weight: .black, design: .rounded))
                                        .foregroundStyle(.white)
                                    Text(selectedMiniGame.rewardLine)
                                        .font(.system(size: 12, weight: .bold, design: .rounded))
                                        .foregroundStyle(Color.white.opacity(0.86))
                                }

                                Spacer()

                                Image(systemName: "play.fill")
                                    .font(.system(size: 20, weight: .black))
                                    .foregroundStyle(.white)
                            }
                        }
                        .buttonStyle(MTPrimaryActionButtonStyle(tint: selectedMiniGame.tint))
                    }
                    .padding(.horizontal, compact ? 14 : 20)
                    .padding(.top, compact ? 14 : 18)
                    .padding(.bottom, 20)
                }
            }
        }
        .sheet(item: $activeMiniGame) { game in
            MiniGamePlayView(game: game) { tokensEarned in
                onGameComplete(game: game, tokensEarned: tokensEarned)
            }
        }
    }

    // MARK: - Header

    private var gamesHeader: some View {
        MTSectionHeader(
            eyebrow: "Sezione",
            title: "Giochi",
            subtitle: "Mini giochi interattivi per guadagnare token. Ogni 5 stelle = 1 token.",
            badge: "Token games",
            accent: Color(hex: "#BC6A42"),
            icon: "gamecontroller.fill"
        )
    }

    // MARK: - Featured Card

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
                colors: [MTSectionUI.elevatedSurface, selectedMiniGame.surfaceTint],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 30, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(MTSectionUI.subtleBorder, lineWidth: 1)
        )
        .shadow(color: MTSectionUI.shadow, radius: 14, y: 8)
    }

    // MARK: - Selection Cards

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
                        .background(selected ? Color.white : game.logoTint, in: Capsule())
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
                            ? AnyShapeStyle(LinearGradient(colors: [game.tint, game.tint.opacity(0.78)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            : AnyShapeStyle(LinearGradient(colors: [Color.white.opacity(0.98), game.surfaceTint], startPoint: .topLeading, endPoint: .bottomTrailing))
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(selected ? Color.white.opacity(0.2) : game.tint.opacity(0.12), lineWidth: 1)
            )
            .shadow(color: selected ? game.tint.opacity(0.20) : MTSectionUI.shadow.opacity(0.5), radius: 10, y: 5)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

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

    private func perkChip(text: String, tint: Color) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .black, design: .rounded))
            .foregroundStyle(tint)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(tint.opacity(0.10), in: Capsule())
    }

    // MARK: - Game Completion

    private func onGameComplete(game: MiniGameDefinition, tokensEarned: Int) {
        totalTokens += tokensEarned
        houseStore.rewardCoins(tokensEarned * 5)

        switch game {
        case .starCatch:
            store.applyBoost(hunger: 0, happiness: 0.10, calm: -0.05, energy: -0.02)
        case .timingTap:
            store.applyBoost(hunger: 0, happiness: 0.08, calm: 0.05, energy: -0.03)
        }

        withAnimation(.snappy(duration: 0.2)) {
            rewardMessage = "\(game.title): +\(tokensEarned) token guadagnati!"
        }
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(2))
            withAnimation(.easeOut(duration: 0.2)) { rewardMessage = nil }
        }
    }
}

// MARK: - MiniGame Play View (router)

private struct MiniGamePlayView: View {
    let game: MiniGameDefinition
    let onComplete: (Int) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.white, game.surfaceTint, game.surfaceTint.opacity(0.8)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
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
                .padding(.horizontal, 22)
                .padding(.top, 18)
                .padding(.bottom, 10)

                switch game {
                case .starCatch:
                    StarCatchGameView(tint: game.tint, logoTint: game.logoTint) { tokens in
                        onComplete(tokens)
                        dismiss()
                    }
                case .timingTap:
                    TimingTapGameView(tint: game.tint, logoTint: game.logoTint) { tokens in
                        onComplete(tokens)
                        dismiss()
                    }
                }

                Spacer()
            }
        }
    }
}

// MARK: - Star Catch Game

private struct StarCatchGameView: View {
    let tint: Color
    let logoTint: Color
    let onClaim: (Int) -> Void

    struct StarItem: Identifiable {
        let id = UUID()
        let x: CGFloat
        let y: CGFloat
        let isGolden: Bool
        let spawnDate = Date()
    }

    enum GameState { case idle, playing, ended }

    @State private var gameState: GameState = .idle
    @State private var stars: [StarItem] = []
    @State private var collectedStars: Int = 0
    @State private var bonusScore: Int = 0
    @State private var combo: Int = 1
    @State private var bestCombo: Int = 1
    @State private var timeLeft: Int = 20
    @State private var lastTapDate: Date = .distantPast
    @State private var tick: Double = 0
    @State private var lastSpawnTick: Double = -1
    @State private var lastCountTick: Double = -1
    @State private var arenaSize: CGSize = .zero

    private var tokensEarned: Int { (collectedStars + bonusScore) / 5 }

    var body: some View {
        VStack(spacing: 14) {
            VStack(spacing: 4) {
                Text("Star Catch")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(Color(hex: "#3d2b1f"))
                Text("Tocca le stelle entro 20 secondi. Ogni 5 stelle = 1 token.")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(hex: "#8a7260"))
                    .multilineTextAlignment(.center)
            }

            // Game Arena
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(LinearGradient(
                        colors: [Color(hex: "#fdf3e3"), Color(hex: "#f5ead8")],
                        startPoint: .top, endPoint: .bottom
                    ))
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color(hex: "#c9a96e").opacity(0.5), lineWidth: 1))

                ForEach(stars) { star in
                    Button {
                        tapStar(star)
                    } label: {
                        Text(star.isGolden ? "🌟" : "⭐")
                            .font(.system(size: 28))
                            .frame(width: 44, height: 44)
                            .background(
                                star.isGolden ? Color(hex: "#fff7de") : Color(hex: "#fff5ba"),
                                in: Circle()
                            )
                            .shadow(color: Color(hex: "#94731c").opacity(0.2), radius: 6)
                    }
                    .buttonStyle(.plain)
                    .position(x: star.x, y: star.y)
                }

                if gameState == .idle {
                    Text("Premi Avvia!")
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundStyle(Color(hex: "#8a7260"))
                }

                if gameState == .ended {
                    VStack(spacing: 6) {
                        Text("Tempo scaduto!")
                            .font(.system(size: 16, weight: .black, design: .rounded))
                            .foregroundStyle(Color(hex: "#3d2b1f"))
                        Text("Stelle: \(collectedStars)  Token: \(tokensEarned)")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(tint)
                    }
                    .padding(16)
                    .background(Color(hex: "#fdf3e3").opacity(0.95), in: RoundedRectangle(cornerRadius: 14))
                }
            }
            .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 200)
            .background(
                GeometryReader { geo in
                    Color.clear.onAppear { arenaSize = geo.size }
                }
            )
            .onReceive(Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()) { _ in
                guard gameState == .playing else { return }
                tick += 0.1
                if tick - lastSpawnTick >= 0.42 { spawnStar(); lastSpawnTick = tick }
                if tick - lastCountTick >= 1.0 {
                    timeLeft -= 1; lastCountTick = tick
                    if timeLeft <= 0 { endGame() }
                }
                let now = Date()
                stars.removeAll { now.timeIntervalSince($0.spawnDate) > 1.3 }
            }

            // Stats
            HStack(spacing: 6) {
                miniStat(label: "Tempo", value: "\(timeLeft)s")
                miniStat(label: "Stelle", value: "\(collectedStars)")
                miniStat(label: "Token", value: "\(tokensEarned)")
                miniStat(label: "Combo", value: "x\(combo)")
                miniStat(label: "Best", value: "x\(bestCombo)")
            }

            // Buttons
            if gameState == .idle {
                Button("Avvia Star Catch") { startGame() }
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(tint, in: RoundedRectangle(cornerRadius: 14))
                    .buttonStyle(.plain)
            } else if gameState == .playing {
                Text("In corso... \(timeLeft)s rimasti")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: "#8a7260"))
            } else {
                Button("Riscatta \(tokensEarned) token") {
                    onClaim(tokensEarned)
                }
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color(hex: "#5a9a2e"), in: RoundedRectangle(cornerRadius: 14))
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 22)
    }

    private func startGame() {
        collectedStars = 0; bonusScore = 0; combo = 1; bestCombo = 1
        timeLeft = 20; stars = []; tick = 0; lastSpawnTick = -1; lastCountTick = -1
        lastTapDate = .distantPast
        gameState = .playing
    }

    private func endGame() {
        gameState = .ended
        stars = []
    }

    private func spawnStar() {
        guard arenaSize.width > 0, arenaSize.height > 0 else { return }
        let pad: CGFloat = 26
        let x = CGFloat.random(in: pad...(arenaSize.width - pad))
        let y = CGFloat.random(in: pad...(arenaSize.height - pad))
        stars.append(StarItem(x: x, y: y, isGolden: Double.random(in: 0...1) < 0.15))
    }

    private func tapStar(_ star: StarItem) {
        guard gameState == .playing else { return }
        let now = Date()
        combo = now.timeIntervalSince(lastTapDate) < 0.85 ? min(9, combo + 1) : 1
        bestCombo = max(bestCombo, combo)
        lastTapDate = now
        collectedStars += star.isGolden ? 3 : 1
        bonusScore += max(0, combo - 1)
        stars.removeAll { $0.id == star.id }
    }

    private func miniStat(label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.system(size: 8, weight: .black, design: .rounded))
                .foregroundStyle(Color(hex: "#8a7260"))
            Text(value)
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundStyle(Color(hex: "#3d2b1f"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 7)
        .background(Color(hex: "#fdf3e3").opacity(0.9), in: RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(hex: "#c9a96e").opacity(0.4), lineWidth: 1))
    }
}

// MARK: - Timing Tap Game

private struct TimingTapGameView: View {
    let tint: Color
    let logoTint: Color
    let onClaim: (Int) -> Void

    enum GameState { case idle, playing, ended }

    @State private var gameState: GameState = .idle
    @State private var cursorPct: Double = 0
    @State private var cursorDir: Double = 1
    @State private var hits: Int = 0
    @State private var tries: Int = 0
    @State private var lastResult: String? = nil

    private let maxTries = 6
    private let zoneMin = 0.42
    private let zoneMax = 0.58

    private var tokensEarned: Int { (hits / 3) * 2 }
    private var inZone: Bool { cursorPct >= zoneMin && cursorPct <= zoneMax }

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 4) {
                Text("Timing Tap")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(Color(hex: "#3d2b1f"))
                Text("Premi STOP quando il cursore entra nella zona verde. 3 successi = 2 token.")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(hex: "#8a7260"))
                    .multilineTextAlignment(.center)
            }

            // Timing Track
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 999)
                        .fill(Color.white)
                        .overlay(RoundedRectangle(cornerRadius: 999).stroke(Color(hex: "#f0dfc4"), lineWidth: 1))

                    // Green zone
                    RoundedRectangle(cornerRadius: 999)
                        .fill(Color(hex: "#66d899").opacity(0.35))
                        .frame(width: geo.size.width * (zoneMax - zoneMin))
                        .offset(x: geo.size.width * zoneMin)

                    // Cursor
                    RoundedRectangle(cornerRadius: 7)
                        .fill(tint)
                        .frame(width: 14, height: geo.size.height - 4)
                        .offset(x: geo.size.width * cursorPct - 7, y: 2)
                        .animation(.linear(duration: 0.05), value: cursorPct)
                }
            }
            .frame(height: 28)
            .onReceive(Timer.publish(every: 0.045, on: .main, in: .common).autoconnect()) { _ in
                guard gameState == .playing else { return }
                cursorPct += 0.03 * cursorDir
                if cursorPct >= 1 { cursorDir = -1 }
                if cursorPct <= 0 { cursorDir = 1 }
            }

            // Result indicator
            if let result = lastResult {
                Text(result)
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(result.contains("Hit") ? Color(hex: "#5a9a2e") : Color(hex: "#e8a0a0"))
                    .transition(.scale.combined(with: .opacity))
            }

            // Stats
            HStack(spacing: 10) {
                miniStat(label: "Successi", value: "\(hits)")
                miniStat(label: "Tentativi", value: "\(tries)/\(maxTries)")
                miniStat(label: "Token round", value: "\(tokensEarned)")
            }

            // Buttons
            switch gameState {
            case .idle:
                Button("Start") { startGame() }
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(tint, in: RoundedRectangle(cornerRadius: 14))
                    .buttonStyle(.plain)

            case .playing:
                Button("Stop") { stopTap() }
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(hex: "#d4884a"), in: RoundedRectangle(cornerRadius: 14))
                    .buttonStyle(.plain)

            case .ended:
                VStack(spacing: 8) {
                    Text("Round finito! \(hits) hit su \(tries)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(hex: "#3d2b1f"))
                    Button("Riscatta \(tokensEarned) token") {
                        onClaim(tokensEarned)
                    }
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(hex: "#5a9a2e"), in: RoundedRectangle(cornerRadius: 14))
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 22)
    }

    private func startGame() {
        hits = 0; tries = 0; cursorPct = 0; cursorDir = 1; lastResult = nil
        gameState = .playing
    }

    private func stopTap() {
        guard gameState == .playing else { return }
        tries += 1
        let hit = inZone
        if hit { hits += 1 }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            lastResult = hit ? "Hit perfetto! ✓" : "Fuori zona, ritenta"
        }
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1))
            withAnimation { lastResult = nil }
        }
        if tries >= maxTries { gameState = .ended }
    }

    private func miniStat(label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.system(size: 9, weight: .black, design: .rounded))
                .foregroundStyle(Color(hex: "#8a7260"))
            Text(value)
                .font(.system(size: 14, weight: .black, design: .rounded))
                .foregroundStyle(Color(hex: "#3d2b1f"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(hex: "#fdf3e3").opacity(0.9), in: RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(hex: "#c9a96e").opacity(0.4), lineWidth: 1))
    }
}

// MARK: - MiniGameDefinition

private enum MiniGameDefinition: CaseIterable, Identifiable {
    case starCatch
    case timingTap

    var id: String { title }

    var title: String {
        switch self {
        case .starCatch: "Star Catch"
        case .timingTap: "Timing Tap"
        }
    }

    var subtitle: String {
        switch self {
        case .starCatch: "Tocca le stelline entro 20 secondi. Ogni 5 stelle = 1 token."
        case .timingTap: "Premi Stop nella zona verde. 3 successi = 2 token."
        }
    }

    var longDescription: String {
        switch self {
        case .starCatch: "Le stelle appaiono nell'arena e scompaiono dopo 1.3 secondi. Tocca quelle dorate per 3 punti! Il combo aumenta se tocchi in rapida successione."
        case .timingTap: "Il cursore oscilla avanti e indietro. Premi STOP quando entra nella zona verde. Hai 6 tentativi per fare piu hit possibili."
        }
    }

    var cardLine: String {
        switch self {
        case .starCatch: "Riflessi rapidi · bonus combo · stelle dorate rare"
        case .timingTap: "Precisione · ritmo costante · 6 tentativi"
        }
    }

    var actionTitle: String {
        switch self {
        case .starCatch: "Gioca a Star Catch"
        case .timingTap: "Gioca a Timing Tap"
        }
    }

    var rewardLine: String {
        switch self {
        case .starCatch: "Ogni 5 stelle = 1 token · combo bonus"
        case .timingTap: "3 hit = 2 token · ritmo e precisione"
        }
    }

    var rewardTag: String {
        switch self {
        case .starCatch: "Token reward"
        case .timingTap: "Precision reward"
        }
    }

    var styleTag: String {
        switch self {
        case .starCatch: "Fast reflex"
        case .timingTap: "Rhythm play"
        }
    }

    var badgeText: String {
        switch self {
        case .starCatch: "STAR"
        case .timingTap: "TAP"
        }
    }

    var logoText: String {
        switch self {
        case .starCatch: "CATCH"
        case .timingTap: "TIMING"
        }
    }

    var icon: String {
        switch self {
        case .starCatch: "star.fill"
        case .timingTap: "target"
        }
    }

    var tint: Color {
        switch self {
        case .starCatch: Color(hex: "#E4A030")
        case .timingTap: Color(hex: "#E48A5B")
        }
    }

    var logoTint: Color {
        switch self {
        case .starCatch: Color(hex: "#9A6820")
        case .timingTap: Color(hex: "#C8614D")
        }
    }

    var surfaceTint: Color {
        switch self {
        case .starCatch: Color(hex: "#FFF8E0")
        case .timingTap: Color(hex: "#FFF1E8")
        }
    }
}
