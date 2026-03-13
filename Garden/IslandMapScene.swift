import SpriteKit

// MARK: - Zona toccabile

enum IslandZone: String {
    case garden    = "Giardino"
    case house     = "Casa"
    case sea       = "Riva del Mare"
    case shop      = "Negozio"
}

// MARK: - IslandMapScene
// Vista dall'alto in stile Animal Crossing: prato verde, casa in legno,
// alberi, fiori, riva del mare. Ogni zona ha un'etichetta e un'area toccabile.

final class IslandMapScene: SKScene {

    // Callback invocato quando l'utente tocca una zona
    var onZoneTapped: ((IslandZone) -> Void)?

    // Mappa zona → nodo principale (per hit-test)
    private var zoneNodes: [IslandZone: SKNode] = [:]

    // MARK: – Lifecycle

    override func didMove(to view: SKView) {
        backgroundColor = .clear
        scaleMode = .resizeFill
        buildIsland()
    }

    // MARK: – Touch

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let pos = touches.first.map({ convert($0.location(in: view!), from: nil) }) else { return }
        for (zone, node) in zoneNodes {
            if node.contains(pos) {
                animateTap(node)
                onZoneTapped?(zone)
                return
            }
        }
    }

    // MARK: – Costruzione

    private func buildIsland() {
        let W = size.width
        let H = size.height

        // ── Prato base ─────────────────────────────────────────────────────
        let grass = SKShapeNode(
            ellipseOf: CGSize(width: W * 0.92, height: H * 0.88)
        )
        grass.fillColor = UIColor(red: 0.50, green: 0.78, blue: 0.46, alpha: 1)
        grass.strokeColor = UIColor(red: 0.36, green: 0.62, blue: 0.32, alpha: 1)
        grass.lineWidth = 3
        grass.position = CGPoint(x: W / 2, y: H / 2 - H * 0.02)
        addChild(grass)

        // ── Riva del mare (basso) ──────────────────────────────────────────
        addSeaZone(W: W, H: H)

        // ── Sentieri (linee sterrate) ──────────────────────────────────────
        addPaths(W: W, H: H)

        // ── Zona Giardino (sinistra-centro) ───────────────────────────────
        addGardenZone(W: W, H: H)

        // ── Casa (centro-alto) ─────────────────────────────────────────────
        addHouseZone(W: W, H: H)

        // ── Negozio (destra-centro) ────────────────────────────────────────
        addShopZone(W: W, H: H)

        // ── Alberi decorativi ──────────────────────────────────────────────
        addTrees(W: W, H: H)

        // ── Fiori sparsi ───────────────────────────────────────────────────
        addFlowers(W: W, H: H)
    }

    // MARK: – Zone

    private func addSeaZone(W: CGFloat, H: CGFloat) {
        let seaPath = CGMutablePath()
        seaPath.addEllipse(in: CGRect(x: W * 0.04, y: H * 0.04,
                                      width: W * 0.92, height: H * 0.24))
        let sea = SKShapeNode(path: seaPath)
        sea.fillColor = UIColor(red: 0.44, green: 0.74, blue: 0.96, alpha: 1)
        sea.strokeColor = UIColor(red: 0.25, green: 0.56, blue: 0.84, alpha: 1)
        sea.lineWidth = 2
        sea.position = .zero
        addChild(sea)

        // Onde decorative
        for i in 0..<3 {
            let wave = waveLabel()
            wave.position = CGPoint(x: W * 0.3 + CGFloat(i) * W * 0.15, y: H * 0.14)
            wave.run(.repeatForever(.sequence([
                .moveBy(x: 4, y: 2, duration: 1.2 + Double(i) * 0.3),
                .moveBy(x: -4, y: -2, duration: 1.2 + Double(i) * 0.3)
            ])))
            addChild(wave)
        }

        // Hit area
        let hitArea = SKShapeNode(rect: CGRect(x: W * 0.1, y: H * 0.03,
                                               width: W * 0.80, height: H * 0.22))
        hitArea.fillColor = .clear
        hitArea.strokeColor = .clear
        addChild(hitArea)
        zoneNodes[.sea] = hitArea

        addLabel("🌊 \(IslandZone.sea.rawValue)",
                 at: CGPoint(x: W / 2, y: H * 0.13),
                 size: 11)
    }

    private func addGardenZone(W: CGFloat, H: CGFloat) {
        let center = CGPoint(x: W * 0.24, y: H * 0.48)
        let plot = roundedRect(size: CGSize(width: W * 0.28, height: H * 0.26),
                               at: center,
                               fill: UIColor(red: 0.38, green: 0.65, blue: 0.28, alpha: 1),
                               stroke: UIColor(red: 0.24, green: 0.50, blue: 0.18, alpha: 1))
        addChild(plot)
        zoneNodes[.garden] = plot

        // Righe di semina
        for row in 0..<3 {
            let rowNode = SKShapeNode(rectOf: CGSize(width: W * 0.22, height: 4), cornerRadius: 2)
            rowNode.fillColor = UIColor(red: 0.29, green: 0.50, blue: 0.18, alpha: 0.7)
            rowNode.strokeColor = .clear
            rowNode.position = CGPoint(x: center.x, y: center.y - H * 0.07 + CGFloat(row) * H * 0.055)
            addChild(rowNode)
        }

        // Pianticelle 🌱
        let plantPositions = [
            CGPoint(x: center.x - W * 0.08, y: center.y + H * 0.02),
            CGPoint(x: center.x,             y: center.y + H * 0.02),
            CGPoint(x: center.x + W * 0.08, y: center.y + H * 0.02),
        ]
        for p in plantPositions {
            let plant = miniLabel("🌱", at: p, size: 16)
            addChild(plant)
        }

        addLabel("🌿 \(IslandZone.garden.rawValue)",
                 at: CGPoint(x: center.x, y: center.y - H * 0.14),
                 size: 11)
    }

    private func addHouseZone(W: CGFloat, H: CGFloat) {
        let center = CGPoint(x: W * 0.52, y: H * 0.63)

        // Fondamenta
        let base = SKShapeNode(rectOf: CGSize(width: W * 0.28, height: H * 0.14), cornerRadius: 5)
        base.fillColor = UIColor(red: 0.90, green: 0.83, blue: 0.72, alpha: 1)
        base.strokeColor = UIColor(red: 0.65, green: 0.52, blue: 0.38, alpha: 1)
        base.lineWidth = 2
        base.position = center
        addChild(base)

        // Tetto
        let roofPath = buildRoofPath(
            baseCenter: center,
            baseW: W * 0.30, baseH: H * 0.14,
            apexY: center.y + H * 0.17
        )
        let roof = SKShapeNode(path: roofPath)
        roof.fillColor = UIColor(red: 0.78, green: 0.36, blue: 0.32, alpha: 1)
        roof.strokeColor = UIColor(red: 0.58, green: 0.22, blue: 0.18, alpha: 1)
        roof.lineWidth = 2
        addChild(roof)

        // Porta
        let door = SKShapeNode(
            rectOf: CGSize(width: W * 0.06, height: H * 0.08),
            cornerRadius: 3
        )
        door.fillColor = UIColor(red: 0.55, green: 0.38, blue: 0.23, alpha: 1)
        door.strokeColor = .clear
        door.position = CGPoint(x: center.x, y: center.y - H * 0.03)
        addChild(door)

        // Finestre (2)
        for xOff in [-W * 0.09, W * 0.09] as [CGFloat] {
            let win = SKShapeNode(rectOf: CGSize(width: W * 0.05, height: H * 0.045), cornerRadius: 2)
            win.fillColor = UIColor(red: 0.87, green: 0.95, blue: 1.0, alpha: 1)
            win.strokeColor = UIColor(red: 0.65, green: 0.52, blue: 0.38, alpha: 1)
            win.lineWidth = 1.5
            win.position = CGPoint(x: center.x + xOff, y: center.y + H * 0.02)
            addChild(win)
        }

        // Comignolo
        let chimney = SKShapeNode(rectOf: CGSize(width: W * 0.04, height: H * 0.06), cornerRadius: 2)
        chimney.fillColor = UIColor(red: 0.72, green: 0.52, blue: 0.38, alpha: 1)
        chimney.strokeColor = UIColor(red: 0.55, green: 0.38, blue: 0.23, alpha: 1)
        chimney.lineWidth = 1.5
        chimney.position = CGPoint(x: center.x + W * 0.07, y: center.y + H * 0.18)
        addChild(chimney)

        // Fumo dal comignolo
        let smoke = miniLabel("💨", at: CGPoint(x: center.x + W * 0.07, y: center.y + H * 0.235), size: 12)
        smoke.run(.repeatForever(.sequence([
            .fadeAlpha(to: 0.3, duration: 1.4),
            .fadeAlpha(to: 1.0, duration: 1.4)
        ])))
        addChild(smoke)

        // Hit area (include anche il tetto)
        let hitArea = SKShapeNode(rectOf: CGSize(width: W * 0.32, height: H * 0.34))
        hitArea.fillColor = .clear
        hitArea.strokeColor = .clear
        hitArea.position = CGPoint(x: center.x, y: center.y + H * 0.07)
        addChild(hitArea)
        zoneNodes[.house] = hitArea

        addLabel("🏡 \(IslandZone.house.rawValue)",
                 at: CGPoint(x: center.x, y: center.y - H * 0.10),
                 size: 11)
    }

    private func addShopZone(W: CGFloat, H: CGFloat) {
        let center = CGPoint(x: W * 0.78, y: H * 0.50)

        // Corpo negozio
        let body = SKShapeNode(rectOf: CGSize(width: W * 0.22, height: H * 0.16), cornerRadius: 6)
        body.fillColor = UIColor(red: 0.99, green: 0.91, blue: 0.72, alpha: 1)
        body.strokeColor = UIColor(red: 0.80, green: 0.60, blue: 0.30, alpha: 1)
        body.lineWidth = 2
        body.position = center
        addChild(body)

        // Tettoia a strisce
        let awningPath = buildAwningPath(center: CGPoint(x: center.x, y: center.y + H * 0.08),
                                          w: W * 0.24, h: H * 0.05)
        let awning = SKShapeNode(path: awningPath)
        awning.fillColor = UIColor(red: 0.87, green: 0.30, blue: 0.35, alpha: 1)
        awning.strokeColor = UIColor(red: 0.70, green: 0.18, blue: 0.22, alpha: 1)
        awning.lineWidth = 1.5
        addChild(awning)

        // Insegna "SHOP"
        let sign = SKLabelNode(text: "🛒")
        sign.fontSize = 18
        sign.verticalAlignmentMode = .center
        sign.horizontalAlignmentMode = .center
        sign.position = CGPoint(x: center.x, y: center.y + H * 0.06)
        addChild(sign)

        // Hit area
        let hitArea = SKShapeNode(rectOf: CGSize(width: W * 0.26, height: H * 0.26))
        hitArea.fillColor = .clear
        hitArea.strokeColor = .clear
        hitArea.position = CGPoint(x: center.x, y: center.y + H * 0.03)
        addChild(hitArea)
        zoneNodes[.shop] = hitArea

        addLabel("🛒 \(IslandZone.shop.rawValue)",
                 at: CGPoint(x: center.x, y: center.y - H * 0.11),
                 size: 11)
    }

    // MARK: – Sentieri

    private func addPaths(W: CGFloat, H: CGFloat) {
        let configs: [(CGPoint, CGPoint)] = [
            // Dalla casa verso giardino
            (CGPoint(x: W * 0.38, y: H * 0.57), CGPoint(x: W * 0.36, y: H * 0.48)),
            // Dalla casa verso negozio
            (CGPoint(x: W * 0.66, y: H * 0.57), CGPoint(x: W * 0.66, y: H * 0.50)),
            // Dalla riva verso casa
            (CGPoint(x: W * 0.50, y: H * 0.27), CGPoint(x: W * 0.50, y: H * 0.55)),
        ]
        for (a, b) in configs {
            let path = CGMutablePath()
            path.move(to: a)
            path.addLine(to: b)
            let road = SKShapeNode(path: path)
            road.strokeColor = UIColor(red: 0.82, green: 0.72, blue: 0.56, alpha: 0.7)
            road.lineWidth = 7
            road.lineCap = .round
            road.zPosition = -1
            addChild(road)
        }
    }

    // MARK: – Alberi

    private func addTrees(W: CGFloat, H: CGFloat) {
        let positions: [CGPoint] = [
            CGPoint(x: W * 0.10, y: H * 0.72),
            CGPoint(x: W * 0.14, y: H * 0.34),
            CGPoint(x: W * 0.88, y: H * 0.76),
            CGPoint(x: W * 0.86, y: H * 0.30),
            CGPoint(x: W * 0.50, y: H * 0.83),
        ]
        for p in positions {
            let tree = buildMiniTree(at: p, scale: CGFloat.random(in: 0.8...1.1))
            addChild(tree)
        }
    }

    private func buildMiniTree(at pos: CGPoint, scale: CGFloat) -> SKNode {
        let container = SKNode()
        container.position = pos

        let trunkW = 8 * scale
        let trunkH = 12 * scale
        let trunk = SKShapeNode(rectOf: CGSize(width: trunkW, height: trunkH), cornerRadius: 2)
        trunk.fillColor = UIColor(red: 0.55, green: 0.38, blue: 0.23, alpha: 1)
        trunk.strokeColor = .clear
        container.addChild(trunk)

        for (i, (radius, color, yOff)) in [
            (20 * scale, UIColor(red: 0.22, green: 0.60, blue: 0.18, alpha: 1), 22 * scale),
            (15 * scale, UIColor(red: 0.30, green: 0.70, blue: 0.25, alpha: 1), 34 * scale),
            (10 * scale, UIColor(red: 0.38, green: 0.78, blue: 0.30, alpha: 1), 44 * scale),
        ].enumerated() {
            let layer = SKShapeNode(circleOfRadius: radius)
            layer.fillColor = color
            layer.strokeColor = .clear
            layer.position = CGPoint(x: 0, y: yOff)
            layer.zPosition = CGFloat(i)
            container.addChild(layer)
        }

        // Leggero dondolio
        let sway = SKAction.repeatForever(.sequence([
            .rotate(byAngle: 0.04, duration: 1.8),
            .rotate(byAngle: -0.04, duration: 1.8)
        ]))
        container.run(sway)
        return container
    }

    // MARK: – Fiori

    private func addFlowers(W: CGFloat, H: CGFloat) {
        let coords: [(CGFloat, CGFloat, String)] = [
            (0.18, 0.55, "🌸"), (0.30, 0.38, "🌼"),
            (0.63, 0.42, "🌺"), (0.72, 0.68, "🌸"),
            (0.42, 0.74, "🌻"), (0.84, 0.60, "🌼"),
        ]
        for (xf, yf, emoji) in coords {
            let f = miniLabel(emoji, at: CGPoint(x: W * xf, y: H * yf), size: 14)
            f.run(.repeatForever(.sequence([
                .scale(to: 1.15, duration: 1.0 + Double.random(in: 0...0.5)),
                .scale(to: 0.90, duration: 1.0 + Double.random(in: 0...0.5))
            ])))
            addChild(f)
        }
    }

    // MARK: – Tap feedback

    private func animateTap(_ node: SKNode) {
        node.run(.sequence([
            .scale(to: 0.93, duration: 0.07),
            .scale(to: 1.00, duration: 0.12)
        ]))
    }

    // MARK: – Helpers geometria

    private func roundedRect(size: CGSize, at pos: CGPoint,
                              fill: UIColor, stroke: UIColor) -> SKShapeNode {
        let n = SKShapeNode(rectOf: size, cornerRadius: 10)
        n.fillColor = fill
        n.strokeColor = stroke
        n.lineWidth = 2
        n.position = pos
        return n
    }

    private func buildRoofPath(baseCenter: CGPoint,
                                baseW: CGFloat, baseH: CGFloat,
                                apexY: CGFloat) -> CGPath {
        let path = CGMutablePath()
        let left  = CGPoint(x: baseCenter.x - baseW / 2, y: baseCenter.y + baseH / 2)
        let right = CGPoint(x: baseCenter.x + baseW / 2, y: baseCenter.y + baseH / 2)
        let apex  = CGPoint(x: baseCenter.x, y: apexY)
        path.move(to: left)
        path.addLine(to: right)
        path.addLine(to: apex)
        path.closeSubpath()
        return path
    }

    private func buildAwningPath(center: CGPoint, w: CGFloat, h: CGFloat) -> CGPath {
        let path = CGMutablePath()
        path.move(to:    CGPoint(x: center.x - w / 2, y: center.y))
        path.addLine(to: CGPoint(x: center.x + w / 2, y: center.y))
        path.addLine(to: CGPoint(x: center.x + w / 2, y: center.y - h))
        // Lembo onda
        let steps = 6
        let stepW = w / CGFloat(steps)
        for i in 0..<steps {
            let x = center.x + w / 2 - CGFloat(i + 1) * stepW
            let yOff: CGFloat = (i % 2 == 0) ? -h * 0.5 : 0
            path.addLine(to: CGPoint(x: x, y: center.y - h + yOff))
        }
        path.closeSubpath()
        return path
    }

    private func addLabel(_ text: String, at pos: CGPoint, size: CGFloat) {
        let l = SKLabelNode(text: text)
        l.fontSize = size
        l.fontName = "AvenirNext-Bold"
        l.fontColor = UIColor(red: 0.18, green: 0.28, blue: 0.14, alpha: 1)
        l.verticalAlignmentMode = .center
        l.horizontalAlignmentMode = .center
        l.position = pos
        addChild(l)
    }

    private func miniLabel(_ text: String, at pos: CGPoint, size: CGFloat) -> SKLabelNode {
        let l = SKLabelNode(text: text)
        l.fontSize = size
        l.verticalAlignmentMode = .center
        l.horizontalAlignmentMode = .center
        l.position = pos
        return l
    }

    private func waveLabel() -> SKLabelNode {
        let l = SKLabelNode(text: "〜")
        l.fontSize = 13
        l.fontColor = UIColor(red: 0.90, green: 0.96, blue: 1.0, alpha: 0.8)
        l.verticalAlignmentMode = .center
        l.horizontalAlignmentMode = .center
        return l
    }
}
