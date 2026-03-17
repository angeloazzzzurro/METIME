import SpriteKit

// MARK: - PetNode

/// Un pet kawaii con corpo blob, occhi a puntino e guancette rosa.
/// Il colore del corpo cambia in base al mood mantenendo toni pastello.
final class PetNode: SKNode {

    // MARK: - Nodi

    private let body      = SKShapeNode()
    private let eyeL      = SKShapeNode(circleOfRadius: 5)
    private let eyeR      = SKShapeNode(circleOfRadius: 5)
    private let cheekL    = SKShapeNode(ellipseOf: CGSize(width: 18, height: 10))
    private let cheekR    = SKShapeNode(ellipseOf: CGSize(width: 18, height: 10))
    private let mouth     = SKShapeNode()

    // MARK: - Init

    override init() {
        super.init()
        buildBody()
        buildFace()
        startIdle()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Mood

    func setMood(_ mood: PetMood) {
        let color: UIColor
        switch mood {
        case .calm:     color = UIColor(red: 0.95, green: 0.80, blue: 0.95, alpha: 1) // lilla pastello
        case .happy:    color = UIColor(red: 1.00, green: 0.90, blue: 0.55, alpha: 1) // giallo pastello
        case .anxious:  color = UIColor(red: 1.00, green: 0.75, blue: 0.60, alpha: 1) // pesca
        case .sleepy:   color = UIColor(red: 0.75, green: 0.88, blue: 1.00, alpha: 1) // azzurro pastello
        case .sick:     color = UIColor(red: 0.80, green: 0.95, blue: 0.80, alpha: 1) // verde pallido
        case .evolving: color = UIColor(red: 1.00, green: 0.80, blue: 0.95, alpha: 1) // rosa pastello
        }
        let action = SKAction.customAction(withDuration: 0.3) { [weak self] _, t in
            self?.body.fillColor = color
        }
        body.run(action)
        updateMouthForMood(mood)
    }

    // MARK: - Interazione

    func bounce() {
        let squish  = SKAction.scaleX(to: 1.25, y: 0.80, duration: 0.10)
        let stretch = SKAction.scaleX(to: 0.85, y: 1.20, duration: 0.10)
        let restore = SKAction.scale(to: 1.0, duration: 0.15)
        run(.sequence([squish, stretch, restore]))
    }

    // MARK: - Build

    private func buildBody() {
        // Blob arrotondato: cerchio con raggio 44
        let path = CGMutablePath()
        path.addArc(center: .zero, radius: 44, startAngle: 0, endAngle: .pi * 2, clockwise: false)
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
        eyeL.position = CGPoint(x: -14, y: 10)
        eyeR.position = CGPoint(x:  14, y: 10)

        // Guancette
        for cheek in [cheekL, cheekR] {
            cheek.fillColor   = UIColor(red: 1.0, green: 0.55, blue: 0.65, alpha: 0.45)
            cheek.strokeColor = .clear
            addChild(cheek)
        }
        cheekL.position = CGPoint(x: -22, y: -2)
        cheekR.position = CGPoint(x:  22, y: -2)

        // Bocca sorridente (default)
        buildSmile()
        addChild(mouth)
    }

    private func buildSmile() {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -10, y: -10))
        path.addQuadCurve(to: CGPoint(x: 10, y: -10),
                          control: CGPoint(x: 0, y: -18))
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
            // Sorriso più ampio
            path.move(to: CGPoint(x: -12, y: -8))
            path.addQuadCurve(to: CGPoint(x: 12, y: -8),
                              control: CGPoint(x: 0, y: -20))
        case .anxious, .sick:
            // Bocca triste
            path.move(to: CGPoint(x: -10, y: -14))
            path.addQuadCurve(to: CGPoint(x: 10, y: -14),
                              control: CGPoint(x: 0, y: -6))
        case .sleepy:
            // Linea piatta (assonnato)
            path.move(to: CGPoint(x: -8, y: -11))
            path.addLine(to: CGPoint(x: 8, y: -11))
        default:
            // Sorriso standard
            path.move(to: CGPoint(x: -10, y: -10))
            path.addQuadCurve(to: CGPoint(x: 10, y: -10),
                              control: CGPoint(x: 0, y: -18))
        }
        mouth.path = path
    }

    // MARK: - Animazione idle

    private func startIdle() {
        let up   = SKAction.moveBy(x: 0, y: 7, duration: 1.4)
        let down = SKAction.moveBy(x: 0, y: -7, duration: 1.4)
        up.timingMode   = .easeInEaseOut
        down.timingMode = .easeInEaseOut
        run(.repeatForever(.sequence([up, down])))
    }
}
