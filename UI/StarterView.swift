import SwiftUI

// MARK: - StarterView

struct StarterView: View {
    @AppStorage("petTypeRaw") private var petTypeRaw: String = ""
    @State private var selected: PetType? = nil
    @State private var confirmed = false

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color(hex: "#0d0d1a"), Color(hex: "#1a0d2e"), Color(hex: "#0a1a1a")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            StarfieldView()

            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Text("METIME")
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundStyle(Color(hex: "#c9a96e").opacity(0.8))
                        .tracking(6)
                        .padding(.top, 56)

                    Text("Scegli il tuo\ncompagno")
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.top, 6)

                    Text("Crescerete insieme nel tempo")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.45))
                        .padding(.top, 4)
                }
                .padding(.bottom, 40)

                // Selection cards
                GeometryReader { geo in
                    HStack(spacing: 14) {
                        ForEach(PetType.allCases, id: \.rawValue) { type in
                            PetTypeCard(type: type, isSelected: selected == type)
                                .frame(maxWidth: .infinity)
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                                        selected = type
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, 20)
                    .frame(height: geo.size.height)
                }
                .frame(height: 380)

                Spacer(minLength: 16)

                // Confirm button
                Button {
                    guard let sel = selected else { return }
                    withAnimation(.easeInOut(duration: 0.25)) {
                        confirmed = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        petTypeRaw = sel.rawValue
                    }
                } label: {
                    HStack(spacing: 8) {
                        Text(selected == nil ? "Seleziona un compagno" : "Inizia l'avventura")
                            .font(.system(size: 17, weight: .black, design: .rounded))
                        if selected != nil {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 15, weight: .black))
                        }
                    }
                    .foregroundStyle(selected == nil ? .white.opacity(0.3) : .white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        Group {
                            if let sel = selected {
                                LinearGradient(
                                    colors: [sel.accentColor, sel.accentColor.opacity(0.65)],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            } else {
                                LinearGradient(
                                    colors: [Color.white.opacity(0.07), Color.white.opacity(0.07)],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            }
                        },
                        in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                    )
                    .shadow(color: selected?.accentColor.opacity(0.35) ?? .clear, radius: 16, y: 6)
                }
                .buttonStyle(.plain)
                .disabled(selected == nil)
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
                .scaleEffect(confirmed ? 0.95 : 1.0)
            }
        }
    }
}

// MARK: - PetTypeCard

private struct PetTypeCard: View {
    let type: PetType
    let isSelected: Bool

    @State private var floatOffset: CGFloat = 0

    var body: some View {
        VStack(spacing: 16) {
            // Pet preview with glow
            ZStack {
                Circle()
                    .fill(type.accentColor.opacity(isSelected ? 0.22 : 0.06))
                    .frame(width: 130, height: 130)
                    .blur(radius: 22)

                if type == .fiamma {
                    FlammaPetView()
                        .frame(width: 78, height: 98)
                } else {
                    UovoPetView()
                        .frame(width: 72, height: 92)
                }
            }
            .frame(height: 130)
            .offset(y: floatOffset)

            // Name
            Text(type.displayName)
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundStyle(.white)

            // Tagline
            Text(type.tagline)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.5))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 4)

            // Trait pills
            VStack(spacing: 5) {
                ForEach(type.traits, id: \.self) { trait in
                    Text(trait)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(type.accentColor)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 5)
                        .background(type.accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(.white.opacity(isSelected ? 0.09 : 0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(
                            isSelected ? type.accentColor : Color.white.opacity(0.1),
                            lineWidth: isSelected ? 2 : 1
                        )
                )
        )
        .shadow(color: isSelected ? type.accentColor.opacity(0.28) : .clear, radius: 22)
        .onAppear {
            let duration = 1.7 + Double.random(in: 0...0.5)
            withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                floatOffset = -9
            }
        }
    }
}

// MARK: - FlammaPetView

