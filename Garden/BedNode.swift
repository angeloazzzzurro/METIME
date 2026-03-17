import SpriteKit

// MARK: - BedNode
// Letto stile Animal Crossing: cornice in legno caldo, coperta azzurra puntinata,
// cuscino pesca, testiera arrotondata con cuoricino rosa.
// Quando il pet è sonnolento appaiono le "Z" fluttuanti sopra il cuscino.

final class BedNode: SKNode {

    // ── Dimensioni ─────────────────────────────────────────────────────────
    private static let W: CGFloat   = 90   // larghezza cornice letto
    private static let H: CGFloat   = 54   // altezza cornice letto
    private static let HBH: CGFloat = 38   // altezza testiera
    private static let LEG: CGFloat = 13   // altezza gambe

    // Offset tra la top del terreno e il centro del nodo (gambe + metà cornice).
    // Usato da GardenScene per appoggiare il letto esattamente sul prato.
    static var groundOffset: CGFloat { LEG + H / 2 }

    // ── ZZZ container ──────────────────────────────────────────────────────
    private var zzzContainer: SKNode?

    // ── Init ───────────────────────────────────────────────────────────────
    override init() {
        super.init()
        buildBed()
    }

    required init?(coder aDecoder: NSCoder) { return nil }

    // MARK: – Costruzione

    private func buildBed() {
        let w = BedNode.W
        let h = BedNode.H
        let hbH = BedNode.HBH
        let legH = BedNode.LEG

        // ── Gambe ──────────────────────────────────────────────────────────
        for xOff in [-(w / 2 - 8), (w / 2 - 8)] as [CGFloat] {
            let leg = SKShapeNode(rectOf: CGSize(width: 10, height: legH), cornerRadius: 2)
            leg.fillColor = woodDark
            leg.strokeColor = .clear
            leg.position = CGPoint(x: xOff, y: -h / 2 - legH / 2)
            addChild(leg)
        }

        // ── Cornice (legno caldo) ──────────────────────────────────────────
        let frame = SKShapeNode(rectOf: CGSize(width: w, height: h), cornerRadius: 7)
        frame.fillColor = woodLight
        frame.strokeColor = woodDark
        frame.lineWidth = 2
        addChild(frame)

        // ── Materasso (crema) ──────────────────────────────────────────────
        let mattress = SKShapeNode(rectOf: CGSize(width: w - 8, height: h - 6), cornerRadius: 5)
        mattress.fillColor = cream
        mattress.strokeColor = .clear
        addChild(mattress)

        // ── Coperta (azzurro pastello con puntini) ─────────────────────────
        let blankH: CGFloat = (h - 8) * 0.57
        let blankY: CGFloat = -(h / 2 - blankH / 2 - 2)
        let blanket = SKShapeNode(rectOf: CGSize(width: w - 10, height: blankH), cornerRadius: 5)
        blanket.fillColor = blanketBlue
        blanket.strokeColor = blanketBlueDark
        blanket.lineWidth = 1.5
        blanket.position = CGPoint(x: 0, y: blankY)
        addChild(blanket)

        // Piega superiore coperta
        addLine(
            from: CGPoint(x: -(w / 2 - 9), y: blankY + blankH / 2 - 5),
            to:   CGPoint(x:  (w / 2 - 9), y: blankY + blankH / 2 - 5),
            color: UIColor(red: 0.85, green: 0.93, blue: 1.0, alpha: 0.85),
            width: 2.5
        )

        // Puntini coperta (3 colonne × 2 righe)
        for row in 0..<2 {
            for col in 0..<3 {
                let dot = SKShapeNode(circleOfRadius: 2)
                dot.fillColor = blanketBlueDark.withAlphaComponent(0.55)
                dot.strokeColor = .clear
                dot.position = CGPoint(
                    x: -14 + CGFloat(col) * 14,
                    y: blankY - 5 + CGFloat(row) * 10
                )
                addChild(dot)
            }
        }

        // ── Cuscino (pesca caldo) ──────────────────────────────────────────
        let pillow = SKShapeNode(ellipseOf: CGSize(width: w * 0.44, height: h * 0.27))
        pillow.fillColor = peach
        pillow.strokeColor = peachDark
        pillow.lineWidth = 1.5
        pillow.position = CGPoint(x: 0, y: h / 2 - 12)
        addChild(pillow)

        // ── Testiera (legno, angoli superiori arrotondati) ─────────────────
        let hbPath = UIBezierPath(
            roundedRect: CGRect(x: -w / 2 - 4, y: h / 2 - 2, width: w + 8, height: hbH),
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: 12, height: 12)
        )
        let headboard = SKShapeNode(path: hbPath.cgPath)
        headboard.fillColor = woodLight
        headboard.strokeColor = woodDark
        headboard.lineWidth = 2
        addChild(headboard)

