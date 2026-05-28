import SpriteKit

// MARK: - PetNode
//
// Supporta due forme distinte, lette da UserDefaults("petTypeRaw"):
//   • fiamma  — corpo a fiamma teardrop, wisp-arms, punta in cima
//   • uovo    — corpo a uovo ovale, crepa, braccia/piedi emergono con gli stage

final class PetNode: SKNode {

    // MARK: - Shape
    private var petShape: PetType = .fiamma

    // MARK: - Face nodes (shared)
    private let eyeL      = SKShapeNode(circleOfRadius: 5.5)
    private let eyeR      = SKShapeNode(circleOfRadius: 5.5)
    private let cheekL    = SKShapeNode(ellipseOf: CGSize(width: 16, height: 10))
    private let cheekR    = SKShapeNode(ellipseOf: CGSize(width: 16, height: 10))
    private let nose      = SKShapeNode()
    private let mouthL    = SKShapeNode()
    private let mouthR    = SKShapeNode()
    private let mouthNode = SKNode()
    private let accentLayer = SKNode()

    // MARK: - Fiamma nodes
    private let flameBody  = SKShapeNode()
    private let flameInner = SKShapeNode()
    private let leftWisp   = SKShapeNode()
    private let rightWisp  = SKShapeNode()

    // MARK: - Uovo nodes
    private let eggBody      = SKShapeNode()
    private let eggHighlight = SKShapeNode(ellipseOf: CGSize(width: 13, height: 20))
    private let eggCrack     = SKShapeNode()
    private let leftStub     = SKShapeNode(rectOf: CGSize(width: 10, height: 18), cornerRadius: 5)
    private let rightStub    = SKShapeNode(rectOf: CGSize(width: 10, height: 18), cornerRadius: 5)
    private let leftFoot     = SKShapeNode(ellipseOf: CGSize(width: 16, height: 10))
    private let rightFoot    = SKShapeNode(ellipseOf: CGSize(width: 16, height: 10))

    private var baseColor: PetColor = .cream
    private var currentStage = 0

    // MARK: - Colors
    private let darkInk    = UIColor(red: 0.18, green: 0.12, blue: 0.08, alpha: 1)
    private let blushPink  = UIColor(red: 0.94, green: 0.51, blue: 0.51, alpha: 0.45)
    private let noseBrown  = UIColor(red: 0.77, green: 0.53, blue: 0.42, alpha: 1)
    // Fiamma
    private let flameOrange = UIColor(red: 1.00, green: 0.55, blue: 0.26, alpha: 1)  // #ff8c42
    private let flameDark   = UIColor(red: 0.80, green: 0.24, blue: 0.00, alpha: 1)  // #cc3d00
    private let flameYellow = UIColor(red: 1.00, green: 0.91, blue: 0.48, alpha: 1)  // #ffe87a
    // Uovo
    private let eggCream   = UIColor(red: 0.99, green: 0.95, blue: 0.89, alpha: 1)   // #fdf3e3
    private let eggBorder  = UIColor(red: 0.79, green: 0.66, blue: 0.43, alpha: 1)   // #c9a96e
    private let footBrown  = UIColor(red: 0.55, green: 0.39, blue: 0.25, alpha: 1)   // #8b6340
    private let footBorder = UIColor(red: 0.42, green: 0.29, blue: 0.19, alpha: 1)   // #6b4a30

    // MARK: - Init