struct FlammaPetView: View {
    var body: some View {
        Canvas { ctx, size in
            let w = size.width, h = size.height, cx = w / 2

            // Flame body
            var body = Path()
            body.move(to: CGPoint(x: cx, y: 2))
            body.addCurve(to: CGPoint(x: w - 3, y: h * 0.64),
                          control1: CGPoint(x: w + 8, y: h * 0.22),
                          control2: CGPoint(x: w - 2, y: h * 0.46))
            body.addCurve(to: CGPoint(x: cx, y: h),
                          control1: CGPoint(x: w - 5, y: h * 0.86),
                          control2: CGPoint(x: cx + 14, y: h))
            body.addCurve(to: CGPoint(x: 3, y: h * 0.64),
                          control1: CGPoint(x: cx - 14, y: h),
                          control2: CGPoint(x: 5, y: h * 0.86))
            body.addCurve(to: CGPoint(x: cx, y: 2),
                          control1: CGPoint(x: 2, y: h * 0.46),
                          control2: CGPoint(x: cx - 8, y: h * 0.22))
            body.closeSubpath()

            ctx.drawLayer { lctx in
                lctx.clip(to: body)
                lctx.fill(
                    Path(CGRect(origin: .zero, size: size)),
                    with: .linearGradient(
                        Gradient(colors: [Color(hex: "#ffe87a"), Color(hex: "#ff8c42"), Color(hex: "#cc3e00")]),
                        startPoint: .zero, endPoint: CGPoint(x: cx, y: h)
                    )
                )
            }

            // Inner highlight
            var inner = Path()
            inner.move(to: CGPoint(x: cx, y: 14))
            inner.addCurve(to: CGPoint(x: w - 14, y: h * 0.60),
                           control1: CGPoint(x: w - 2, y: h * 0.28),
                           control2: CGPoint(x: w - 12, y: h * 0.46))
            inner.addCurve(to: CGPoint(x: cx, y: h - 12),
                           control1: CGPoint(x: w - 16, y: h * 0.80),
                           control2: CGPoint(x: cx + 9, y: h - 12))
            inner.addCurve(to: CGPoint(x: 14, y: h * 0.60),
                           control1: CGPoint(x: cx - 9, y: h - 12),
                           control2: CGPoint(x: 16, y: h * 0.80))
            inner.addCurve(to: CGPoint(x: cx, y: 14),
                           control1: CGPoint(x: 2, y: h * 0.46),
                           control2: CGPoint(x: cx - 2, y: h * 0.28))
            inner.closeSubpath()
            ctx.fill(inner, with: .color(.white.opacity(0.2)))

            // Eyes
            let eyeY = h * 0.54, eyeR: CGFloat = 5.5, ex: CGFloat = 11
            for sign: CGFloat in [-1, 1] {
                ctx.fill(Path(ellipseIn: CGRect(x: cx + sign * ex - eyeR, y: eyeY - eyeR, width: eyeR * 2, height: eyeR * 2)), with: .color(.white))
                ctx.fill(Path(ellipseIn: CGRect(x: cx + sign * ex - 3, y: eyeY - 2.5, width: 6, height: 6)), with: .color(.black.opacity(0.88)))
                ctx.fill(Path(ellipseIn: CGRect(x: cx + sign * ex - 0.5, y: eyeY - eyeR + 1.5, width: 2.5, height: 2.5)), with: .color(.white.opacity(0.9)))
            }

            // Smile
            var smile = Path()
            smile.move(to: CGPoint(x: cx - 7, y: h * 0.655))
            smile.addQuadCurve(to: CGPoint(x: cx + 7, y: h * 0.655), control: CGPoint(x: cx, y: h * 0.705))
            ctx.stroke(smile, with: .color(.black.opacity(0.55)), style: StrokeStyle(lineWidth: 2, lineCap: .round))

            // Cheek blush
            for sign: CGFloat in [-1, 1] {
                ctx.fill(
                    Path(ellipseIn: CGRect(x: cx + sign * 18 - 7, y: h * 0.62 - 4, width: 14, height: 8)),
                    with: .color(Color(red: 1, green: 0.55, blue: 0.4, opacity: 0.35))
                )
            }
        }
    }
}

// MARK: - UovoPetView

