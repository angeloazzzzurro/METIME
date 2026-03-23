import SpriteKit

// MARK: - PetNode
//
// Pet kawaii con corpo blob, occhi a puntino e guancette rosa.
// In modalità isometrica il nodo viene scalato da GardenScene (yScale = 0.75)
// per simulare la prospettiva dall'alto a 45°.

final class PetNode: SKNode {

    // MARK: - Nodi

    private let silhouette = SKNode()
    private let leftEar = SKShapeNode()
    private let rightEar = SKShapeNode()
    private let leftEarInner = SKShapeNode()
    private let rightEarInner = SKShapeNode()
    private let neckShadow = SKShapeNode(ellipseOf: CGSize(width: 18, height: 10))
    private let neck = SKShapeNode(rectOf: CGSize(width: 20, height: 18), cornerRadius: 8)
    private let body   = SKShapeNode()
    private let leftArm = SKShapeNode(rectOf: CGSize(width: 18, height: 36), cornerRadius: 9)
    private let rightArm = SKShapeNode(rectOf: CGSize(width: 18, height: 36), cornerRadius: 9)
    private let leftHand = SKShapeNode(ellipseOf: CGSize(width: 20, height: 16))
    private let rightHand = SKShapeNode(ellipseOf: CGSize(width: 20, height: 16))
    private let leftLeg = SKShapeNode(rectOf: CGSize(width: 20, height: 28), cornerRadius: 10)
    private let rightLeg = SKShapeNode(rectOf: CGSize(width: 20, height: 28), cornerRadius: 10)
    private let leftFoot = SKShapeNode(ellipseOf: CGSize(width: 24, height: 14))
    private let rightFoot = SKShapeNode(ellipseOf: CGSize(width: 24, height: 14))
    private let eyeL   = SKShapeNode(circleOfRadius: 5)
    private let eyeR   = SKShapeNode(circleOfRadius: 5)
    private let cheekL = SKShapeNode(ellipseOf: CGSize(width: 18, height: 10))
    private let cheekR = SKShapeNode(ellipseOf: CGSize(width: 18, height: 10))
    private let muzzleShadow = SKShapeNode(ellipseOf: CGSize(width: 32, height: 20))
    private let muzzle = SKShapeNode(ellipseOf: CGSize(width: 36, height: 24))
    private let muzzleHighlight = SKShapeNode(ellipseOf: CGSize(width: 22, height: 10))
    private let mouth = SKNode()
    private let mouthLeft = SKShapeNode()
    private let mouthRight = SKShapeNode()
    private let nose   = SKShapeNode(circleOfRadius: 3.8)
    private let tail   = SKShapeNode(circleOfRadius: 10)
    private let accentLayer = SKNode()

    private var currentStage = 0

    // MARK: - Init

    override init() {
        super.init()
        buildBody()
        buildFace()
        startIdle()
    }

    required init?(coder: NSCoder) { return nil }

    // MARK: - Colore corrente

    /// Colore base del pet (impostato da GameStore, indipendente dal mood)
    private var baseColor: PetColor = .cream

    /// Imposta il colore base con animazione fluida.
    func setColor(_ petColor: PetColor, animated: Bool = true) {
        baseColor = petColor
        syncSurfaceColors(animated: animated)
    }

    // MARK: - Mood

    func setMood(_ mood: PetMood) {
        // Il mood non sovrascrive più il colore base — agisce solo sulla bocca
        // e sugli effetti speciali (evolving)
        updateMouthForMood(mood)
        if mood == .evolving { runEvolvingEffect() }
    }