    override init() {
        super.init()
        let raw = UserDefaults.standard.string(forKey: "petTypeRaw") ?? ""
        petShape = PetType(rawValue: raw) ?? .fiamma
        buildPet()
        startIdle()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - Build

    private func buildPet() {
        switch petShape {
        case .fiamma: buildFiamma()
        case .uovo:   buildUovo()
        }
        buildFace()
        accentLayer.zPosition = 30
        addChild(accentLayer)
        syncColors(animated: false)
        updateStageFeatures(animated: false)
    }

    // MARK: - Fiamma body

    private func buildFiamma() {
        // Wisp arms (behind flame body)
        for (wisp, side) in [(leftWisp, CGFloat(-1)), (rightWisp, CGFloat(1))] {
            wisp.path        = wispPath(side: side)
            wisp.fillColor   = flameOrange
            wisp.strokeColor = .clear
            wisp.zPosition   = 3
        }
        leftWisp.position  = CGPoint(x: -22, y: 0)
        rightWisp.position = CGPoint(x:  22, y: 0)
        addChild(leftWisp)
        addChild(rightWisp)

        // Main body
        flameBody.path        = flameBodyPath()
        flameBody.fillColor   = flameOrange
        flameBody.strokeColor = flameDark
        flameBody.lineWidth   = 2.5
        flameBody.zPosition   = 5
        addChild(flameBody)

        // Inner yellow highlight
        flameInner.path        = flameInnerPath()
        flameInner.fillColor   = flameYellow.withAlphaComponent(0.55)
        flameInner.strokeColor = .clear
        flameInner.zPosition   = 6
        addChild(flameInner)
    }

    // MARK: - Uovo body

    private func buildUovo() {
        // Feet (appear at stage 2)
        for foot in [leftFoot, rightFoot] {
            foot.fillColor   = footBrown
            foot.strokeColor = footBorder
            foot.lineWidth   = 1.8
            foot.alpha       = 0
            foot.zPosition   = 2
        }
        leftFoot.position  = CGPoint(x: -13, y: -42)
        rightFoot.position = CGPoint(x:  13, y: -42)
        addChild(leftFoot)
        addChild(rightFoot)

        // Stub arms (appear at stage 1)
        for stub in [leftStub, rightStub] {
            stub.fillColor   = eggCream
            stub.strokeColor = eggBorder
            stub.lineWidth   = 1.5
            stub.alpha       = 0
            stub.zPosition   = 3
        }
        leftStub.position   = CGPoint(x: -28, y: -8)
        leftStub.zRotation  = 0.22
        rightStub.position  = CGPoint(x:  28, y: -8)
        rightStub.zRotation = -0.22
        addChild(leftStub)
        addChild(rightStub)

        // Egg body
        eggBody.path        = eggBodyPath()
        eggBody.fillColor   = eggCream
        eggBody.strokeColor = eggBorder
        eggBody.lineWidth   = 2.5
        eggBody.zPosition   = 5
        addChild(eggBody)

        // Highlight glare
        eggHighlight.fillColor   = UIColor.white.withAlphaComponent(0.38)
        eggHighlight.strokeColor = .clear
        eggHighlight.position    = CGPoint(x: -9, y: 16)
        eggHighlight.zPosition   = 6
        addChild(eggHighlight)

        // Crack
        eggCrack.path        = crackPath()
        eggCrack.strokeColor = UIColor(red: 0.55, green: 0.37, blue: 0.19, alpha: 0.70)
        eggCrack.lineWidth   = 2
        eggCrack.lineCap     = .round
        eggCrack.lineJoin    = .round
        eggCrack.fillColor   = .clear
        eggCrack.zPosition   = 7
        addChild(eggCrack)
    }

    // MARK: - Face (shared)

    private func buildFace() {
        let (eyeOffX, eyeY): (CGFloat, CGFloat)
        let (cheekOffX, cheekY): (CGFloat, CGFloat)
        let noseY, mouthY: CGFloat

        switch petShape {
        case .fiamma:
            eyeOffX = 12; eyeY = 6
            cheekOffX = 22; cheekY = -6
            noseY = 8; mouthY = -2
        case .uovo:
            eyeOffX = 12; eyeY = 10
            cheekOffX = 20; cheekY = 0
            noseY = 10; mouthY = 0
        }

        // Eyes
        for eye in [eyeL, eyeR] {
            eye.fillColor   = darkInk
            eye.strokeColor = .clear
            eye.zPosition   = 20
            addChild(eye)
            let shine = SKShapeNode(circleOfRadius: 2.2)
            shine.fillColor   = .white
            shine.strokeColor = .clear
            shine.position    = CGPoint(x: 1.8, y: 1.8)
            eye.addChild(shine)
        }
        eyeL.position = CGPoint(x: -eyeOffX, y: eyeY)
        eyeR.position = CGPoint(x:  eyeOffX, y: eyeY)

        // Cheeks
        for cheek in [cheekL, cheekR] {
            cheek.fillColor   = blushPink
            cheek.strokeColor = .clear
            cheek.zPosition   = 21
            addChild(cheek)
        }
        cheekL.position = CGPoint(x: -cheekOffX, y: cheekY)
        cheekR.position = CGPoint(x:  cheekOffX, y: cheekY)

        // Nose
        nose.path        = nosePath()
        nose.fillColor   = noseBrown
        nose.strokeColor = .clear
        nose.position    = CGPoint(x: 0, y: noseY)
        nose.zPosition   = 22
        addChild(nose)

        // Mouth
        for arc in [mouthL, mouthR] {
            arc.strokeColor = UIColor(red: 0.35, green: 0.20, blue: 0.12, alpha: 0.85)
            arc.lineWidth   = 2.8
            arc.lineCap     = .round
            arc.lineJoin    = .round
            arc.fillColor   = .clear
        }
        mouthNode.addChild(mouthL)
        mouthNode.addChild(mouthR)
        mouthNode.position  = CGPoint(x: 0, y: mouthY)
        mouthNode.zPosition = 22
        addChild(mouthNode)

        applyMouthStyle(for: .calm)
    }

    // MARK: - Paths

    private func flameBodyPath() -> CGPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 40))
        path.addCurve(to: CGPoint(x: 25, y: 0),
                      controlPoint1: CGPoint(x: 10, y: 28),
                      controlPoint2: CGPoint(x: 30, y: 14))
        path.addCurve(to: CGPoint(x: 0, y: -38),
                      controlPoint1: CGPoint(x: 25, y: -14),
                      controlPoint2: CGPoint(x: 14, y: -38))
        path.addCurve(to: CGPoint(x: -25, y: 0),
                      controlPoint1: CGPoint(x: -14, y: -38),
                      controlPoint2: CGPoint(x: -25, y: -14))
        path.addCurve(to: CGPoint(x: 0, y: 40),
                      controlPoint1: CGPoint(x: -30, y: 14),
                      controlPoint2: CGPoint(x: -10, y: 28))
        path.close()
        return path.cgPath
    }

    private func flameInnerPath() -> CGPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 28))
        path.addCurve(to: CGPoint(x: 15, y: 2),
                      controlPoint1: CGPoint(x: 6, y: 18),
                      controlPoint2: CGPoint(x: 17, y: 10))
        path.addCurve(to: CGPoint(x: 0, y: -20),
                      controlPoint1: CGPoint(x: 15, y: -8),
                      controlPoint2: CGPoint(x: 8, y: -20))
        path.addCurve(to: CGPoint(x: -15, y: 2),
                      controlPoint1: CGPoint(x: -8, y: -20),
                      controlPoint2: CGPoint(x: -15, y: -8))
        path.addCurve(to: CGPoint(x: 0, y: 28),
                      controlPoint1: CGPoint(x: -17, y: 10),
                      controlPoint2: CGPoint(x: -6, y: 18))
        path.close()
        return path.cgPath
    }

    private func wispPath(side: CGFloat) -> CGPath {
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addCurve(to: CGPoint(x: side * 12, y: 2),
                      controlPoint1: CGPoint(x: side * 4, y: -7),
                      controlPoint2: CGPoint(x: side * 10, y: -4))
        path.addCurve(to: CGPoint(x: side * 5, y: -10),
                      controlPoint1: CGPoint(x: side * 14, y: 9),
                      controlPoint2: CGPoint(x: side * 11, y: 1))
        path.close()
        return path.cgPath
    }

    private func eggBodyPath() -> CGPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 38))
        path.addCurve(to: CGPoint(x: 24, y: 2),
                      controlPoint1: CGPoint(x: 28, y: 34),
                      controlPoint2: CGPoint(x: 30, y: 18))
        path.addCurve(to: CGPoint(x: 0, y: -38),
                      controlPoint1: CGPoint(x: 26, y: -12),
                      controlPoint2: CGPoint(x: 16, y: -38))
        path.addCurve(to: CGPoint(x: -24, y: 2),
                      controlPoint1: CGPoint(x: -16, y: -38),
                      controlPoint2: CGPoint(x: -26, y: -12))
        path.addCurve(to: CGPoint(x: 0, y: 38),
                      controlPoint1: CGPoint(x: -30, y: 18),
                      controlPoint2: CGPoint(x: -28, y: 34))
        path.close()
        return path.cgPath
    }

    private func crackPath() -> CGPath {
        // Zigzag crack across the upper third of the egg
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -13, y: 22))
        path.addLine(to: CGPoint(x: -4,  y: 30))
        path.addLine(to: CGPoint(x:  4,  y: 25))
        path.addLine(to: CGPoint(x:  13, y: 32))
        return path
    }

    private func nosePath() -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x:  0, y:  4))
        path.addLine(to: CGPoint(x: -4.5, y: -2))
        path.addLine(to: CGPoint(x:  4.5, y: -2))
        path.closeSubpath()
        return path
    }

    // MARK: - Mouth

    private func applyMouthStyle(for mood: PetMood) {
        switch mood {
        case .sleepy:
            mouthL.path = mouthArc(side: -1, dy: 0)
            mouthR.path = mouthArc(side:  1, dy: 0)
        case .anxious, .sick:
            mouthL.path = sadArc(side: -1)
            mouthR.path = sadArc(side:  1)
        case .happy, .evolving:
            mouthL.path = mouthArc(side: -1, dy: -6)
            mouthR.path = mouthArc(side:  1, dy: -6)
        default:
            mouthL.path = mouthArc(side: -1, dy: -3)
            mouthR.path = mouthArc(side:  1, dy: -3)
        }
    }

    private func mouthArc(side: CGFloat, dy: CGFloat) -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: side * 1, y: 0))
        path.addQuadCurve(to: CGPoint(x: side * 7, y: dy),
                          control: CGPoint(x: side * 4, y: dy - 4))
        return path
    }

    private func sadArc(side: CGFloat) -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: side * 1, y: -3))
        path.addQuadCurve(to: CGPoint(x: side * 7, y: 0),
                          control: CGPoint(x: side * 4, y: 3))
        return path
    }

    // MARK: - Public API

    func setColor(_ petColor: PetColor, animated: Bool = true) {
        baseColor = petColor
        syncColors(animated: animated)
    }

    func setMood(_ mood: PetMood) {
        applyMouthStyle(for: mood)
        if mood == .evolving { runEvolvingEffect() }
    }

    func setStage(_ stage: Int) {
        currentStage = max(0, stage)
        updateScaleForStage()
        rebuildStageDecorations()
        updateStageFeatures()
    }

    func bounce() {
        let squish  = SKAction.scaleX(to: 1.25, y: 0.80, duration: 0.10)
        let stretch = SKAction.scaleX(to: 0.85, y: 1.12, duration: 0.10)
        let restore = SKAction.scale(to: 1.00, duration: 0.14)
        run(.sequence([squish, stretch, restore]))
    }

    // MARK: - Colors Sync

    private func syncColors(animated: Bool) {
        let apply: () -> Void = {
            switch self.petShape {
            case .fiamma:
                // Fiamma è sempre arancione; petColor tinge leggermente il glow interno
                self.flameInner.fillColor = self.flameYellow.withAlphaComponent(0.55)
            case .uovo:
                // Egg shell tinta con petColor
                var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
                self.baseColor.uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
                let tinted = UIColor(
                    red:   0.99 * 0.82 + r * 0.18,
                    green: 0.95 * 0.82 + g * 0.18,
                    blue:  0.89 * 0.82 + b * 0.18,
                    alpha: 1
                )
                self.eggBody.fillColor   = tinted
                self.leftStub.fillColor  = tinted
                self.rightStub.fillColor = tinted
            }
        }

        if animated {
            let up  = SKAction.scale(to: 1.10, duration: 0.11)
            let down = SKAction.scale(to: 1.00, duration: 0.11)
            let col = SKAction.customAction(withDuration: 0.11) { [weak self] _, _ in
                apply()
                self?.updateScaleForStage()
            }
            run(.sequence([up, SKAction.group([down, col])]))
        } else {
            apply()
        }
    }

    // MARK: - Stage

    private func updateScaleForStage() {
        let scale = 1.0 + CGFloat(min(currentStage, 4)) * 0.10
        setScale(scale)
    }

    private func updateStageFeatures(animated: Bool = true) {
        guard petShape == .uovo else { return }
        let showStubs = currentStage >= 1
        let showFeet  = currentStage >= 2
        if animated && parent != nil {
            leftStub.run(.fadeAlpha(to: showStubs ? 1.0 : 0.0, duration: 0.4))
            rightStub.run(.fadeAlpha(to: showStubs ? 1.0 : 0.0, duration: 0.4))
            leftFoot.run(.fadeAlpha(to: showFeet  ? 1.0 : 0.0, duration: 0.4))
            rightFoot.run(.fadeAlpha(to: showFeet  ? 1.0 : 0.0, duration: 0.4))
        } else {
            leftStub.alpha  = showStubs ? 1.0 : 0.0
            rightStub.alpha = showStubs ? 1.0 : 0.0
            leftFoot.alpha  = showFeet  ? 1.0 : 0.0
            rightFoot.alpha = showFeet  ? 1.0 : 0.0
        }
    }

    private func rebuildStageDecorations() {
        accentLayer.removeAllChildren()
        switch petShape {
        case .fiamma: buildFlammaDecorations()
        case .uovo:   buildUovoDecorations()
        }
    }

    private func buildFlammaDecorations() {
        if currentStage >= 1 {
            let spark = SKShapeNode(circleOfRadius: 5)
            spark.fillColor   = flameYellow
            spark.strokeColor = .clear
            spark.position    = CGPoint(x: -20, y: 44)
            accentLayer.addChild(spark)
        }
        if currentStage >= 2 {
            let spark2 = SKShapeNode(circleOfRadius: 5)
            spark2.fillColor   = flameYellow
            spark2.strokeColor = .clear
            spark2.position    = CGPoint(x: 20, y: 42)
            accentLayer.addChild(spark2)
        }
        if currentStage >= 3 {
            let halo = SKShapeNode(ellipseOf: CGSize(width: 80, height: 18))
            halo.strokeColor = flameOrange.withAlphaComponent(0.7)
            halo.lineWidth   = 2.5
            halo.fillColor   = .clear
            halo.position    = CGPoint(x: 0, y: 48)
            accentLayer.addChild(halo)
        }
        if currentStage >= 4 {
            let crown = SKLabelNode(text: "✦")
            crown.fontSize  = 18
            crown.fontColor = flameYellow
            crown.position  = CGPoint(x: 0, y: 62)
            accentLayer.addChild(crown)
        }
    }

    private func buildUovoDecorations() {
        if currentStage >= 1 {
            let leaf = SKShapeNode(ellipseOf: CGSize(width: 14, height: 8))
            leaf.fillColor   = UIColor(red: 0.45, green: 0.82, blue: 0.55, alpha: 0.95)
            leaf.strokeColor = .clear
            leaf.zRotation   = -.pi / 5
            leaf.position    = CGPoint(x: -14, y: 44)
            accentLayer.addChild(leaf)
        }
        if currentStage >= 2 {
            let blossom = SKLabelNode(text: "✿")
            blossom.fontSize  = 13
            blossom.fontColor = UIColor(red: 1.0, green: 0.62, blue: 0.8, alpha: 0.95)
            blossom.position  = CGPoint(x: 14, y: 42)
            accentLayer.addChild(blossom)
        }
        if currentStage >= 3 {
            let halo = SKShapeNode(ellipseOf: CGSize(width: 86, height: 20))
            halo.strokeColor = UIColor.white.withAlphaComponent(0.65)
            halo.lineWidth   = 2
            halo.fillColor   = .clear
            halo.position    = CGPoint(x: 0, y: 50)
            accentLayer.addChild(halo)
        }
        if currentStage >= 4 {
            let crown = SKLabelNode(text: "✦")
            crown.fontSize  = 18
            crown.fontColor = UIColor(red: 1.0, green: 0.92, blue: 0.45, alpha: 1)
            crown.position  = CGPoint(x: 0, y: 62)
            accentLayer.addChild(crown)
        }
    }

    // MARK: - Idle Animation

    private func startIdle() {
        let up   = SKAction.moveBy(x: 0, y: 5, duration: 1.4)
        let down = SKAction.moveBy(x: 0, y: -5, duration: 1.4)
        up.timingMode   = .easeInEaseOut
        down.timingMode = .easeInEaseOut

        let tiltR = SKAction.rotate(byAngle:  0.03, duration: 1.4)
        let tiltL = SKAction.rotate(byAngle: -0.03, duration: 1.4)
        tiltR.timingMode = .easeInEaseOut
        tiltL.timingMode = .easeInEaseOut

        run(.repeatForever(.sequence([up, down])))
        run(.repeatForever(.sequence([tiltR, tiltL])))
    }

    // MARK: - Evolution Effect

    private func runEvolvingEffect() {
        let body: SKShapeNode = petShape == .fiamma ? flameBody : eggBody
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.12, duration: 0.25),
            SKAction.scale(to: 1.00, duration: 0.25)
        ])
        let glow   = SKAction.customAction(withDuration: 0.5) { _, _ in body.glowWidth = 8 }
        let unglow = SKAction.customAction(withDuration: 0.5) { _, _ in body.glowWidth = 0 }
        run(.sequence([pulse, glow, unglow]))
    }
}
