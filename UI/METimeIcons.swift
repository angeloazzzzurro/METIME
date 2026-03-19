import SwiftUI

// MARK: - METIME Icon System — Animal Crossing inspired
//
// Design language (AC):
//  • Rounded-square card, pastel gradient background
//  • White highlight dot top-left (AC signature)
//  • Tiny leaf accent top-right
//  • Thin category-tinted border
//  • Leaf-badge shape for nav buttons

// ─────────────────────────────────────────────────────────────────────────────
// MARK: ACItemIcon — store catalog card icon
// ─────────────────────────────────────────────────────────────────────────────

struct ACItemIcon: View {
    let itemID: String
    var size: CGFloat = 64

    private var def: ACIconStyle { ACIconStyle.style(for: itemID) }

    var body: some View {
        ZStack(alignment: .center) {
            // Card
            RoundedRectangle(cornerRadius: size * 0.24, style: .continuous)
                .fill(LinearGradient(
                    colors: [def.cardTop, def.cardBottom],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .overlay(
                    RoundedRectangle(cornerRadius: size * 0.24, style: .continuous)
                        .strokeBorder(def.accent.opacity(0.45), lineWidth: 1.6)
                )

            // Main icon drawing
            ACIconDrawing(itemID: itemID, size: size * 0.64)

            // AC white highlight dot — top left
            Circle()
                .fill(Color.white.opacity(0.60))
                .frame(width: size * 0.16, height: size * 0.16)
                .frame(width: size, height: size, alignment: .topLeading)
                .padding(size * 0.10)

            // Leaf accent — top right
            Image(systemName: "leaf.fill")
                .font(.system(size: size * 0.14, weight: .black))
                .foregroundStyle(def.accent.opacity(0.55))
                .frame(width: size, height: size, alignment: .topTrailing)
                .padding(size * 0.09)
        }
        .frame(width: size, height: size)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: ACNavIcon — leaf-badge for top nav (Store / Zaino / Decora / Me Time)
// ─────────────────────────────────────────────────────────────────────────────

struct ACNavIcon: View {
    enum Kind { case store, inventory, decorate, meTime }
    let kind: Kind
    var size: CGFloat = 46

    var body: some View {
        ZStack {
            ACLeafBadge(color: kind.color, size: size)
            kind.symbolImage
                .font(.system(size: size * 0.36, weight: .bold))
                .foregroundStyle(.white)
        }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: ACLeafBadge — reusable leaf-shaped background
// ─────────────────────────────────────────────────────────────────────────────

struct ACLeafBadge: View {
    let color: Color
    var size: CGFloat = 46

    var body: some View {
        ZStack {
            ACLeafShape()
                .fill(LinearGradient(
                    colors: [color.opacity(0.80), color],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .shadow(color: color.opacity(0.40), radius: 6, y: 3)

            // Soft inner shine
            ACLeafShape()
                .fill(
                    RadialGradient(
                        colors: [Color.white.opacity(0.35), Color.clear],
                        center: UnitPoint(x: 0.35, y: 0.30),
                        startRadius: 0,
                        endRadius: size * 0.4
                    )
                )
        }
        .frame(width: size, height: size)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: ACLeafShape — rounded diamond with slight top point
// ─────────────────────────────────────────────────────────────────────────────

struct ACLeafShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width, h = rect.height
        let cx = rect.midX, cy = rect.midY
        return Path { p in
            p.move(to: CGPoint(x: cx, y: rect.minY + h * 0.04))
            p.addCurve(
                to: CGPoint(x: rect.maxX - w * 0.04, y: cy),
                control1: CGPoint(x: rect.maxX - w * 0.09, y: rect.minY + h * 0.04),
                control2: CGPoint(x: rect.maxX - w * 0.04, y: cy - h * 0.32)
            )
            p.addCurve(
                to: CGPoint(x: cx, y: rect.maxY - h * 0.04),
                control1: CGPoint(x: rect.maxX - w * 0.04, y: cy + h * 0.32),
                control2: CGPoint(x: rect.maxX - w * 0.09, y: rect.maxY - h * 0.04)
            )
            p.addCurve(
                to: CGPoint(x: rect.minX + w * 0.04, y: cy),
                control1: CGPoint(x: rect.minX + w * 0.09, y: rect.maxY - h * 0.04),
                control2: CGPoint(x: rect.minX + w * 0.04, y: cy + h * 0.32)
            )
            p.addCurve(
                to: CGPoint(x: cx, y: rect.minY + h * 0.04),
                control1: CGPoint(x: rect.minX + w * 0.04, y: cy - h * 0.32),
                control2: CGPoint(x: rect.minX + w * 0.09, y: rect.minY + h * 0.04)
            )
            p.closeSubpath()
        }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: ACIconDrawing — per-item custom illustrations
// ─────────────────────────────────────────────────────────────────────────────

struct ACIconDrawing: View {
    let itemID: String
    var size: CGFloat = 42

    var body: some View {
        Group {
            switch itemID {
            case "food_carrot":       CarrotView(size: size)
            case "food_cookie":       CookieView(size: size)
            case "food_cake":         CakeView(size: size)
            case "food_tea":          TeaView(size: size)
            case "essential_bowl":    BowlView(size: size)
            case "essential_cushion": CushionView(size: size)
            case "essential_blanket": BlanketView(size: size)
            case "deco_plant":        PlantView(size: size)
            case "deco_lamp":         LampView(size: size)
            case "deco_rug":          RugView(size: size)
            case "special_crystal":   CrystalView(size: size)
            case "special_book":      BookView(size: size)
            case "special_candle":    CandleView(size: size)
            default:
                Image(systemName: "cube.fill")
                    .font(.system(size: size * 0.6))
                    .foregroundStyle(Color.gray.opacity(0.5))
            }
        }
        .frame(width: size, height: size)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: Item illustrations
// ─────────────────────────────────────────────────────────────────────────────

// 🥕 Carota Magica
private struct CarrotView: View {
    let size: CGFloat
    var body: some View {
        Canvas { ctx, sz in
            let cx = sz.width / 2, cy = sz.height / 2
            // Body
            var body = Path()
            body.move(to: CGPoint(x: cx, y: cy - sz.height * 0.36))
            body.addCurve(
                to: CGPoint(x: cx, y: cy + sz.height * 0.36),
                control1: CGPoint(x: cx + sz.width * 0.34, y: cy - sz.height * 0.1),
                control2: CGPoint(x: cx + sz.width * 0.20, y: cy + sz.height * 0.32)
            )
            body.addCurve(
                to: CGPoint(x: cx, y: cy - sz.height * 0.36),
                control1: CGPoint(x: cx - sz.width * 0.20, y: cy + sz.height * 0.32),
                control2: CGPoint(x: cx - sz.width * 0.34, y: cy - sz.height * 0.1)
            )
            ctx.fill(body, with: .color(Color(hex: "#FB923C")))

            // Ridges
            for yOff in [-0.08, 0.06, 0.18] as [CGFloat] {
                var ridge = Path()
                ridge.move(to: CGPoint(x: cx - sz.width * 0.18, y: cy + sz.height * yOff))
                ridge.addLine(to: CGPoint(x: cx + sz.width * 0.10, y: cy + sz.height * yOff))
                ctx.stroke(ridge, with: .color(Color(hex: "#F97316").opacity(0.45)), lineWidth: 1.2)
            }

            // Tops (3 leaves)
            let leafTip = CGPoint(x: cx, y: cy - sz.height * 0.36)
            for (dx, dy) in [(-0.28, -0.36), (0.0, -0.44), (0.24, -0.36)] as [(CGFloat, CGFloat)] {
                var leaf = Path()
                leaf.move(to: leafTip)
                leaf.addCurve(
                    to: CGPoint(x: cx + sz.width * dx, y: cy + sz.height * dy),
                    control1: CGPoint(x: cx + sz.width * (dx * 0.5), y: cy - sz.height * 0.46),
                    control2: CGPoint(x: cx + sz.width * (dx * 0.8), y: cy + sz.height * (dy + 0.06))
                )
                ctx.stroke(leaf, with: .color(Color(hex: "#22C55E")), lineWidth: 2.2)
            }
        }
        .frame(width: size, height: size)
    }
}

// 🍪 Biscotto Stellato
private struct CookieView: View {
    let size: CGFloat
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(hex: "#D97706"))
                .frame(width: size * 0.80, height: size * 0.80)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "#B45309"), Color(hex: "#D97706")],
                        center: .bottomTrailing, startRadius: 0, endRadius: size * 0.5
                    )
                )
                .frame(width: size * 0.80, height: size * 0.80)
            Image(systemName: "star.fill")
                .font(.system(size: size * 0.40))
                .foregroundStyle(Color(hex: "#FDE68A"))
            // Chips
            ForEach([(-0.22, -0.16), (0.18, 0.08), (-0.08, 0.22), (0.24, -0.22)] as [(CGFloat, CGFloat)], id: \.0) { dx, dy in
                Circle()
                    .fill(Color(hex: "#7C2D12"))
                    .frame(width: size * 0.11, height: size * 0.11)
                    .offset(x: size * dx, y: size * dy)
            }
        }
        .frame(width: size, height: size)
    }
}

// 🎂 Torta Rosa
private struct CakeView: View {
    let size: CGFloat
    var body: some View {
        ZStack {
            // Base tier
            RoundedRectangle(cornerRadius: size * 0.10, style: .continuous)
                .fill(Color(hex: "#FCA5A5"))
                .frame(width: size * 0.82, height: size * 0.28)
                .offset(y: size * 0.22)
            // Top tier
            RoundedRectangle(cornerRadius: size * 0.08, style: .continuous)
                .fill(Color(hex: "#F9A8D4"))
                .frame(width: size * 0.56, height: size * 0.24)
                .offset(y: size * 0.02)
            // Frosting waves
            Canvas { ctx, sz in
                let y = sz.height * 0.02 - sz.height * 0.10
                var path = Path()
                path.move(to: CGPoint(x: sz.width * 0.22, y: y))
                path.addCurve(
                    to: CGPoint(x: sz.width * 0.40, y: y - 6),
                    control1: CGPoint(x: sz.width * 0.27, y: y - 6),
                    control2: CGPoint(x: sz.width * 0.35, y: y - 6)
                )
                path.addCurve(
                    to: CGPoint(x: sz.width * 0.60, y: y - 0),
                    control1: CGPoint(x: sz.width * 0.47, y: y - 6),
                    control2: CGPoint(x: sz.width * 0.54, y: y)
                )
                path.addCurve(
                    to: CGPoint(x: sz.width * 0.78, y: y - 6),
                    control1: CGPoint(x: sz.width * 0.66, y: y - 6),
                    control2: CGPoint(x: sz.width * 0.73, y: y - 6)
                )
                ctx.stroke(path, with: .color(.white), lineWidth: 3)
            }
            // Candle
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(Color(hex: "#A78BFA"))
                .frame(width: size * 0.09, height: size * 0.18)
                .offset(y: -(size * 0.16))
            // Flame
            Ellipse()
                .fill(Color(hex: "#FDE68A"))
                .frame(width: size * 0.09, height: size * 0.13)
                .offset(y: -(size * 0.30))
        }
        .frame(width: size, height: size)
    }
}

// 🍵 Tè Camomilla
private struct TeaView: View {
    let size: CGFloat
    var body: some View {
        ZStack {
            // Cup body
            Path { p in
                let w = size, h = size
                p.move(to: CGPoint(x: w * 0.22, y: h * 0.30))
                p.addLine(to: CGPoint(x: w * 0.28, y: h * 0.72))
                p.addCurve(
                    to: CGPoint(x: w * 0.72, y: h * 0.72),
                    control1: CGPoint(x: w * 0.35, y: h * 0.80),
                    control2: CGPoint(x: w * 0.65, y: h * 0.80)
                )
                p.addLine(to: CGPoint(x: w * 0.78, y: h * 0.30))
                p.closeSubpath()
            }
            .fill(Color(hex: "#FEF9C3"))
            .overlay(
                Path { p in
                    let w = size, h = size
                    p.move(to: CGPoint(x: w * 0.22, y: h * 0.30))
                    p.addLine(to: CGPoint(x: w * 0.28, y: h * 0.72))
                    p.addCurve(
                        to: CGPoint(x: w * 0.72, y: h * 0.72),
                        control1: CGPoint(x: w * 0.35, y: h * 0.80),
                        control2: CGPoint(x: w * 0.65, y: h * 0.80)
                    )
                    p.addLine(to: CGPoint(x: w * 0.78, y: h * 0.30))
                    p.closeSubpath()
                }.stroke(Color(hex: "#86EFAC"), lineWidth: 1.6)
            )
            // Tea fill
            Path { p in
                let w = size, h = size
                p.move(to: CGPoint(x: w * 0.26, y: h * 0.44))
                p.addLine(to: CGPoint(x: w * 0.30, y: h * 0.68))
                p.addCurve(
                    to: CGPoint(x: w * 0.70, y: h * 0.68),
                    control1: CGPoint(x: w * 0.37, y: h * 0.76),
                    control2: CGPoint(x: w * 0.63, y: h * 0.76)
                )
                p.addLine(to: CGPoint(x: w * 0.74, y: h * 0.44))
                p.closeSubpath()
            }
            .fill(Color(hex: "#4ADE80").opacity(0.35))
            // Handle
            Path { p in
                let w = size, h = size
                p.move(to: CGPoint(x: w * 0.78, y: h * 0.38))
                p.addCurve(
                    to: CGPoint(x: w * 0.78, y: h * 0.58),
                    control1: CGPoint(x: w * 0.96, y: h * 0.38),
                    control2: CGPoint(x: w * 0.96, y: h * 0.58)
                )
            }
            .stroke(Color(hex: "#86EFAC"), lineWidth: 2.2)
            // Steam
            ForEach([-1, 0, 1], id: \.self) { i in
                let xOff = size * (0.5 + CGFloat(i) * 0.12)
                Path { p in
                    p.move(to: CGPoint(x: xOff, y: size * 0.26))
                    p.addCurve(
                        to: CGPoint(x: xOff + size * 0.04, y: size * 0.08),
                        control1: CGPoint(x: xOff + size * 0.06, y: size * 0.20),
                        control2: CGPoint(x: xOff - size * 0.04, y: size * 0.14)
                    )
                }
                .stroke(Color(hex: "#86EFAC").opacity(0.65), lineWidth: 1.4)
            }
        }
        .frame(width: size, height: size)
    }
}

// 🥣 Ciotola di Ceramica
private struct BowlView: View {
    let size: CGFloat
    var body: some View {
        ZStack {
            Ellipse()
                .fill(Color(hex: "#BFDBFE"))
                .frame(width: size * 0.80, height: size * 0.48)
                .offset(y: size * 0.08)
            Path { p in
                let w = size, h = size
                p.move(to: CGPoint(x: w * 0.10, y: h * 0.50))
                p.addCurve(
                    to: CGPoint(x: w * 0.90, y: h * 0.50),
                    control1: CGPoint(x: w * 0.10, y: h * 0.82),
                    control2: CGPoint(x: w * 0.90, y: h * 0.82)
                )
            }
            .stroke(Color(hex: "#60A5FA"), lineWidth: 2)
            // Rim highlight
            Capsule()
                .fill(Color(hex: "#93C5FD"))
                .frame(width: size * 0.80, height: size * 0.14)
                .offset(y: size * 0.08)
            // Decorative dots
            ForEach([-0.18, 0.0, 0.18] as [CGFloat], id: \.self) { dx in
                Circle()
                    .fill(Color(hex: "#60A5FA").opacity(0.45))
                    .frame(width: size * 0.08, height: size * 0.08)
                    .offset(x: size * dx, y: size * 0.22)
            }
        }
        .frame(width: size, height: size)
    }
}

// 🛋️ Cuscino Lilla
private struct CushionView: View {
    let size: CGFloat
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.26, style: .continuous)
                .fill(LinearGradient(
                    colors: [Color(hex: "#C4B5FD"), Color(hex: "#8B5CF6")],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ))
                .frame(width: size * 0.82, height: size * 0.60)
            // Centre button
            Circle()
                .fill(Color(hex: "#7C3AED"))
                .frame(width: size * 0.14, height: size * 0.14)
            Circle()
                .fill(Color.white.opacity(0.3))
                .frame(width: size * 0.07, height: size * 0.07)
                .offset(x: -size * 0.02, y: -size * 0.02)
            // Corner tufts
            ForEach([(-0.28, -0.16), (0.28, -0.16), (-0.28, 0.16), (0.28, 0.16)] as [(CGFloat, CGFloat)], id: \.0) { dx, dy in
                Circle()
                    .fill(Color(hex: "#6D28D9").opacity(0.45))
                    .frame(width: size * 0.10, height: size * 0.10)
                    .offset(x: size * dx, y: size * dy)
            }
        }
        .frame(width: size, height: size)
    }
}

// ⭐ Copertina Stellata
private struct BlanketView: View {
    let size: CGFloat
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.14, style: .continuous)
                .fill(LinearGradient(
                    colors: [Color(hex: "#FEF9C3"), Color(hex: "#FDE68A")],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ))
                .frame(width: size * 0.82, height: size * 0.68)
            // Wavy bottom edge
            Canvas { ctx, sz in
                var p = Path()
                p.move(to: CGPoint(x: sz.width * 0.09, y: sz.height * 0.66))
                let steps: [(CGFloat, CGFloat)] = [(0.25, 0.60), (0.40, 0.66), (0.55, 0.60), (0.70, 0.66), (0.84, 0.60), (0.91, 0.64)]
                for (fx, fy) in steps {
                    p.addLine(to: CGPoint(x: sz.width * fx, y: sz.height * fy))
                }
                ctx.stroke(p, with: .color(Color(hex: "#F59E0B")), lineWidth: 2)
            }
            // Stars
            ForEach([(-0.16, -0.04), (0.14, -0.14), (0.0, 0.10), (-0.26, 0.16), (0.26, 0.12)] as [(CGFloat, CGFloat)], id: \.0) { dx, dy in
                Image(systemName: "star.fill")
                    .font(.system(size: size * 0.16))
                    .foregroundStyle(Color(hex: "#F59E0B").opacity(0.7))
                    .offset(x: size * dx, y: size * dy)
            }
        }
        .frame(width: size, height: size)
    }
}