    func setStage(_ stage: Int) {
        currentStage = max(0, stage)
        updateScaleForStage()
        rebuildStageDecorations()
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
        addChild(silhouette)
        silhouette.addChild(tail)
        silhouette.addChild(leftEar)
        silhouette.addChild(rightEar)
        silhouette.addChild(neckShadow)
        silhouette.addChild(neck)
        silhouette.addChild(leftArm)
        silhouette.addChild(rightArm)
        silhouette.addChild(body)
        silhouette.addChild(leftLeg)
        silhouette.addChild(rightLeg)
        silhouette.addChild(leftHand)
        silhouette.addChild(rightHand)
        silhouette.addChild(leftFoot)
        silhouette.addChild(rightFoot)
        addChild(accentLayer)

        leftEar.path = earPath(width: 28, height: 44, roundness: 12)
        leftEar.position = CGPoint(x: -25, y: 34)
        leftEar.zRotation = 0.04

        rightEar.path = earPath(width: 28, height: 44, roundness: 12)
        rightEar.position = CGPoint(x: 25, y: 34)
        rightEar.zRotation = -0.04

        leftEarInner.path = earPath(width: 12, height: 26, roundness: 6)
        leftEarInner.position = CGPoint(x: 0, y: 3)
        leftEarInner.fillColor = UIColor(red: 1.0, green: 0.80, blue: 0.84, alpha: 0.85)
        leftEarInner.strokeColor = .clear
        leftEar.addChild(leftEarInner)

        rightEarInner.path = earPath(width: 12, height: 26, roundness: 6)
        rightEarInner.position = CGPoint(x: 0, y: 3)
        rightEarInner.fillColor = UIColor(red: 1.0, green: 0.80, blue: 0.84, alpha: 0.85)
        rightEarInner.strokeColor = .clear
        rightEar.addChild(rightEarInner)

        body.path = bodyPath()
        body.fillColor   = UIColor(red: 0.98, green: 0.95, blue: 0.93, alpha: 1)
        body.strokeColor = UIColor(red: 0.90, green: 0.75, blue: 0.80, alpha: 0.5)
        body.lineWidth   = 2

        neckShadow.fillColor = UIColor(red: 0.79, green: 0.67, blue: 0.73, alpha: 0.16)
        neckShadow.strokeColor = .clear
        neckShadow.position = CGPoint(x: 0, y: 17)
        neckShadow.zPosition = 0.5

        neck.fillColor = UIColor(red: 0.98, green: 0.95, blue: 0.93, alpha: 1)
        neck.strokeColor = UIColor(red: 0.90, green: 0.75, blue: 0.80, alpha: 0.72)
        neck.lineWidth = 1.6
        neck.position = CGPoint(x: 0, y: 20)
        neck.zPosition = 1

        for limb in [leftArm, rightArm, leftHand, rightHand, leftLeg, rightLeg, leftFoot, rightFoot] {
            limb.fillColor = UIColor(red: 0.98, green: 0.95, blue: 0.93, alpha: 1)
            limb.strokeColor = UIColor(red: 0.78, green: 0.60, blue: 0.68, alpha: 0.82)
            limb.lineWidth = 1.8
        }
        leftArm.position = CGPoint(x: -34, y: 0)
        leftArm.zRotation = 0.28
        leftArm.zPosition = 0
        rightArm.position = CGPoint(x: 34, y: 0)
        rightArm.zRotation = -0.28
        rightArm.zPosition = 0

        leftHand.position = CGPoint(x: -42, y: -14)
        leftHand.zPosition = 4
        rightHand.position = CGPoint(x: 42, y: -14)
        rightHand.zPosition = 4

        leftLeg.position = CGPoint(x: -16, y: -36)
        leftLeg.zPosition = 1
        rightLeg.position = CGPoint(x: 16, y: -36)
        rightLeg.zPosition = 1

        leftFoot.position = CGPoint(x: -16, y: -48)
        leftFoot.zPosition = 5
        rightFoot.position = CGPoint(x: 16, y: -48)
        rightFoot.zPosition = 5

        tail.fillColor = UIColor.white.withAlphaComponent(0.92)
        tail.strokeColor = UIColor(red: 0.90, green: 0.75, blue: 0.80, alpha: 0.25)
        tail.lineWidth = 1
        tail.position = CGPoint(x: 33, y: -5)
        tail.zPosition = -1

        syncSurfaceColors(animated: false)
    }

    private func buildFace() {
        // Occhi
        for eye in [eyeL, eyeR] {
            eye.fillColor   = UIColor(red: 0.20, green: 0.10, blue: 0.25, alpha: 1)
            eye.strokeColor = .clear
            addChild(eye)
        }
        eyeL.position = CGPoint(x: -15, y: 10)
        eyeR.position = CGPoint(x:  15, y: 10)

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
        cheekL.position = CGPoint(x: -24, y: -1)
        cheekR.position = CGPoint(x:  24, y: -1)

        muzzleShadow.fillColor = UIColor(red: 0.83, green: 0.70, blue: 0.74, alpha: 0.18)
        muzzleShadow.strokeColor = .clear
        muzzleShadow.position = CGPoint(x: 2, y: -7)
        addChild(muzzleShadow)

        muzzle.fillColor = UIColor(red: 1.0, green: 0.97, blue: 0.95, alpha: 0.96)
        muzzle.strokeColor = UIColor(red: 0.90, green: 0.82, blue: 0.84, alpha: 0.72)
        muzzle.lineWidth = 1.2
        muzzle.position = CGPoint(x: 1, y: -5)
        addChild(muzzle)

        muzzleHighlight.fillColor = UIColor.white.withAlphaComponent(0.42)
        muzzleHighlight.strokeColor = .clear
        muzzleHighlight.position = CGPoint(x: 0, y: 4)
        muzzle.addChild(muzzleHighlight)

        nose.fillColor = UIColor(red: 0.54, green: 0.34, blue: 0.42, alpha: 0.85)
        nose.strokeColor = .clear
        nose.position = CGPoint(x: 0, y: -1)
        addChild(nose)

        // Bocca
        buildSmile()
        addChild(mouth)
    }

