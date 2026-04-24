import SwiftUI

// MARK: - WorldMapView
// Mappa del mondo con zone esplorabili
// Basata su map.html — palette warm Animal Crossing

struct WorldMapView: View {
    @State private var selectedLocation: MapLocation? = nil

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
                    mapHeader(compact: compact)

                    ScrollView {
                        VStack(spacing: 14) {
                            mapCanvas
                            if let loc = selectedLocation {
                                locationCard(loc, compact: compact)
                                    .transition(.move(edge: .bottom).combined(with: .opacity))
                            }
                            locationsGrid(compact: compact)
                        }
                        .padding(.horizontal, compact ? 12 : 18)
                        .padding(.vertical, 14)
                        .padding(.bottom, 30)
                    }
                }
            }
        }
    }

    // MARK: - Header

    private func mapHeader(compact: Bool) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("Mappa")
                    .font(.system(size: compact ? 11 : 13, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: "#8a7260"))
                Text("Mondo METIME")
                    .font(.system(size: compact ? 22 : 28, weight: .black, design: .rounded))
                    .foregroundStyle(Color(hex: "#3d2b1f"))
            }
            Spacer()
            Label("\(MapLocation.all.reduce(0) { $0 + $1.players }) online", systemImage: "person.2.fill")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(Color(hex: "#5a9a2e"))
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

    // MARK: - Map Canvas

    private var mapCanvas: some View {
        ZStack {
            // Map background terrain
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "#98b878"), Color(hex: "#8aaa70"),
                            Color(hex: "#a0bd80"), Color(hex: "#80a060")
                        ],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Color(hex: "#8b6340"), lineWidth: 3)
                )

            // Biome labels
            Text("Bosco Smeraldo")
                .font(.system(size: 9, weight: .black, design: .rounded))
                .foregroundStyle(Color(hex: "#3d2b1f").opacity(0.5))
                .rotationEffect(.degrees(-5))
                .position(x: 90, y: 110)

            Text("Terre Fertili")
                .font(.system(size: 9, weight: .black, design: .rounded))
                .foregroundStyle(Color(hex: "#3d2b1f").opacity(0.5))
                .rotationEffect(.degrees(3))
                .position(x: 200, y: 230)

            // Water areas
            Ellipse()
                .fill(Color(hex: "#64aad2").opacity(0.45))
                .frame(width: 90, height: 60)
                .position(x: 270, y: 200)

            Ellipse()
                .fill(Color(hex: "#64a0c8").opacity(0.35))
                .frame(width: 60, height: 80)
                .position(x: 55, y: 245)

            // Location pins
            ForEach(MapLocation.all) { loc in
                mapPin(loc)
                    .position(
                        x: loc.mapPosition.x * 340,
                        y: loc.mapPosition.y * 300
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            selectedLocation = selectedLocation?.id == loc.id ? nil : loc
                        }
                    }
            }

            // Player marker
            ZStack {
                Circle()
                    .fill(Color(hex: "#d4884a").opacity(0.3))
                    .frame(width: 28, height: 28)
                Circle()
                    .fill(Color(hex: "#d4884a"))
                    .frame(width: 14, height: 14)
                    .overlay(Circle().stroke(.white, lineWidth: 2))
                Text("Tu")
                    .font(.system(size: 7, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
            }
            .position(x: 165, y: 180)
        }
        .frame(height: 300)
        .shadow(color: Color(hex: "#3d2b1f").opacity(0.2), radius: 12, y: 6)
    }

    private func mapPin(_ loc: MapLocation) -> some View {
        let isSelected = selectedLocation?.id == loc.id

        return VStack(spacing: 2) {
            ZStack {
                Circle()
                    .fill(loc.pinColor)
                    .frame(width: isSelected ? 34 : 28, height: isSelected ? 34 : 28)
                    .overlay(Circle().stroke(.white.opacity(0.6), lineWidth: 1.5))
                    .shadow(color: Color(hex: "#3d2b1f").opacity(0.3), radius: 4, y: 2)
                Text(loc.emoji)
                    .font(.system(size: isSelected ? 16 : 13))
            }
            .scaleEffect(isSelected ? 1.1 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)

            Text(loc.shortName)
                .font(.system(size: 7, weight: .black, design: .rounded))
                .foregroundStyle(Color(hex: "#3d2b1f"))
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(Color(hex: "#fdf3e3").opacity(0.9), in: RoundedRectangle(cornerRadius: 4))
                .lineLimit(1)
        }
    }

    // MARK: - Selected Location Card

    private func locationCard(_ loc: MapLocation, compact: Bool) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(loc.emoji)
                    .font(.system(size: 28))
                VStack(alignment: .leading, spacing: 2) {
                    Text(loc.name)
                        .font(.system(size: 17, weight: .black, design: .rounded))
                        .foregroundStyle(Color(hex: "#3d2b1f"))
                    Text(loc.description)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(hex: "#5e4636"))
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                Button {
                    withAnimation { selectedLocation = nil }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Color(hex: "#8a7260"))
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 12) {
                statChip(icon: "person.fill", label: "\(loc.players) online", tint: Color(hex: "#5a9a2e"))
                statChip(icon: "star.fill", label: "Lv \(loc.minLevel)+", tint: Color(hex: "#d4a843"))
                statChip(icon: "leaf.fill", label: loc.resource, tint: Color(hex: "#8fa882"))
            }

            Button {
                withAnimation { selectedLocation = nil }
            } label: {
                Label("Esplora zona", systemImage: "map.fill")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(Color(hex: "#a67c52"), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(Color(hex: "#fdf3e3").opacity(0.95), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(Color(hex: "#c9a96e"), lineWidth: 2))
        .shadow(color: Color(hex: "#3d2b1f").opacity(0.12), radius: 10, y: 4)
    }

    private func statChip(icon: String, label: String, tint: Color) -> some View {
        Label(label, systemImage: icon)
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .foregroundStyle(tint)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(tint.opacity(0.12), in: Capsule())
    }

    // MARK: - Locations Grid

    private func locationsGrid(compact: Bool) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Tutte le Zone")
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundStyle(Color(hex: "#3d2b1f"))

            LazyVGrid(
                columns: compact
                    ? [GridItem(.flexible()), GridItem(.flexible())]
                    : [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
                spacing: 10
            ) {
                ForEach(MapLocation.all) { loc in
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            selectedLocation = loc
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Text(loc.emoji)
                                .font(.system(size: 20))
                            VStack(alignment: .leading, spacing: 1) {
                                Text(loc.shortName)
                                    .font(.system(size: 11, weight: .black, design: .rounded))
                                    .foregroundStyle(Color(hex: "#3d2b1f"))
                                    .lineLimit(1)
                                Label("\(loc.players)", systemImage: "person.fill")
                                    .font(.system(size: 9, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color(hex: "#5a9a2e"))
                            }
                            Spacer(minLength: 0)
                        }
                        .padding(10)
                        .background(Color(hex: "fdf3e3").opacity(selectedLocation?.id == loc.id ? 1 : 0.82), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(selectedLocation?.id == loc.id ? Color(hex: "#a67c52") : Color(hex: "#c9a96e").opacity(0.4), lineWidth: selectedLocation?.id == loc.id ? 2 : 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

// MARK: - MapLocation Model

struct MapLocation: Identifiable {
    let id = UUID()
    let name: String
    let shortName: String
    let emoji: String
    let description: String
    let players: Int
    let minLevel: Int
    let resource: String
    let mapPosition: CGPoint  // normalized 0–1
    let pinColor: Color

    static let all: [MapLocation] = [
        .init(name: "Cittadella Picco Gelato", shortName: "Picco Gelato", emoji: "🏔️",
              description: "Un'antica fortezza sulle vette ghiacciate. Ricca di cristalli rari e ricette leggendarie.",
              players: 12, minLevel: 30, resource: "Ghiaccio",
              mapPosition: .init(x: 0.20, y: 0.14), pinColor: Color(hex: "#d8ccb0")),
        .init(name: "Villaggio Asgard", shortName: "Asgard", emoji: "🏘️",
              description: "Un vivace mercato di villaggio. Luogo d'incontro per scambiare ingredienti.",
              players: 24, minLevel: 5, resource: "Cereali",
              mapPosition: .init(x: 0.30, y: 0.32), pinColor: Color(hex: "#c0a860")),
        .init(name: "Colline Mistiche", shortName: "Colline", emoji: "🔮",
              description: "Altopiani viola avvolti nella nebbia. Erbe magiche e funghi rari.",
              players: 8, minLevel: 18, resource: "Erbe",
              mapPosition: .init(x: 0.65, y: 0.28), pinColor: Color(hex: "#b0a0d0")),
        .init(name: "Lago di Cristallo", shortName: "Lago", emoji: "💎",
              description: "Un lago incontaminato alimentato da sorgenti montane.",
              players: 5, minLevel: 12, resource: "Pesce",
              mapPosition: .init(x: 0.50, y: 0.55), pinColor: Color(hex: "#80c0d8")),
        .init(name: "Città dei Ciliegi", shortName: "Ciliegi", emoji: "🌸",
              description: "Un'incantevole cittadina sotto eterni fiori di ciliegio. Centro eventi sociali.",
              players: 31, minLevel: 1, resource: "Petali",
              mapPosition: .init(x: 0.22, y: 0.48), pinColor: Color(hex: "#f0b0c0")),
        .init(name: "Fattoria Valle Verde", shortName: "Valle Verde", emoji: "🌿",
              description: "Terre fertili che si estendono fino all'orizzonte. Il suolo migliore.",
              players: 15, minLevel: 8, resource: "Verdure",
              mapPosition: .init(x: 0.40, y: 0.72), pinColor: Color(hex: "#90c070")),
        .init(name: "Fucina di Ferro", shortName: "Fucina", emoji: "⚒️",
              description: "Una fonderia vulcanica dove abili artigiani forgiano utensili da cucina.",
              players: 3, minLevel: 25, resource: "Minerali",
              mapPosition: .init(x: 0.72, y: 0.75), pinColor: Color(hex: "#b08070")),
        .init(name: "Porto del Tramonto", shortName: "Porto", emoji: "⚓",
              description: "Un caldo porto costiero. Le navi portano spezie esotiche ogni giorno.",
              players: 19, minLevel: 15, resource: "Spezie",
              mapPosition: .init(x: 0.82, y: 0.42), pinColor: Color(hex: "#d0a060")),
    ]
}
