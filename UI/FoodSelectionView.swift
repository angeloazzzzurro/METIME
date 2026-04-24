import SwiftUI

// MARK: - FoodSelectionView
// Basata su choose-food.html

struct FoodSelectionView: View {
    @EnvironmentObject private var store: GameStore
    @EnvironmentObject private var houseStore: HouseStore

    @State private var selectedRecipe: Int = 0
    @State private var selectedTime: Int = 0
    @State private var selectedChef: Int = 0
    @State private var usedIngredients: Set<Int> = []
    @State private var isCooking: Bool = false
    @State private var cookProgress: Double = 0
    @State private var chefStatus: String = "IN ATTESA"
    @State private var cookedCount: Int = 0
    @State private var toastMessage: String?

    private let chefs = ["🐱", "🐻", "🐥"]

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
                    recipeNavBar
                    ScrollView {
                        VStack(spacing: 14) {
                            mainPanel(compact: compact)
                            progressPanel
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
    }

    // MARK: - Header

    private func sectionHeader(compact: Bool) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("Sezione")
                    .font(.system(size: compact ? 11 : 13, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: "#8a7260"))
                Text("Scegli Ricetta")
                    .font(.system(size: compact ? 22 : 28, weight: .black, design: .rounded))
                    .foregroundStyle(Color(hex: "#3d2b1f"))
            }
            Spacer()
            Label("\(cookedCount)/15", systemImage: "flame.fill")
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

    // MARK: - Recipe Nav Bar