// 🪴 Piantina Felice
private struct PlantView: View {
    let size: CGFloat
    var body: some View {
        ZStack {
            // Pot
            Path { p in
                let w = size, h = size
                p.move(to: CGPoint(x: w * 0.28, y: h * 0.54))
                p.addLine(to: CGPoint(x: w * 0.34, y: h * 0.80))
                p.addCurve(
                    to: CGPoint(x: w * 0.66, y: h * 0.80),
                    control1: CGPoint(x: w * 0.40, y: h * 0.86),
                    control2: CGPoint(x: w * 0.60, y: h * 0.86)
                )
                p.addLine(to: CGPoint(x: w * 0.72, y: h * 0.54))
                p.closeSubpath()
            }
            .fill(Color(hex: "#D97706"))
            // Rim
            Capsule()
                .fill(Color(hex: "#B45309"))
                .frame(width: size * 0.50, height: size * 0.12)
                .offset(y: size * 0.22)
            // Soil
            Ellipse()
                .fill(Color(hex: "#7C3D12").opacity(0.55))
                .frame(width: size * 0.34, height: size * 0.09)
                .offset(y: size * 0.18)
            // Leaves
            ForEach([((-0.28, -0.26), (-0.18, -0.40)), ((0.24, -0.28), (0.14, -0.44)), ((0.0, -0.44), (0.0, -0.56))] as [((CGFloat, CGFloat), (CGFloat, CGFloat))], id: \.0.0) { base, tip in
                Path { p in
                    p.move(to: CGPoint(x: size * 0.50, y: size * 0.22))
                    p.addCurve(
                        to: CGPoint(x: size * (0.50 + tip.0), y: size * (0.50 + tip.1)),
                        control1: CGPoint(x: size * (0.50 + base.0 * 0.4), y: size * (0.50 + base.1 * 0.4)),
                        control2: CGPoint(x: size * (0.50 + tip.0 * 0.7), y: size * (0.50 + tip.1 * 0.6))
                    )
                }
                .stroke(Color(hex: "#22C55E"), lineWidth: 2.6)
            }
        }
        .frame(width: size, height: size)
    }
}

