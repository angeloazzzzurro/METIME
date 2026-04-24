import SwiftUI

// MARK: - FarmView
// Basata su farm.html

struct FarmView: View {
    @EnvironmentObject private var houseStore: HouseStore

    @State private var selectedFarm: Int = 0
    @State private var quantities: [Int] = [24, 12, 36, 18]
    @State private var timeLeft: [Double] = [15, 20, 12, 25]
    @State private var workingChefs: [Bool] = Array(repeating: false, count: 6)
    @State private var toastMessage: String?

    @Namespace private var tabNS

    private let allChefs: [(name: String, emoji: String)] = [
        ("Mochi", "🐱"), ("Honey", "🐻"), ("Pip", "🐥"),
        ("Bun", "🐰"), ("Foxy", "🦊"), ("Lily", "🐸")
    ]

    private var farm: FarmData { FarmData.all[selectedFarm] }
    private var isReady: Bool { timeLeft[selectedFarm] <= 0 }
    private var progress: Double {
        let total = farm.duration
        guard total > 0 else { return 1 }
        return min(1, (total - timeLeft[selectedFarm]) / total)
    }

    var body: some View {
        GeometryReader { proxy in
            let compact = proxy.size.width < 430
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "#8fa882"), Color(hex: "#b8cdb0"), Color(hex: "#f5ead8")],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    sectionHeader(compact: compact)
                    farmTabBar
                    ScrollView {
                        VStack(spacing: 14) {
                            resourceCard
                            timerCard
                            chefCard
                            illustrationCard
                        }
                        .padding(.horizontal, compact ? 12 : 18)
                        .padding(.vertical, 14)
                        .padding(.bottom, 30)
                    }
                }

                if let msg = toastMessage {
                    toastOverlay(msg)
                }
            }
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            tickTimers()
        }
    }

    // MARK: - Header

    private func sectionHeader(compact: Bool) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("Sezione")
                    .font(.system(size: compact ? 11 : 13, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: "#8a7260"))
                Text(farm.title)
                    .font(.system(size: compact ? 22 : 28, weight: .black, design: .rounded))
                    .foregroundStyle(Color(hex: "#3d2b1f"))
                    .animation(.snappy, value: selectedFarm)
            }
            Spacer()
            Label("×\(quantities[selectedFarm])", systemImage: "archivebox.fill")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(Color(hex: "#d4884a"))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(hex: "#fdf3e3").opacity(0.9), in: Capsule())
                .overlay(Capsule().stroke(Color(hex: "#c9a96e").opacity(0.5), lineWidth: 1.5))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            LinearGradient(colors: [Color(hex: "#fdf3e3"), Color(hex: "#f5ead8")], startPoint: .top, endPoint: .bottom)
        )
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color(hex: "#c9a96e")).frame(height: 1)
        }
    }

    // MARK: - Tab Bar

    private var farmTabBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(FarmData.all.indices, id: \.self) { idx in
                    Button {
                        withAnimation(.snappy(duration: 0.2)) { selectedFarm = idx }
                    } label: {
                        VStack(spacing: 0) {
                            Text(FarmData.all[idx].tab)
                                .font(.system(size: 13, weight: .black, design: .rounded))
                                .foregroundStyle(selectedFarm == idx ? Color(hex: "#3d2b1f") : Color(hex: "#8a7260"))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)

                            Rectangle()
                                .fill(selectedFarm == idx ? Color(hex: "#d4884a") : Color.clear)
                                .frame(height: 3)
                                .matchedGeometryEffect(id: idx == selectedFarm ? "activeFarmTab" : "inactiveFarmTab\(idx)", in: tabNS)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .background(
            LinearGradient(colors: [Color(hex: "#fdf3e3"), Color(hex: "#f5ead8")], startPoint: .top, endPoint: .bottom)
        )
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color(hex: "#c9a96e").opacity(0.4)).frame(height: 1)
        }
    }

    // MARK: - Resource Card

    private var resourceCard: some View {
        HStack(spacing: 14) {
            Text(farm.icon)
                .font(.system(size: 46))

            VStack(alignment: .leading, spacing: 4) {
                Text(farm.name)
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(Color(hex: "#3d2b1f"))
                Text(farm.desc)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(hex: "#8a7260"))
            }

            Spacer()

            Text("×\(quantities[selectedFarm])")
                .font(.system(size: 26, weight: .black, design: .rounded))
                .foregroundStyle(Color(hex: "#d4884a"))
                .animation(.spring(response: 0.3, dampingFraction: 0.5), value: quantities[selectedFarm])
        }
        .padding(16)
        .background(
            LinearGradient(colors: [Color(hex: "#f0e8d4"), Color(hex: "#e8dcc4")], startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
        )
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color(hex: "#c9a96e"), lineWidth: 1.5))
        .shadow(color: Color(hex: "#3d2b1f").opacity(0.1), radius: 8, y: 4)
    }

    // MARK: - Timer Card

    private var timerCard: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Prossimo Raccolto")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundStyle(Color(hex: "#3d2b1f"))
                Spacer()
                Text(isReady ? "Pronto!" : timerString)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(isReady ? Color(hex: "#5a9a2e") : Color(hex: "#8a7260"))
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6).fill(Color(hex: "#c9a96e").opacity(0.25))
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isReady ? Color(hex: "#5a9a2e") : Color(hex: "#d4884a"))
                        .frame(width: geo.size.width * progress)
                        .animation(.linear(duration: 1), value: progress)
                }
            }
            .frame(height: 12)

            Button {
                harvest()
            } label: {
                Label("Raccogli!", systemImage: "leaf.fill")
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        isReady ? Color(hex: "#5a9a2e") : Color(hex: "#8a7260").opacity(0.5),
                        in: RoundedRectangle(cornerRadius: 14)
                    )
            }
            .buttonStyle(.plain)
            .disabled(!isReady)
        }
        .padding(16)
        .background(Color(hex: "#fdf3e3").opacity(0.95), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color(hex: "#c9a96e"), lineWidth: 1.5))
    }

    private var timerString: String {
        let total = Int(timeLeft[selectedFarm])
        let h = total / 3600, m = (total % 3600) / 60, s = total % 60
        return String(format: "%02dh %02dm %02ds", h, m, s)
    }

    // MARK: - Chef Card

    private var chefCard: some View {
        let workingCount = workingChefs.filter { $0 }.count
        return VStack(alignment: .leading, spacing: 10) {
            Text("Chef al lavoro (\(workingCount)/\(allChefs.count))")
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundStyle(Color(hex: "#3d2b1f"))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(allChefs.indices, id: \.self) { idx in
                        VStack(spacing: 4) {
                            Button {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    workingChefs[idx].toggle()
                                }
                                showToast(workingChefs[idx]
                                    ? "\(allChefs[idx].name) assegnato!"
                                    : "\(allChefs[idx].name) rimosso dal lavoro")
                            } label: {
                                Text(allChefs[idx].emoji)
                                    .font(.system(size: 22))
                                    .frame(width: 46, height: 46)
                                    .background(Color(hex: "#f5ead8"), in: Circle())
                                    .overlay(
                                        Circle().stroke(
                                            workingChefs[idx] ? Color(hex: "#d4884a") : Color(hex: "#c9a96e").opacity(0.4),
                                            lineWidth: workingChefs[idx] ? 2.5 : 1
                                        )
                                    )
                                    .shadow(color: workingChefs[idx] ? Color(hex: "#d4884a").opacity(0.3) : .clear, radius: 6)
                            }
                            .buttonStyle(.plain)

                            Text(allChefs[idx].name)
                                .font(.system(size: 9, weight: .bold, design: .rounded))
                                .foregroundStyle(Color(hex: "#8a7260"))
                        }
                    }

                    ForEach(0..<4, id: \.self) { _ in
                        VStack(spacing: 4) {
                            Text("+")
                                .font(.system(size: 16, weight: .black))
                                .foregroundStyle(Color(hex: "#c9a96e"))
                                .frame(width: 46, height: 46)
                                .background(Color(hex: "#f5ead8").opacity(0.5), in: Circle())
                                .overlay(Circle().stroke(Color(hex: "#c9a96e").opacity(0.3), lineWidth: 1))
                            Text("Sblocca")
                                .font(.system(size: 9, weight: .bold, design: .rounded))
                                .foregroundStyle(Color(hex: "#c9a96e"))
                        }
                    }
                }
                .padding(.horizontal, 2)
            }
        }
        .padding(16)
        .background(Color(hex: "#fdf3e3").opacity(0.95), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color(hex: "#c9a96e"), lineWidth: 1.5))
    }

    // MARK: - Illustration Card

    private var illustrationCard: some View {
        VStack(spacing: 8) {
            Text(farm.illust)
                .font(.system(size: 36))
            Text(farm.msg)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(Color(hex: "#8a7260"))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(18)
        .background(Color(hex: "#fdf3e3").opacity(0.9), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color(hex: "#c9a96e"), lineWidth: 1.5))
    }

    // MARK: - Toast

    private func toastOverlay(_ message: String) -> some View {
        Text(message)
            .font(.system(size: 13, weight: .black, design: .rounded))
            .foregroundStyle(Color(hex: "#3d2b1f"))
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(
                LinearGradient(colors: [Color(hex: "#fdf3e3"), Color(hex: "#f5ead8")], startPoint: .top, endPoint: .bottom),
                in: RoundedRectangle(cornerRadius: 18)
            )
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color(hex: "#c9a96e"), lineWidth: 2))
            .shadow(color: Color(hex: "#3d2b1f").opacity(0.2), radius: 20)
            .transition(.scale.combined(with: .opacity))
    }

    // MARK: - Logic

    private func tickTimers() {
        for i in timeLeft.indices {
            if timeLeft[i] > 0 {
                timeLeft[i] -= 1
                if timeLeft[i] <= 0 {
                    showToast("Raccolto pronto nella \(FarmData.all[i].title)!")
                }
            }
        }
    }

    private func harvest() {
        guard isReady else { return }
        let bonus = Int.random(in: 3...7)
        quantities[selectedFarm] += bonus
        houseStore.rewardCoins(bonus)
        showToast("Raccolto! +\(bonus) \(farm.name)")
        timeLeft[selectedFarm] = farm.duration
    }

    private func showToast(_ msg: String) {
        withAnimation { toastMessage = msg }
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(2))
            withAnimation { toastMessage = nil }
        }
    }
}

// MARK: - Model

private struct FarmData {
    let title: String
    let tab: String
    let icon: String
    let name: String
    let desc: String
    let illust: String
    let msg: String
    let duration: Double

    static let all: [FarmData] = [
        .init(title: "Pollaio", tab: "Pollaio", icon: "🥚",
              name: "Uova Fresche", desc: "Uova biologiche di gallina felice",
              illust: "🐔🐔🐔", msg: "Le tue galline sono felici!", duration: 15),
        .init(title: "Pesca", tab: "Pesca", icon: "🐟",
              name: "Pesce Fresco", desc: "Trota e koi dal laghetto sereno",
              illust: "🐟🐟🎣", msg: "I pesci nuotano tranquilli!", duration: 20),
        .init(title: "Frutteto", tab: "Frutteto", icon: "🍎",
              name: "Frutti di Stagione", desc: "Mele, arance e frutti di bosco",
              illust: "🍎🍊🍇", msg: "Il frutteto è rigoglioso!", duration: 12),
        .init(title: "Risaia", tab: "Risaia", icon: "🌾",
              name: "Riso di Montagna", desc: "Riso coltivato con acqua di sorgente",
              illust: "🌾🌱🌿", msg: "La risaia cresce bene!", duration: 25),
    ]
}