    private var recipeNavBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(FoodRecipe.all.indices, id: \.self) { idx in
                    Button {
                        guard !isCooking else { return }
                        withAnimation(.snappy(duration: 0.2)) {
                            selectedRecipe = idx
                            selectedTime = 0
                            usedIngredients = []
                        }
                    } label: {
                        Text(FoodRecipe.all[idx].name)
                            .font(.system(size: 11, weight: .black, design: .rounded))
                            .foregroundStyle(selectedRecipe == idx ? .white : Color(hex: "#3d2b1f"))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                selectedRecipe == idx ? Color(hex: "#d4884a") : Color(hex: "#fdf3e3").opacity(0.9),
                                in: Capsule()
                            )
                            .overlay(Capsule().stroke(Color(hex: "#c9a96e").opacity(0.5), lineWidth: 1.5))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
        }
        .background(
            LinearGradient(colors: [Color(hex: "#fdf3e3"), Color(hex: "#f5ead8")], startPoint: .top, endPoint: .bottom)
        )
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color(hex: "#c9a96e").opacity(0.4)).frame(height: 1)
        }
    }

    // MARK: - Main Panel

    private func mainPanel(compact: Bool) -> some View {
        HStack(alignment: .top, spacing: 12) {
            chefSidebar

            recipeCard

            if !compact {
                chefIllustration
            }
        }
        .padding(16)
        .background(Color(hex: "#fdf3e3").opacity(0.95), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(Color(hex: "#c9a96e"), lineWidth: 2))
        .shadow(color: Color(hex: "#3d2b1f").opacity(0.12), radius: 10, y: 4)
    }

    private var chefSidebar: some View {
        VStack(spacing: 8) {
            Text("Chef")
                .font(.system(size: 9, weight: .black, design: .rounded))
                .foregroundStyle(Color(hex: "#8a7260"))

            ForEach(chefs.indices, id: \.self) { idx in
                VStack(spacing: 3) {
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            selectedChef = idx
                        }
                    } label: {
                        Text(chefs[idx])
                            .font(.system(size: 22))
                            .frame(width: 44, height: 44)
                            .background(Color(hex: "#f5ead8"), in: Circle())
                            .overlay(
                                Circle().stroke(
                                    selectedChef == idx ? Color(hex: "#d4884a") : Color(hex: "#c9a96e").opacity(0.4),
                                    lineWidth: selectedChef == idx ? 2.5 : 1
                                )
                            )
                            .scaleEffect(selectedChef == idx ? 1.1 : 1.0)
                    }
                    .buttonStyle(.plain)
                    Text("Chef \(idx + 1)")
                        .font(.system(size: 8, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(hex: "#8a7260"))
                }
            }

            VStack(spacing: 3) {
                Text("+")
                    .font(.system(size: 16, weight: .black))
                    .foregroundStyle(Color(hex: "#c9a96e"))
                    .frame(width: 44, height: 44)
                    .background(Color(hex: "#f5ead8").opacity(0.5), in: Circle())
                    .overlay(Circle().stroke(Color(hex: "#c9a96e").opacity(0.3), lineWidth: 1))
                Text("Vuoto")
                    .font(.system(size: 8, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: "#8a7260"))
            }
        }
        .frame(width: 58)
    }

    private var recipeCard: some View {
        let recipe = FoodRecipe.all[selectedRecipe]
        return VStack(alignment: .leading, spacing: 10) {
            Text(recipe.name)
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundStyle(Color(hex: "#3d2b1f"))

            HStack(spacing: 2) {
                ForEach(0..<5) { i in
                    Text(i < recipe.stars ? "★" : "☆")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Color(hex: "#d4a843"))
                }
            }

            Text("Seleziona tempo di cottura:")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(Color(hex: "#8a7260"))

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 6) {
                ForEach(recipe.times.indices, id: \.self) { idx in
                    let time = recipe.times[idx]
                    Button {
                        guard !isCooking else { return }
                        withAnimation(.snappy(duration: 0.15)) { selectedTime = idx }
                    } label: {
                        VStack(spacing: 2) {
                            Text("🪙 \(time.cost)")
                                .font(.system(size: 11, weight: .black, design: .rounded))
                                .foregroundStyle(selectedTime == idx ? .white : Color(hex: "#3d2b1f"))
                            Text(time.label)
                                .font(.system(size: 9, weight: .bold, design: .rounded))
                                .foregroundStyle(selectedTime == idx ? .white.opacity(0.8) : Color(hex: "#8a7260"))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            selectedTime == idx ? Color(hex: "#d4884a") : Color(hex: "#f5ead8"),
                            in: RoundedRectangle(cornerRadius: 10)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(hex: "#c9a96e").opacity(0.5), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(isCooking ? Color(hex: "#c9a96e") : Color(hex: "#a67c52"))
                    .frame(height: 40)

                if isCooking {
                    GeometryReader { geo in
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.25))
                            .frame(width: geo.size.width * cookProgress)
                            .animation(.linear(duration: Double(recipe.times[selectedTime].seconds)), value: cookProgress)
                    }
                    .frame(height: 40)
                }

                Text(isCooking ? "Cucinando..." : "Cucina!")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
            }
            .frame(height: 40)
            .onTapGesture { if !isCooking { startCooking() } }

            Text("Ingredienti")
                .font(.system(size: 9, weight: .black, design: .rounded))
                .foregroundStyle(Color(hex: "#8a7260"))

            HStack(spacing: 8) {
                ForEach(recipe.ingredients.indices, id: \.self) { idx in
                    Text(recipe.ingredients[idx])
                        .font(.system(size: 20))
                        .opacity(usedIngredients.contains(idx) ? 0.3 : 1.0)
                        .scaleEffect(usedIngredients.contains(idx) ? 0.85 : 1.0)
                        .animation(.spring(response: 0.3), value: usedIngredients.contains(idx))
                        .onTapGesture {
                            withAnimation { _ = usedIngredients.contains(idx) ? usedIngredients.remove(idx) : usedIngredients.insert(idx) }
                        }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var chefIllustration: some View {
        VStack(spacing: 4) {
            Text(chefs[selectedChef])
                .font(.system(size: 40))
            Text(chefStatus)
                .font(.system(size: 9, weight: .black, design: .rounded))
                .foregroundStyle(Color(hex: "#8a7260"))
        }
        .frame(width: 80)
        .padding(.top, 20)
    }

    // MARK: - Progress Panel

    private var progressPanel: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Completamento")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: "#3d2b1f"))
                Spacer()
                Text("\(cookedCount) / 15")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: "#8a7260"))
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(hex: "#c9a96e").opacity(0.3))
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(hex: "#d4884a"))
                        .frame(width: geo.size.width * min(1, Double(cookedCount) / 15.0))
                        .animation(.snappy, value: cookedCount)
                }
            }
            .frame(height: 12)

            if cookedCount >= 15 {
                Label("Traguardo raggiunto! Bonus sbloccato!", systemImage: "trophy.fill")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(Color(hex: "#d4a843"))
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(16)
        .background(Color(hex: "#fdf3e3").opacity(0.95), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(Color(hex: "#c9a96e"), lineWidth: 2))
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

    // MARK: - Cooking Logic

    private func startCooking() {
        isCooking = true
        chefStatus = "CUCINANDO!"
        cookProgress = 0
        usedIngredients = []

        let recipe = FoodRecipe.all[selectedRecipe]
        let duration = recipe.times[selectedTime].seconds

        for i in recipe.ingredients.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.4) {
                withAnimation { usedIngredients.insert(i) }
            }
        }

        withAnimation(.linear(duration: Double(duration))) {
            cookProgress = 1.0
        }

        Task { @MainActor in
            try? await Task.sleep(for: .seconds(duration))
            isCooking = false
            cookProgress = 0
            usedIngredients = []
            chefStatus = "FATTO!"
            cookedCount += 1

            let reward = recipe.stars * 10
            houseStore.rewardCoins(reward)

            let msg = "\(recipe.name) pronto! +\(recipe.times[selectedTime].cost) coin"
            withAnimation { toastMessage = msg }

            if cookedCount >= 15 {
                try? await Task.sleep(for: .seconds(2))
                withAnimation { toastMessage = "Traguardo raggiunto! Bonus sbloccato!" }
            }

            try? await Task.sleep(for: .seconds(2))
            withAnimation { toastMessage = nil }
            try? await Task.sleep(for: .seconds(2))
            withAnimation { chefStatus = "IN ATTESA" }
        }
    }
}