// 🌙 Lampada Lunare
private struct LampView: View {
    let size: CGFloat
    var body: some View {
        ZStack {
            // Glow aura
            Circle()
                .fill(Color(hex: "#FDE68A").opacity(0.28))
                .frame(width: size * 0.70, height: size * 0.70)
                .offset(y: -(size * 0.10))
            // Moon circle
            Circle()
                .fill(Color(hex: "#FDE68A"))
                .frame(width: size * 0.46, height: size * 0.46)
                .offset(y: -(size * 0.10))
            // Crescent overlay
            Circle()
                .fill(Color(hex: "#FEF9C3"))
                .frame(width: size * 0.22, height: size * 0.22)
                .offset(x: -(size * 0.10), y: -(size * 0.20))
            // Stand
            Rectangle()
                .fill(Color(hex: "#B45309"))
                .frame(width: size * 0.07, height: size * 0.26)
                .offset(y: size * 0.22)
            // Base
            Capsule()
                .fill(Color(hex: "#D97706"))
                .frame(width: size * 0.32, height: size * 0.09)
                .offset(y: size * 0.36)
        }
        .frame(width: size, height: size)
    }
}

// 🎨 Tappeto Arcobaleno
private struct RugView: View {
    let size: CGFloat
    var body: some View {
        ZStack {
            Ellipse()
                .fill(Color(hex: "#C4B5FD"))
                .frame(width: size * 0.88, height: size * 0.50)
            Ellipse()
                .fill(Color(hex: "#F9A8D4"))
                .frame(width: size * 0.64, height: size * 0.34)
            Ellipse()
                .fill(Color(hex: "#FDE68A"))
                .frame(width: size * 0.38, height: size * 0.20)
            // Outer ring dots
            ForEach(0..<6) { i in
                let angle = Double(i) * .pi / 3.0
                let rx = size * 0.36, ry = size * 0.20
                Circle()
                    .fill(Color(hex: "#7C3AED").opacity(0.55))
                    .frame(width: size * 0.08, height: size * 0.08)
                    .offset(x: rx * CGFloat(cos(angle)), y: ry * CGFloat(sin(angle)))
            }
        }
        .frame(width: size, height: size)
    }
}

