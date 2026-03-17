import SpriteKit

// MARK: - PetNode
//
// Pet kawaii con corpo blob, occhi a puntino e guancette rosa.
// In modalità isometrica il nodo viene scalato da GardenScene (yScale = 0.75)
// per simulare la prospettiva dall'alto a 45°.

final class PetNode: SKNode {

    // MARK: - Nodi

    private let body   = SKShapeNode()
    private let eyeL   = SKShapeNode(circleOfRadius: 5)
    private let eyeR   = SKShapeNode(circleOfRadius: 5)
    private let cheekL = SKShapeNode(ellipseOf: CGSize(width: 18, height: 10))
    private let cheekR = SKShapeNode(ellipseOf: CGSize(width: 18, height: 10))
    private let mouth  = SKShapeNode()

    // MARK: - Init

    override init() {
        super.init()
        buildBody()
        buildFace()
        startIdle()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    // MARK: - Mood

    func setMood(_ mood: PetMood) {
        let targetColor: UIColor
        switch mood {
        case .calm:     targetColor = UIColor(red: 0.95, green: 0.80, blue: 0.95, alpha: 1) // lilla
        case .happy:    targetColor = UIColor(red: 1.00, green: 0.90, blue: 0.55, alpha: 1) // giallo
        case .anxious:  targetColor = UIColor(red: 1.00, green: 0.75, blue: 0.60, alpha: 1) // pesca
        case .sleepy:   targetColor = UIColor(red: 0.75, green: 0.88, blue: 1.00, alpha: 1) // azzurro
        case .sick:     targetColor = UIColor(red: 0.80, green: 0.95, blue: 0.80, alpha: 1) // verde pallido
        case .evolving: targetColor = UIColor(red: 1.00, green: 0.80, blue: 0.95, alpha: 1) // rosa
        }
        // Transizione colore fluida
        let fade = SKAction.customAction(withDuration: 0.35) { [weak self] _, _ in
            self?.body.fillColor = targetColor
        }
        body.run(fade)
        updateMouthForMood(mood)

        // Effetto speciale per .evolving: scintille intorno al pet
        if mood == .evolving { runEvolvingEffect() }
    }

    // MARK: - Interazione

    func bounce() {
        // Squish isometrico: più pronunciato sull'asse X (prospettiva)
        let squish  = SKAction.scaleX(to: 1.30, y: 0.75, duration: 0.10)
        let stretch = SKAction.scaleX(to: 0.80, y: 1.15, duration: 0.10)
        let restore = SKAction.scale(to: 1.00,            duration: 0.15)
        run(.sequence([squish, stretch, restore]))
    }

    // MARK: - Build

    private func buildBody() {
        // Blob leggermente ellittico per look kawaii
        let path = CGMutablePath()
        path.addEllipse(in: CGRect(x: -46, y: -40, width: 92, height: 82))
        body.path        = path
        body.fillColor   = UIColor(red: 0.95, green: 0.80, blue: 0.95, alpha: 1)
        body.strokeColor = UIColor(red: 0.85, green: 0.60, blue: 0.90, alpha: 0.6)
        body.lineWidth   = 2
        addChild(body)
    }

    private func buildFace() {
        // Occhi
        for eye in [eyeL, eyeR] {
            eye.fillColor   = UIColor(red: 0.20, green: 0.10, blue: 0.25, alpha: 1)
            eye.strokeColor = .clear
            addChild(eye)
        }
        eyeL.position = CGPoint(x: -15, y: 8)
        eyeR.position = CGPoint(x:  15, y: 8)

        // Riflesso occhi (punto bianco)
        for (eye, offset) in [(eyeL, CGPoint(x: 2, y: 2)), (eyeR, CGPoint(x: 2, y: 2))] {
            let shine = SKShapeNode(circleOfRadius: 2)
            shine.fillColor   = .white
            shine.strokeColor = .clear
            shine.position    = offset
            eye.addChild(shine)
        }

        // Guancette
        for cheek in [cheekL, cheekR] {
            cheek.fillColor   = UIColor(red: 1.0, green: 0.55, blue: 0.65, alpha: 0.45)
            cheek.strokeColor = .clear
            addChild(cheek)
        }
        cheekL.position = CGPoint(x: -24, y: -4)
        cheekR.position = CGPoint(x:  24, y: -4)

        // Bocca
        buildSmile()
        addChild(mouth)
    }

    private func buildSmile() {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -10, y: -12))
        path.addQuadCurve(to: CGPoint(x: 10, y: -12),
                          control: CGPoint(x: 0, y: -20))
        mouth.path        = path
        mouth.strokeColor = UIColor(red: 0.20, green: 0.10, blue: 0.25, alpha: 0.8)
        mouth.lineWidth   = 2.5
        mouth.lineCap     = .round
        mouth.fillColor   = .clear
        mouth.position    = CGPoint(x: 0, y: 2)
    }

    private func updateMouthForMood(_ mood: PetMood) {
        let path = CGMutablePath()
        switch mood {
        case .happy, .evolving:
            path.move(to: CGPoint(x: -13, y: -10))
            path.addQuadCurve(to: CGPoint(x: 13, y: -10),
                              control: CGPoint(x: 0, y: -22))
        case .anxious, .sick:
            path.move(to: CGPoint(x: -10, y: -16))
            path.addQuadCurve(to: CGPoint(x: 10, y: -16),
                              control: CGPoint(x: 0, y: -8))
        case .sleepy:
            path.move(to: CGPoint(x: -8, y: -13))
            path.addLine(to: CGPoint(x: 8, y: -13))
        default:
            path.move(to: CGPoint(x: -10, y: -12))
            path.addQuadCurve(to: CGPoint(x: 10, y: -12),
                              control: CGPoint(x: 0, y: -20))
        }
        mouth.path = path
    }

    // MARK: - Animazione idle
    //
    // L'animazione verticale è ridotta rispetto alla versione piatta:
    // in prospettiva isometrica un movimento di 5pt appare già evidente.

    private func startIdle() {
        let up   = SKAction.moveBy(x: 0, y: 5, duration: 1.6)
        let down = SKAction.moveBy(x: 0, y: -5, duration: 1.6)
        up.timingMode   = .easeInEaseOut
        down.timingMode = .easeInEaseOut
        // Leggera rotazione per effetto "respiro"
        let tiltR = SKAction.rotate(byAngle:  0.04, duration: 1.6)
        let tiltL = SKAction.rotate(byAngle: -0.04, duration: 1.6)
        tiltR.timingMode = .easeInEaseOut
        tiltL.timingMode = .easeInEaseOut

        run(.repeatForever(.sequence([up, down])))
        run(.repeatForever(.sequence([tiltR, tiltL])))
    }

    // MARK: - Effetto evolving

    private func runEvolvingEffect() {
        let scale  = SKAction.sequence([
            SKAction.scale(to: 1.12, duration: 0.25),
            SKAction.scale(to: 1.00, duration: 0.25)
        ])
        let glow = SKAction.customAction(withDuration: 0.5) { [weak self] _, _ in
            self?.body.glowWidth = 8
        }
        let unglow = SKAction.customAction(withDuration: 0.5) { [weak self] _, _ in
            self?.body.glowWidth = 0
        }
        run(.sequence([scale, glow, unglow]))
    }
}