    private func buildSmile() {
        mouth.position    = CGPoint(x: 2, y: -3)
        mouthLeft.strokeColor = UIColor(red: 0.20, green: 0.10, blue: 0.25, alpha: 0.86)
        mouthLeft.lineWidth = 2.8
        mouthLeft.lineCap = .round
        mouthLeft.lineJoin = .round
        mouthLeft.fillColor = .clear
        mouthLeft.position = .zero

        mouthRight.strokeColor = UIColor(red: 0.20, green: 0.10, blue: 0.25, alpha: 0.86)
        mouthRight.lineWidth = 2.8
        mouthRight.lineCap = .round
        mouthRight.lineJoin = .round
        mouthRight.fillColor = .clear
        mouthRight.position = .zero

        mouth.addChild(mouthLeft)
        mouth.addChild(mouthRight)
        applyMouthStyle(for: .calm)
    }

    private func updateMouthForMood(_ mood: PetMood) {
        applyMouthStyle(for: mood)
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

    private func updateScaleForStage() {
        let stageScale = 1.0 + CGFloat(min(currentStage, 4)) * 0.12
        silhouette.setScale(stageScale)
        accentLayer.setScale(stageScale)
        tail.setScale(0.96 + CGFloat(min(currentStage, 4)) * 0.04)

        let earStretch = 1.0 + CGFloat(min(currentStage, 4)) * 0.04
        leftEar.yScale = earStretch
        rightEar.yScale = earStretch
    }

    private func rebuildStageDecorations() {
        accentLayer.removeAllChildren()

        if currentStage >= 1 {
            let leaf = SKShapeNode(ellipseOf: CGSize(width: 16, height: 9))
            leaf.fillColor = UIColor(red: 0.45, green: 0.82, blue: 0.55, alpha: 0.95)
            leaf.strokeColor = .clear
            leaf.zRotation = -.pi / 5
            leaf.position = CGPoint(x: -12, y: 57)
            accentLayer.addChild(leaf)
        }

        if currentStage >= 2 {
            let blossom = SKLabelNode(text: "✿")
            blossom.fontSize = 15
            blossom.fontColor = UIColor(red: 1.0, green: 0.62, blue: 0.8, alpha: 0.95)
            blossom.position = CGPoint(x: 16, y: 55)
            accentLayer.addChild(blossom)
        }

        if currentStage >= 3 {
            let halo = SKShapeNode(ellipseOf: CGSize(width: 106, height: 28))
            halo.strokeColor = UIColor.white.withAlphaComponent(0.65)
            halo.lineWidth = 2
            halo.fillColor = .clear
            halo.position = CGPoint(x: 0, y: 72)
            accentLayer.addChild(halo)
        }

        if currentStage >= 4 {
            let crown = SKLabelNode(text: "✦")
            crown.fontSize = 20
            crown.fontColor = UIColor(red: 1.0, green: 0.92, blue: 0.45, alpha: 1)
            crown.position = CGPoint(x: 0, y: 88)
            accentLayer.addChild(crown)
        }
    }

    private func syncSurfaceColors(animated: Bool) {
        let newColor = baseColor.uiColor
        let newStroke = baseColor.strokeUIColor
        let applyColors = {
            self.body.fillColor = newColor
            self.body.strokeColor = newStroke
            self.neck.fillColor = newColor
            self.neck.strokeColor = newStroke.withAlphaComponent(0.82)
            self.leftEar.fillColor = newColor
            self.rightEar.fillColor = newColor
            self.leftEar.strokeColor = newStroke
            self.rightEar.strokeColor = newStroke
            self.leftArm.fillColor = newColor
            self.rightArm.fillColor = newColor
            self.leftHand.fillColor = newColor
            self.rightHand.fillColor = newColor
            self.leftLeg.fillColor = newColor
            self.rightLeg.fillColor = newColor
            self.leftFoot.fillColor = newColor
            self.rightFoot.fillColor = newColor
            self.leftArm.strokeColor = newStroke.withAlphaComponent(0.8)
            self.rightArm.strokeColor = newStroke.withAlphaComponent(0.8)
            self.leftHand.strokeColor = newStroke.withAlphaComponent(0.8)
            self.rightHand.strokeColor = newStroke.withAlphaComponent(0.8)
            self.leftLeg.strokeColor = newStroke.withAlphaComponent(0.8)
            self.rightLeg.strokeColor = newStroke.withAlphaComponent(0.8)
            self.leftFoot.strokeColor = newStroke.withAlphaComponent(0.8)
            self.rightFoot.strokeColor = newStroke.withAlphaComponent(0.8)
            self.tail.fillColor = newColor.withAlphaComponent(0.95)
            self.tail.strokeColor = newStroke.withAlphaComponent(0.6)
            self.muzzle.strokeColor = newStroke.withAlphaComponent(0.5)
        }

        if animated {
            let scaleUp = SKAction.scale(to: 1.12, duration: 0.12)
            let scaleDown = SKAction.scale(to: 1.0, duration: 0.12)
            let colorAct = SKAction.customAction(withDuration: 0.12) { [weak self] _, _ in
                applyColors()
                self?.updateScaleForStage()
            }
            run(.sequence([scaleUp, SKAction.group([scaleDown, colorAct])]))
        } else {
            applyColors()
        }
    }

    private func bodyPath() -> CGPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: -30, y: -26))
        path.addQuadCurve(to: CGPoint(x: -24, y: 22), controlPoint: CGPoint(x: -38, y: -2))
        path.addQuadCurve(to: CGPoint(x: 0, y: 40), controlPoint: CGPoint(x: -18, y: 38))
        path.addQuadCurve(to: CGPoint(x: 24, y: 22), controlPoint: CGPoint(x: 18, y: 38))
        path.addQuadCurve(to: CGPoint(x: 30, y: -26), controlPoint: CGPoint(x: 38, y: -2))
        path.addQuadCurve(to: CGPoint(x: 0, y: -40), controlPoint: CGPoint(x: 22, y: -42))
        path.addQuadCurve(to: CGPoint(x: -30, y: -26), controlPoint: CGPoint(x: -22, y: -42))
        path.close()
        return path.cgPath
    }

    private func earPath(width: CGFloat, height: CGFloat, roundness: CGFloat) -> CGPath {
        let path = UIBezierPath(roundedRect: CGRect(x: -width / 2, y: -height / 2, width: width, height: height), cornerRadius: roundness)
        return path.cgPath
    }

    private func applyMouthStyle(for mood: PetMood) {
        switch mood {
        case .sleepy:
            mouthLeft.path = singleLobePath(start: CGPoint(x: -6, y: -7), end: CGPoint(x: -1, y: -7), control: CGPoint(x: -3.5, y: -7))
            mouthRight.path = singleLobePath(start: CGPoint(x: 1, y: -7), end: CGPoint(x: 6, y: -7), control: CGPoint(x: 3.5, y: -7))
        case .anxious, .sick:
            mouthLeft.path = singleLobePath(start: CGPoint(x: -6, y: -6), end: CGPoint(x: -1, y: -9), control: CGPoint(x: -3, y: -11))
            mouthRight.path = singleLobePath(start: CGPoint(x: 1, y: -9), end: CGPoint(x: 6, y: -6), control: CGPoint(x: 3, y: -11))
        case .happy, .evolving:
            mouthLeft.path = singleLobePath(start: CGPoint(x: -6, y: -7), end: CGPoint(x: -1, y: -2), control: CGPoint(x: -3, y: 1))
            mouthRight.path = singleLobePath(start: CGPoint(x: 1, y: -2), end: CGPoint(x: 6, y: -7), control: CGPoint(x: 3, y: 1))
        default:
            mouthLeft.path = singleLobePath(start: CGPoint(x: -6, y: -6), end: CGPoint(x: -1, y: -3), control: CGPoint(x: -3, y: 0))
            mouthRight.path = singleLobePath(start: CGPoint(x: 1, y: -3), end: CGPoint(x: 6, y: -6), control: CGPoint(x: 3, y: 0))
        }
    }

    private func singleLobePath(start: CGPoint, end: CGPoint, control: CGPoint) -> CGPath {
        let path = CGMutablePath()
        path.move(to: start)
        path.addQuadCurve(to: end, control: control)
        return path
    }
}