// 💜 Cristallo Viola
private struct CrystalView: View {
    let size: CGFloat
    var body: some View {
        ZStack {
            // Glow
            Circle()
                .fill(Color(hex: "#7C3AED").opacity(0.14))
                .frame(width: size * 0.80, height: size * 0.80)
            // Main crystal
            Path { p in
                let cx = size / 2, cy = size / 2
                p.move(to: CGPoint(x: cx, y: cy - size * 0.38))
                p.addLine(to: CGPoint(x: cx + size * 0.24, y: cy - size * 0.12))
                p.addLine(to: CGPoint(x: cx + size * 0.18, y: cy + size * 0.32))
                p.addLine(to: CGPoint(x: cx, y: cy + size * 0.38))
                p.addLine(to: CGPoint(x: cx - size * 0.18, y: cy + size * 0.32))
                p.addLine(to: CGPoint(x: cx - size * 0.24, y: cy - size * 0.12))
                p.closeSubpath()
            }
            .fill(LinearGradient(
                colors: [Color(hex: "#DDD6FE"), Color(hex: "#7C3AED")],
                startPoint: .top, endPoint: .bottom
            ))
            // Inner facet highlight
            Path { p in
                let cx = size / 2, cy = size / 2
                p.move(to: CGPoint(x: cx, y: cy - size * 0.38))
                p.addLine(to: CGPoint(x: cx + size * 0.10, y: cy - size * 0.08))
                p.addLine(to: CGPoint(x: cx, y: cy - size * 0.02))
                p.addLine(to: CGPoint(x: cx - size * 0.10, y: cy - size * 0.08))
                p.closeSubpath()
            }
            .fill(Color.white.opacity(0.30))
            // Sparkles
            ForEach([(0.36, -0.26), (-0.32, -0.14), (0.28, 0.20)] as [(CGFloat, CGFloat)], id: \.0) { dx, dy in
                Image(systemName: "sparkle")
                    .font(.system(size: size * 0.14))
                    .foregroundStyle(Color(hex: "#A78BFA"))
                    .offset(x: size * dx, y: size * dy)
            }
        }
        .frame(width: size, height: size)
    }
}