        // Pannello interno testiera (legno più chiaro)
        let panelPath = UIBezierPath(
            roundedRect: CGRect(x: -w / 2 + 7, y: h / 2 + 6, width: w - 14, height: hbH - 14),
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: 7, height: 7)
        )
        let panel = SKShapeNode(path: panelPath.cgPath)
        panel.fillColor = woodPanel
        panel.strokeColor = .clear
        addChild(panel)

        // ── Cuoricino sulla testiera ───────────────────────────────────────
        let heart = SKLabelNode(text: "♡")
        heart.fontSize = 17
        heart.fontColor = UIColor(red: 1.0, green: 0.56, blue: 0.65, alpha: 1)
        heart.verticalAlignmentMode = .center
        heart.horizontalAlignmentMode = .center
        heart.position = CGPoint(x: 0, y: h / 2 + hbH / 2 + 1)
        addChild(heart)

        // Leggero dondolio idle
        let tiltRight = SKAction.rotate(toAngle:  0.015, duration: 2.5, shortestUnitArc: true)
        let tiltLeft  = SKAction.rotate(toAngle: -0.015, duration: 2.5, shortestUnitArc: true)
        run(.repeatForever(.sequence([tiltRight, tiltLeft])))
    }

    // MARK: – ZZZ (mood sonnolento)

    func startSleepingZZZ() {
        stopSleepingZZZ()
        let container = SKNode()
        zzzContainer = container
        addChild(container)

        let baseX: CGFloat = BedNode.W / 2 - 2
        let baseY: CGFloat = BedNode.H / 2 + BedNode.HBH + 12
        let configs: [(String, CGFloat)] = [("z", 11), ("z", 15), ("Z", 20)]

        for (i, (letter, size)) in configs.enumerated() {
            let z = makeZLabel(text: letter, fontSize: size)
            let startPos = CGPoint(x: baseX + CGFloat(i) * 4, y: baseY)
            z.position = startPos
            z.alpha = 0
            container.addChild(z)

            let delay  = SKAction.wait(forDuration: Double(i) * 0.65)
            let show   = SKAction.fadeIn(withDuration: 0.25)
            let float  = SKAction.moveBy(x: CGFloat(i) * 4 + 3, y: 32, duration: 1.6)
            let fade   = SKAction.sequence([.wait(forDuration: 1.1), .fadeOut(withDuration: 0.35)])
            let reset  = SKAction.run { [weak z] in
                z?.position = startPos
                z?.alpha = 0
            }
            let gap    = SKAction.wait(forDuration: Double(3 - i) * 0.65)
            let seq    = SKAction.sequence([delay, .group([float, .sequence([show, fade])]), reset, gap])
            z.run(.repeatForever(seq))
        }
    }

    func stopSleepingZZZ() {
        zzzContainer?.removeFromParent()
        zzzContainer = nil
    }

    // MARK: – Helpers

    private func addLine(from a: CGPoint, to b: CGPoint, color: UIColor, width: CGFloat) {
        let path = CGMutablePath()
        path.move(to: a)
        path.addLine(to: b)
        let node = SKShapeNode(path: path)
        node.strokeColor = color
        node.lineWidth = width
        addChild(node)
    }

    private func makeZLabel(text: String, fontSize: CGFloat) -> SKLabelNode {
        let l = SKLabelNode(text: text)
        l.fontSize = fontSize
        l.fontName = "AvenirNext-Bold"
        l.fontColor = UIColor(red: 0.57, green: 0.57, blue: 0.80, alpha: 0.9)
        l.verticalAlignmentMode = .center
        l.horizontalAlignmentMode = .center
        return l
    }

    // MARK: – Palette (Animal Crossing pastello)

    private let woodLight  = UIColor(red: 0.75, green: 0.56, blue: 0.36, alpha: 1)
    private let woodDark   = UIColor(red: 0.55, green: 0.38, blue: 0.23, alpha: 1)
    private let woodPanel  = UIColor(red: 0.87, green: 0.69, blue: 0.49, alpha: 1)
    private let cream      = UIColor(red: 0.97, green: 0.94, blue: 0.87, alpha: 1)
    private let blanketBlue     = UIColor(red: 0.70, green: 0.86, blue: 0.98, alpha: 1)
    private let blanketBlueDark = UIColor(red: 0.52, green: 0.70, blue: 0.90, alpha: 1)
    private let peach      = UIColor(red: 0.99, green: 0.90, blue: 0.86, alpha: 1)
    private let peachDark  = UIColor(red: 0.87, green: 0.74, blue: 0.70, alpha: 1)
}