struct UovoPetView: View {
    var body: some View {
        Canvas { ctx, size in
            let w = size.width, h = size.height, cx = w / 2

            // Egg body
            var egg = Path()
            egg.move(to: CGPoint(x: cx, y: 2))
            egg.addCurve(to: CGPoint(x: w - 3, y: h * 0.50),
                         control1: CGPoint(x: w + 5, y: h * 0.1),
                         control2: CGPoint(x: w - 2, y: h * 0.32))
            egg.addCurve(to: CGPoint(x: cx, y: h - 2),
                         control1: CGPoint(x: w - 8, y: h * 0.80),
                         control2: CGPoint(x: cx + 11, y: h - 2))
            egg.addCurve(to: CGPoint(x: 3, y: h * 0.50),
                         control1: CGPoint(x: cx - 11, y: h - 2),
                         control2: CGPoint(x: 8, y: h * 0.80))
            egg.addCurve(to: CGPoint(x: cx, y: 2),
                         control1: CGPoint(x: 2, y: h * 0.32),
                         control2: CGPoint(x: cx - 5, y: h * 0.1))
            egg.closeSubpath()

            ctx.drawLayer { lctx in
                lctx.clip(to: egg)
                lctx.fill(
                    Path(CGRect(origin: .zero, size: size)),
                    with: .linearGradient(
                        Gradient(colors: [Color(hex: "#fffdf5"), Color(hex: "#f5e8d0"), Color(hex: "#e0c89a")]),
                        startPoint: .zero, endPoint: CGPoint(x: cx, y: h)
                    )
                )
            }

            // Outline
            ctx.stroke(egg, with: .color(Color(hex: "#c9a06a").opacity(0.55)), style: StrokeStyle(lineWidth: 2, lineJoin: .round))

            // Highlight
            let hiPath = Path(ellipseIn: CGRect(x: cx - 18, y: 10, width: 16, height: 22))
            ctx.fill(hiPath, with: .color(.white.opacity(0.35)))

            // Speckles
            let speckles: [(CGFloat, CGFloat, CGFloat)] = [
                (cx - 15, h * 0.50, 2.8), (cx + 16, h * 0.55, 2.2),
                (cx - 6, h * 0.72, 1.8), (cx + 10, h * 0.68, 2.0),
                (cx - 18, h * 0.63, 1.6), (cx + 4, h * 0.82, 1.5),
            ]
            for (sx, sy, sr) in speckles {
                ctx.fill(Path(ellipseIn: CGRect(x: sx - sr, y: sy - sr, width: sr * 2, height: sr * 2)),
                         with: .color(Color(hex: "#a07040").opacity(0.22)))
            }

            // Crack
            let crackTopY = h * 0.22
            var crack = Path()
            crack.move(to: CGPoint(x: cx - 11, y: crackTopY))
            crack.addLine(to: CGPoint(x: cx - 3, y: crackTopY + 8))
            crack.addLine(to: CGPoint(x: cx + 5, y: crackTopY + 4))
            crack.addLine(to: CGPoint(x: cx + 11, y: crackTopY + 10))
            ctx.stroke(crack, with: .color(Color(hex: "#8b6030").opacity(0.65)), style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))

            // Eyes peeking
            let eyeY = crackTopY + 18, eyeR: CGFloat = 5.0, ex: CGFloat = 10
            for sign: CGFloat in [-1, 1] {
                ctx.fill(Path(ellipseIn: CGRect(x: cx + sign * ex - eyeR, y: eyeY - eyeR, width: eyeR * 2, height: eyeR * 2)), with: .color(.white))
                ctx.fill(Path(ellipseIn: CGRect(x: cx + sign * ex - 2.8, y: eyeY - 2, width: 5.6, height: 5.6)), with: .color(.black.opacity(0.85)))
                ctx.fill(Path(ellipseIn: CGRect(x: cx + sign * ex - 0.5, y: eyeY - eyeR + 2, width: 2.2, height: 2.2)), with: .color(.white.opacity(0.9)))
            }

            // Curious little brow arcs
            for sign: CGFloat in [-1, 1] {
                var brow = Path()
                brow.move(to: CGPoint(x: cx + sign * (ex - 5), y: eyeY - eyeR - 3))
                brow.addQuadCurve(to: CGPoint(x: cx + sign * (ex + 5), y: eyeY - eyeR - 3),
                                  control: CGPoint(x: cx + sign * ex, y: eyeY - eyeR - 7))
                ctx.stroke(brow, with: .color(.black.opacity(0.5)), style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
            }
        }
    }
}

// MARK: - StarfieldView

private struct StarfieldView: View {
    private struct Star: Identifiable {
        let id: Int
        let x, y, size, opacity: CGFloat
    }

    private let stars: [Star] = (0..<70).map { i in
        Star(id: i,
             x: CGFloat.random(in: 0...1),
             y: CGFloat.random(in: 0...1),
             size: CGFloat.random(in: 0.8...2.8),
             opacity: CGFloat.random(in: 0.15...0.65))
    }

    var body: some View {
        GeometryReader { geo in
            ForEach(stars) { star in
                Circle()
                    .fill(.white.opacity(star.opacity))
                    .frame(width: star.size, height: star.size)
                    .position(x: star.x * geo.size.width, y: star.y * geo.size.height)
            }
        }
        .ignoresSafeArea()
    }
}