// 📖 Libro dei Sogni
private struct BookView: View {
    let size: CGFloat
    var body: some View {
        ZStack {
            // Back cover
            RoundedRectangle(cornerRadius: size * 0.08, style: .continuous)
                .fill(Color(hex: "#3B82F6"))
                .frame(width: size * 0.68, height: size * 0.76)
                .offset(x: size * 0.06)
            // Pages
            RoundedRectangle(cornerRadius: size * 0.04, style: .continuous)
                .fill(Color.white)
                .frame(width: size * 0.52, height: size * 0.70)
                .offset(x: size * 0.08)
            // Text lines
            ForEach([-0.18, -0.06, 0.06, 0.18] as [CGFloat], id: \.self) { dy in
                RoundedRectangle(cornerRadius: 1.5, style: .continuous)
                    .fill(Color(hex: "#BAE6FD"))
                    .frame(width: size * 0.32, height: size * 0.04)
                    .offset(x: size * 0.08, y: size * dy)
            }
            // Spine
            RoundedRectangle(cornerRadius: size * 0.06, style: .continuous)
                .fill(Color(hex: "#1D4ED8"))
                .frame(width: size * 0.14, height: size * 0.76)
                .offset(x: -(size * 0.20))
            // Star on cover
            Image(systemName: "moon.stars.fill")
                .font(.system(size: size * 0.20))
                .foregroundStyle(Color(hex: "#FDE68A"))
                .offset(x: -(size * 0.02), y: -(size * 0.16))
        }
        .frame(width: size, height: size)
    }
}

