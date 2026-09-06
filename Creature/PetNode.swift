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
    private let browL = SKShapeNode()
    private let browR = SKShapeNode()
    private let cheekL = SKShapeNode(ellipseOf: CGSize(width: 18, height: 10))
    private let cheekR = SKShapeNode(ellipseOf: CGSize(width: 18, height: 10))
    private let muzzleShadow = SKShapeNode(ellipseOf: CGSize(width: 32, height: 20))
    private let muzzle = SKShapeNode(ellipseOf: CGSize(width: 36, height: 24))
    private let muzzleHighlight = SKShapeNode(ellipseOf: CGSize(width: 22, height: 10))
    private let bellyPatch = SKShapeNode(ellipseOf: CGSize(width: 38, height: 28))
    private let foreheadPatch = SKShapeNode(ellipseOf: CGSize(width: 26, height: 14))
    private let mouth = SKNode()
    private let mouthLeft = SKShapeNode()
    private let mouthRight = SKShapeNode()
    private let nose   = SKShapeNode(circleOfRadius: 3.8)
    private let tail   = SKShapeNode(circleOfRadius: 10)
    private let accentLayer = SKNode()

    private var currentStage = 0
    private var currentMood: PetMood = .calm

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
        currentMood = mood
        // Il mood non sovrascrive più il colore base — agisce solo sulla bocca
        // e sugli effetti speciali (evolving)
        updateMouthForMood(mood)
        startIdle()
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
        body.glowWidth = 1.2

        bellyPatch.fillColor = UIColor.white.withAlphaComponent(0.20)
        bellyPatch.strokeColor = UIColor.white.withAlphaComponent(0.10)
        bellyPatch.lineWidth = 1
        bellyPatch.position = CGPoint(x: 0, y: -6)
        bellyPatch.zPosition = 2
        silhouette.addChild(bellyPatch)

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
        tail.position = CGPoint(x: 35, y: -3)
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

        for brow in [browL, browR] {
            brow.strokeColor = UIColor(red: 0.42, green: 0.28, blue: 0.36, alpha: 0.42)
            brow.lineWidth = 2
            brow.lineCap = .round
            brow.lineJoin = .round
            brow.fillColor = .clear
            addChild(brow)
        }
        browL.path = singleLobePath(start: CGPoint(x: -19, y: 19), end: CGPoint(x: -10, y: 18), control: CGPoint(x: -14, y: 21))
        browR.path = singleLobePath(start: CGPoint(x: 10, y: 18), end: CGPoint(x: 19, y: 19), control: CGPoint(x: 14, y: 21))

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

        foreheadPatch.fillColor = UIColor.white.withAlphaComponent(0.18)
        foreheadPatch.strokeColor = .clear
        foreheadPatch.position = CGPoint(x: 0, y: 22)
        foreheadPatch.zRotation = -.pi / 18
        addChild(foreheadPatch)

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
        removeAction(forKey: "petBob")
        removeAction(forKey: "petTilt")
        tail.removeAction(forKey: "tailSway")
        leftEar.removeAction(forKey: "earWiggle")
        rightEar.removeAction(forKey: "earWiggle")
        eyeL.removeAction(forKey: "blink")
        eyeR.removeAction(forKey: "blink")

        let bobDistance: CGFloat
        let bobDuration: TimeInterval
        let tiltAmount: CGFloat
        let tailAngle: CGFloat

        switch currentMood {
        case .sleepy:
            bobDistance = 3
            bobDuration = 2.3
            tiltAmount = 0.02
            tailAngle = 0.04
        case .anxious:
            bobDistance = 4
            bobDuration = 1.0
            tiltAmount = 0.06
            tailAngle = 0.12
        case .happy:
            bobDistance = 6
            bobDuration = 1.2
            tiltAmount = 0.05
            tailAngle = 0.16
        case .evolving:
            bobDistance = 7
            bobDuration = 1.05
            tiltAmount = 0.07
            tailAngle = 0.18
        case .sick:
            bobDistance = 2
            bobDuration = 2.0
            tiltAmount = 0.018
            tailAngle = 0.03
        case .calm:
            bobDistance = 5
            bobDuration = 1.6
            tiltAmount = 0.04
            tailAngle = 0.10
        }

        let up = SKAction.moveBy(x: 0, y: bobDistance, duration: bobDuration)
        let down = SKAction.moveBy(x: 0, y: -bobDistance, duration: bobDuration)
        up.timingMode = .easeInEaseOut
        down.timingMode = .easeInEaseOut
        run(.repeatForever(.sequence([up, down])), withKey: "petBob")

        let tiltR = SKAction.rotate(toAngle: tiltAmount, duration: bobDuration, shortestUnitArc: true)
        let tiltL = SKAction.rotate(toAngle: -tiltAmount, duration: bobDuration, shortestUnitArc: true)
        tiltR.timingMode = .easeInEaseOut
        tiltL.timingMode = .easeInEaseOut
        run(.repeatForever(.sequence([tiltR, tiltL])), withKey: "petTilt")

        let tailRight = SKAction.rotate(toAngle: tailAngle, duration: bobDuration * 0.7, shortestUnitArc: true)
        let tailLeft = SKAction.rotate(toAngle: -tailAngle * 0.6, duration: bobDuration * 0.7, shortestUnitArc: true)
        tailRight.timingMode = .easeInEaseOut
        tailLeft.timingMode = .easeInEaseOut
        tail.run(.repeatForever(.sequence([tailRight, tailLeft])), withKey: "tailSway")

        if currentMood == .anxious || currentMood == .happy || currentMood == .evolving {
            let wiggleOut = SKAction.rotate(byAngle: currentMood == .anxious ? -0.08 : 0.06, duration: 0.55)
            let wiggleBack = SKAction.rotate(byAngle: currentMood == .anxious ? 0.08 : -0.06, duration: 0.55)
            wiggleOut.timingMode = .easeInEaseOut
            wiggleBack.timingMode = .easeInEaseOut
            leftEar.run(.repeatForever(.sequence([wiggleOut, wiggleBack])), withKey: "earWiggle")
            rightEar.run(.repeatForever(.sequence([wiggleBack, wiggleOut])), withKey: "earWiggle")
        }

        startBlinkLoop()
    }

    private func startBlinkLoop() {
        let pause = SKAction.wait(forDuration: currentMood == .sleepy ? 3.2 : (currentMood == .anxious ? 1.8 : 2.4))
        let close = SKAction.scaleY(to: 0.12, duration: 0.08)
        let open = SKAction.scaleY(to: 1.0, duration: 0.12)
        close.timingMode = .easeInEaseOut
        open.timingMode = .easeInEaseOut

        let blinkSequence: SKAction
        if currentMood == .anxious || currentMood == .happy {
            blinkSequence = .sequence([pause, close, open, .wait(forDuration: 0.08), close, open])
        } else {
            blinkSequence = .sequence([pause, close, open])
        }

        eyeL.run(.repeatForever(blinkSequence), withKey: "blink")
        eyeR.run(.repeatForever(blinkSequence), withKey: "blink")
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
        let stage = min(max(currentStage, 0), 4)

        silhouette.setScale(1.0)
        accentLayer.setScale(1.0)
        tail.setScale(1.0)
        bellyPatch.setScale(1.0)
        foreheadPatch.setScale(1.0)
        leftEar.setScale(1.0)
        rightEar.setScale(1.0)
        leftEar.position = CGPoint(x: -25, y: 34)
        rightEar.position = CGPoint(x: 25, y: 34)
        leftArm.setScale(1.0)
        rightArm.setScale(1.0)
        leftLeg.setScale(1.0)
        rightLeg.setScale(1.0)
        leftHand.setScale(1.0)
        rightHand.setScale(1.0)
        leftFoot.setScale(1.0)
        rightFoot.setScale(1.0)
        tail.position = CGPoint(x: 35, y: -3)
        muzzle.setScale(1.0)
        muzzle.position = CGPoint(x: 1, y: -5)
        cheekL.setScale(1.0)
        cheekR.setScale(1.0)
        body.glowWidth = 1.2

        switch stage {
        case 0:
            silhouette.setScale(0.92)
            leftEar.yScale = 0.92
            rightEar.yScale = 0.92
            tail.setScale(0.88)
            bellyPatch.setScale(0.88)
            foreheadPatch.setScale(0.85)
        case 1:
            silhouette.setScale(1.0)
            leftEar.yScale = 1.02
            rightEar.yScale = 1.02
            tail.setScale(0.96)
            bellyPatch.setScale(0.95)
        case 2:
            silhouette.setScale(1.08)
            leftEar.yScale = 1.08
            rightEar.yScale = 1.08
            leftEar.position = CGPoint(x: -26, y: 36)
            rightEar.position = CGPoint(x: 26, y: 36)
            tail.setScale(1.02)
            muzzle.setScale(1.04)
            cheekL.setScale(1.08)
            cheekR.setScale(1.08)
        case 3:
            silhouette.setScale(1.16)
            accentLayer.setScale(1.06)
            leftEar.yScale = 1.12
            rightEar.yScale = 1.12
            leftEar.xScale = 1.04
            rightEar.xScale = 1.04
            tail.setScale(1.08)
            tail.position = CGPoint(x: 38, y: -1)
            bellyPatch.setScale(1.08)
            foreheadPatch.setScale(1.06)
            muzzle.setScale(1.06)
            body.glowWidth = 2.4
        default:
            silhouette.setScale(1.24)
            accentLayer.setScale(1.12)
            leftEar.yScale = 1.16
            rightEar.yScale = 1.16
            leftEar.xScale = 1.06
            rightEar.xScale = 1.06
            leftEar.position = CGPoint(x: -27, y: 38)
            rightEar.position = CGPoint(x: 27, y: 38)
            tail.setScale(1.14)
            tail.position = CGPoint(x: 40, y: 0)
            bellyPatch.setScale(1.12)
            foreheadPatch.setScale(1.10)
            muzzle.setScale(1.10)
            cheekL.setScale(1.12)
            cheekR.setScale(1.12)
            body.glowWidth = 3.6
        }
    }

    private func rebuildStageDecorations() {
        accentLayer.removeAllChildren()

        switch min(max(currentStage, 0), 4) {
        case 0:
            break
        case 1:
            accentLayer.addChild(makeLeafAccent(size: CGSize(width: 16, height: 9), color: UIColor(red: 0.45, green: 0.82, blue: 0.55, alpha: 0.95), position: CGPoint(x: -12, y: 57), rotation: -.pi / 5))
            accentLayer.addChild(makeLeafAccent(size: CGSize(width: 12, height: 7), color: UIColor(red: 0.62, green: 0.90, blue: 0.58, alpha: 0.92), position: CGPoint(x: -4, y: 60), rotation: .pi / 6))
        case 2:
            accentLayer.addChild(makeLeafAccent(size: CGSize(width: 18, height: 10), color: UIColor(red: 0.42, green: 0.80, blue: 0.52, alpha: 0.96), position: CGPoint(x: -14, y: 61), rotation: -.pi / 4))

            let blossom = SKLabelNode(text: "✿")
            blossom.fontSize = 18
            blossom.fontColor = UIColor(red: 1.0, green: 0.62, blue: 0.8, alpha: 0.95)
            blossom.position = CGPoint(x: 14, y: 60)
            accentLayer.addChild(blossom)

            let bud = SKShapeNode(circleOfRadius: 5)
            bud.fillColor = UIColor(red: 1.0, green: 0.82, blue: 0.90, alpha: 0.96)
            bud.strokeColor = .clear
            bud.position = CGPoint(x: 2, y: 64)
            accentLayer.addChild(bud)
            accentLayer.addChild(makeLeafAccent(size: CGSize(width: 10, height: 18), color: UIColor(red: 0.64, green: 0.90, blue: 0.52, alpha: 0.88), position: CGPoint(x: 24, y: 34), rotation: .pi / 6))
            accentLayer.addChild(makeLeafAccent(size: CGSize(width: 10, height: 18), color: UIColor(red: 0.64, green: 0.90, blue: 0.52, alpha: 0.88), position: CGPoint(x: -24, y: 34), rotation: -.pi / 6))
        case 3:
            let wreath = SKShapeNode(ellipseOf: CGSize(width: 76, height: 26))
            wreath.strokeColor = UIColor(red: 0.60, green: 0.86, blue: 0.48, alpha: 0.92)
            wreath.lineWidth = 3
            wreath.fillColor = .clear
            wreath.position = CGPoint(x: 0, y: 67)
            accentLayer.addChild(wreath)

            for position in [CGPoint(x: -22, y: 67), CGPoint(x: 0, y: 70), CGPoint(x: 22, y: 67)] {
                let blossom = SKLabelNode(text: "❀")
                blossom.fontSize = position.x == 0 ? 18 : 15
                blossom.fontColor = UIColor(red: 1.0, green: 0.72, blue: 0.82, alpha: 0.98)
                blossom.position = position
                accentLayer.addChild(blossom)
            }

            for (position, rotation) in [(CGPoint(x: -34, y: 60), -CGFloat.pi / 4), (CGPoint(x: 34, y: 60), CGFloat.pi / 4)] {
                accentLayer.addChild(makeLeafAccent(size: CGSize(width: 16, height: 8), color: UIColor(red: 0.72, green: 0.94, blue: 0.62, alpha: 0.92), position: position, rotation: rotation))
            }

            let halo = SKShapeNode(ellipseOf: CGSize(width: 106, height: 28))
            halo.strokeColor = UIColor.white.withAlphaComponent(0.65)
            halo.lineWidth = 2
            halo.fillColor = .clear
            halo.position = CGPoint(x: 0, y: 82)
            accentLayer.addChild(halo)
            accentLayer.addChild(makeSparkleAccent(text: "✦", size: 14, color: UIColor(red: 1.0, green: 0.93, blue: 0.62, alpha: 0.96), position: CGPoint(x: -34, y: 85)))
            accentLayer.addChild(makeSparkleAccent(text: "✦", size: 14, color: UIColor(red: 1.0, green: 0.93, blue: 0.62, alpha: 0.96), position: CGPoint(x: 34, y: 85)))
        default:
            let halo = SKShapeNode(ellipseOf: CGSize(width: 118, height: 30))
            halo.strokeColor = UIColor.white.withAlphaComponent(0.72)
            halo.lineWidth = 2.4
            halo.fillColor = .clear
            halo.position = CGPoint(x: 0, y: 82)
            accentLayer.addChild(halo)

            let innerHalo = SKShapeNode(ellipseOf: CGSize(width: 90, height: 20))
            innerHalo.strokeColor = UIColor(red: 1.0, green: 0.92, blue: 0.54, alpha: 0.8)
            innerHalo.lineWidth = 1.6
            innerHalo.fillColor = .clear
            innerHalo.position = CGPoint(x: 0, y: 82)
            accentLayer.addChild(innerHalo)

            let crown = SKLabelNode(text: "✦")
            crown.fontSize = 24
            crown.fontColor = UIColor(red: 1.0, green: 0.92, blue: 0.45, alpha: 1)
            crown.position = CGPoint(x: 0, y: 98)
            accentLayer.addChild(crown)

            accentLayer.addChild(makeSparkleAccent(text: "✦", size: 14, color: UIColor(red: 1.0, green: 0.95, blue: 0.70, alpha: 0.95), position: CGPoint(x: -26, y: 90)))
            accentLayer.addChild(makeSparkleAccent(text: "✦", size: 14, color: UIColor(red: 1.0, green: 0.95, blue: 0.70, alpha: 0.95), position: CGPoint(x: 26, y: 90)))
            accentLayer.addChild(makeSparkleAccent(text: "✧", size: 12, color: UIColor.white.withAlphaComponent(0.92), position: CGPoint(x: -42, y: 80)))
            accentLayer.addChild(makeSparkleAccent(text: "✧", size: 12, color: UIColor.white.withAlphaComponent(0.92), position: CGPoint(x: 42, y: 80)))

            let sideOrbLeft = makeOrbAccent(color: UIColor(red: 0.80, green: 0.95, blue: 1.0, alpha: 0.86), position: CGPoint(x: -36, y: 64))
            let sideOrbRight = makeOrbAccent(color: UIColor(red: 1.0, green: 0.80, blue: 0.92, alpha: 0.86), position: CGPoint(x: 36, y: 64))
            accentLayer.addChild(sideOrbLeft)
            accentLayer.addChild(sideOrbRight)

            let sash = SKShapeNode(rectOf: CGSize(width: 56, height: 8), cornerRadius: 4)
            sash.fillColor = UIColor(red: 1.0, green: 0.96, blue: 0.78, alpha: 0.78)
            sash.strokeColor = UIColor.white.withAlphaComponent(0.28)
            sash.lineWidth = 1
            sash.position = CGPoint(x: 0, y: 54)
            accentLayer.addChild(sash)
        }
    }

    private func makeLeafAccent(size: CGSize, color: UIColor, position: CGPoint, rotation: CGFloat) -> SKShapeNode {
        let leaf = SKShapeNode(ellipseOf: size)
        leaf.fillColor = color
        leaf.strokeColor = .clear
        leaf.position = position
        leaf.zRotation = rotation
        return leaf
    }

    private func makeSparkleAccent(text: String, size: CGFloat, color: UIColor, position: CGPoint) -> SKLabelNode {
        let sparkle = SKLabelNode(text: text)
        sparkle.fontSize = size
        sparkle.fontColor = color
        sparkle.position = position
        return sparkle
    }

    private func makeOrbAccent(color: UIColor, position: CGPoint) -> SKShapeNode {
        let orb = SKShapeNode(circleOfRadius: 6)
        orb.fillColor = color
        orb.strokeColor = UIColor.white.withAlphaComponent(0.45)
        orb.lineWidth = 1
        orb.position = position
        return orb
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
            self.bellyPatch.fillColor = newColor.withAlphaComponent(0.22)
            self.bellyPatch.strokeColor = UIColor.white.withAlphaComponent(0.14)
            self.foreheadPatch.fillColor = UIColor.white.withAlphaComponent(0.18)
            self.browL.strokeColor = newStroke.withAlphaComponent(0.38)
            self.browR.strokeColor = newStroke.withAlphaComponent(0.38)
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
        path.move(to: CGPoint(x: -33, y: -24))
        path.addQuadCurve(to: CGPoint(x: -27, y: 18), controlPoint: CGPoint(x: -41, y: -2))
        path.addQuadCurve(to: CGPoint(x: -10, y: 38), controlPoint: CGPoint(x: -26, y: 34))
        path.addQuadCurve(to: CGPoint(x: 0, y: 43), controlPoint: CGPoint(x: -5, y: 43))
        path.addQuadCurve(to: CGPoint(x: 10, y: 38), controlPoint: CGPoint(x: 5, y: 43))
        path.addQuadCurve(to: CGPoint(x: 27, y: 18), controlPoint: CGPoint(x: 26, y: 34))
        path.addQuadCurve(to: CGPoint(x: 33, y: -24), controlPoint: CGPoint(x: 41, y: -2))
        path.addQuadCurve(to: CGPoint(x: 18, y: -40), controlPoint: CGPoint(x: 32, y: -42))
        path.addQuadCurve(to: CGPoint(x: 0, y: -44), controlPoint: CGPoint(x: 9, y: -45))
        path.addQuadCurve(to: CGPoint(x: -18, y: -40), controlPoint: CGPoint(x: -9, y: -45))
        path.addQuadCurve(to: CGPoint(x: -33, y: -24), controlPoint: CGPoint(x: -32, y: -42))
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