// MARK: - Model

struct FoodRecipe {
    let name: String
    let stars: Int
    let ingredients: [String]
    let times: [CookTime]

    struct CookTime {
        let cost: Int
        let label: String
        let seconds: Int
    }

    static let all: [FoodRecipe] = [
        .init(name: "Pancake al Miele 🥞", stars: 4,
              ingredients: ["🥚", "🧈", "🍯", "🌾", "🥛"],
              times: [
                .init(cost: 1500, label: "30 min", seconds: 3),
                .init(cost: 1600, label: "20 min", seconds: 2),
                .init(cost: 1500, label: "45 min", seconds: 4),
                .init(cost: 150,  label: "3 ore",  seconds: 5),
              ]),
        .init(name: "Ramen Speciale 🍜", stars: 5,
              ingredients: ["🍜", "🥚", "🧄", "🌶️", "🍖"],
              times: [
                .init(cost: 2000, label: "40 min", seconds: 4),
                .init(cost: 2200, label: "25 min", seconds: 3),
                .init(cost: 1800, label: "1 ora",  seconds: 5),
                .init(cost: 400,  label: "4 ore",  seconds: 6),
              ]),
        .init(name: "Torta di Fragole 🍰", stars: 3,
              ingredients: ["🍓", "🧈", "🌾", "🥛", "🍫"],
              times: [
                .init(cost: 1200, label: "20 min", seconds: 2),
                .init(cost: 1400, label: "15 min", seconds: 2),
                .init(cost: 1000, label: "35 min", seconds: 3),
                .init(cost: 100,  label: "2 ore",  seconds: 5),
              ]),
        .init(name: "Sushi Misto 🍣", stars: 4,
              ingredients: ["🍚", "🐟", "🥑", "🥒", "🍋"],
              times: [
                .init(cost: 1800, label: "35 min", seconds: 3),
                .init(cost: 2000, label: "20 min", seconds: 2),
                .init(cost: 1600, label: "50 min", seconds: 4),
                .init(cost: 300,  label: "3 ore",  seconds: 5),
              ]),
    ]
}