// 🕯️ Candela Aromatica
private struct CandleView: View {
    let size: CGFloat
    var body: some View {
        ZStack {
            // Wax pool glow
            Ellipse()
                .fill(Color(hex: "#FDE68A").opacity(0.22))
                .frame(width: size * 0.60, height: size * 0.28)
                .offset(y: size * 0.30)
            // Candle body
            RoundedRectangle(cornerRadius: size * 0.12, style: .continuous)
                .fill(LinearGradient(
                    colors: [Color(hex: "#FEF9C3"), Color(hex: "#FDE68A")],
                    startPoint: .leading, endPoint: .trailing
                ))
                .frame(width: size * 0.38, height: size * 0.52)
                .offset(y: size * 0.10)
            // Drip
            Capsule()
                .fill(Color(hex: "#FEF9C3"))
                .frame(width: size * 0.08, height: size * 0.16)
                .offset(x: size * 0.12, y: -(size * 0.02))
            // Wick
            Rectangle()
                .fill(Color(hex: "#44403C"))
                .frame(width: size * 0.025, height: size * 0.10)
                .offset(y: -(size * 0.22))
            // Flame outer
            Ellipse()
                .fill(Color(hex: "#FB923C"))
                .frame(width: size * 0.16, height: size * 0.22)
                .offset(y: -(size * 0.34))
            // Flame inner
            Ellipse()
                .fill(Color(hex: "#FDE68A"))
                .frame(width: size * 0.09, height: size * 0.14)
                .offset(y: -(size * 0.36))
            // Scent dots
            ForEach([(-0.14, -0.46), (0.0, -0.50), (0.14, -0.46)] as [(CGFloat, CGFloat)], id: \.0) { dx, dy in
                Circle()
                    .fill(Color(hex: "#A78BFA").opacity(0.50))
                    .frame(width: size * 0.07, height: size * 0.07)
                    .offset(x: size * dx, y: size * dy)
            }
        }
        .frame(width: size, height: size)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: ACIconStyle — card colors per item
// ─────────────────────────────────────────────────────────────────────────────

struct ACIconStyle {
    let cardTop: Color
    let cardBottom: Color
    let accent: Color

    static func style(for id: String) -> ACIconStyle {
        switch id {
        case "food_carrot":
            return .init(cardTop: Color(hex: "#FFF7E6"), cardBottom: Color(hex: "#FFE0A0"), accent: Color(hex: "#F59E0B"))
        case "food_cookie":
            return .init(cardTop: Color(hex: "#FFF0E6"), cardBottom: Color(hex: "#FFD9B8"), accent: Color(hex: "#F87171"))
        case "food_cake":
            return .init(cardTop: Color(hex: "#FFE8EF"), cardBottom: Color(hex: "#FFBFD4"), accent: Color(hex: "#F87171"))
        case "food_tea":
            return .init(cardTop: Color(hex: "#F0FFF8"), cardBottom: Color(hex: "#C6F0D6"), accent: Color(hex: "#34D399"))
        case "essential_bowl":
            return .init(cardTop: Color(hex: "#EFF6FF"), cardBottom: Color(hex: "#BFDBFE"), accent: Color(hex: "#60A5FA"))
        case "essential_cushion":
            return .init(cardTop: Color(hex: "#F5F0FF"), cardBottom: Color(hex: "#DDD6FE"), accent: Color(hex: "#A78BFA"))
        case "essential_blanket":
            return .init(cardTop: Color(hex: "#FEFCE8"), cardBottom: Color(hex: "#FEF08A"), accent: Color(hex: "#F59E0B"))
        case "deco_plant":
            return .init(cardTop: Color(hex: "#F0FDF4"), cardBottom: Color(hex: "#BBF7D0"), accent: Color(hex: "#34D399"))
        case "deco_lamp":
            return .init(cardTop: Color(hex: "#FEFCE8"), cardBottom: Color(hex: "#FDE68A"), accent: Color(hex: "#F59E0B"))
        case "deco_rug":
            return .init(cardTop: Color(hex: "#FDF4FF"), cardBottom: Color(hex: "#E9D5FF"), accent: Color(hex: "#A78BFA"))
        case "special_crystal":
            return .init(cardTop: Color(hex: "#F5F0FF"), cardBottom: Color(hex: "#C4B5FD"), accent: Color(hex: "#7C3AED"))
        case "special_book":
            return .init(cardTop: Color(hex: "#EFF6FF"), cardBottom: Color(hex: "#BAE6FD"), accent: Color(hex: "#60A5FA"))
        case "special_candle":
            return .init(cardTop: Color(hex: "#FFF7ED"), cardBottom: Color(hex: "#FED7AA"), accent: Color(hex: "#F59E0B"))
        default:
            return .init(cardTop: Color(hex: "#F3F4F6"), cardBottom: Color(hex: "#E5E7EB"), accent: .gray)
        }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: ACNavIcon helpers
// ─────────────────────────────────────────────────────────────────────────────

extension ACNavIcon.Kind {
    var color: Color {
        switch self {
        case .store:     return Color(hex: "#F87171")
        case .inventory: return Color(hex: "#60A5FA")
        case .decorate:  return Color(hex: "#A78BFA")
        case .meTime:    return Color(hex: "#F59E0B")
        }
    }
    @ViewBuilder var symbolImage: some View {
        switch self {
        case .store:     Image(systemName: "bag.fill")
        case .inventory: Image(systemName: "backpack.fill")
        case .decorate:  Image(systemName: "wand.and.stars")
        case .meTime:    Image(systemName: "sparkles.rectangle.stack.fill")
        }
    }
}
