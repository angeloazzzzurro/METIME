import SpriteKit
import Foundation

// MARK: - HouseScene

final class HouseScene: SKScene {
    private let keyLightColor = UIColor(red: 1.00, green: 0.96, blue: 0.84, alpha: 1)
    private let isoShadowColor = UIColor(red: 0.16, green: 0.16, blue: 0.22, alpha: 1)

    // MARK: Config
    private let tileW: CGFloat = 80
    private let tileH: CGFloat = 40
    private let cols = 5
    private let rows = 5

    // MARK: Nodes
    private var ambientLayer = SKNode()
    private var floorLayer = SKNode()
    private var wallLayer  = SKNode()
    private var decorLayer = SKNode()
    private var itemLayer  = SKNode()
    private var frameLayer = SKNode()
    private var petNode: PetNode?
    private var petShadowNode: SKShapeNode?
    private var petStageNode: SKNode?
    private weak var windowNode: SKShapeNode?

    // MARK: State
    var mood: PetMood = .calm { didSet { updateMoodColors() } }
    var petColor: PetColor = .lavender { didSet { updatePetPresentation() } }
    var petStage: Int = 0 { didSet { updatePetPresentation() } }
    var placedItems: [(itemID: String, position: CGPoint)] = [] {
        didSet { refreshItems() }
    }

    // MARK: Mood palette (pareti + pavimento)
    private var floorColor: UIColor {
        switch mood {
        case .happy:   return UIColor(red: 1.00, green: 0.95, blue: 0.80, alpha: 1)
        case .calm:    return UIColor(red: 0.88, green: 0.85, blue: 0.98, alpha: 1)
        case .anxious: return UIColor(red: 1.00, green: 0.90, blue: 0.85, alpha: 1)
        case .sleepy:  return UIColor(red: 0.80, green: 0.88, blue: 0.95, alpha: 1)
        case .sick:    return UIColor(red: 0.85, green: 0.88, blue: 0.92, alpha: 1)
        case .evolving:return UIColor(red: 0.92, green: 0.86, blue: 1.00, alpha: 1)
        }
    }

    private var wallColor: UIColor {
        switch mood {
        case .happy:   return UIColor(red: 1.00, green: 0.88, blue: 0.60, alpha: 1)
        case .calm:    return UIColor(red: 0.78, green: 0.72, blue: 0.96, alpha: 1)
        case .anxious: return UIColor(red: 1.00, green: 0.78, blue: 0.72, alpha: 1)
        case .sleepy:  return UIColor(red: 0.70, green: 0.80, blue: 0.92, alpha: 1)
        case .sick:    return UIColor(red: 0.75, green: 0.80, blue: 0.88, alpha: 1)
        case .evolving:return UIColor(red: 0.86, green: 0.74, blue: 0.98, alpha: 1)
        }
    }

    // MARK: - Lifecycle

    override func didMove(to view: SKView) {
        backgroundColor = .clear
        anchorPoint = CGPoint(x: 0.5, y: 0.24)

        addChild(ambientLayer)
        addChild(floorLayer)
        addChild(wallLayer)
        addChild(decorLayer)
        addChild(itemLayer)
        addChild(frameLayer)

        buildRoom()
        addPet()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if let petNode, petNode.contains(location) {
            animatePetInteraction()
            return
        }

        if let windowNode, windowNode.contains(location) {
            animateWindowGlow()
            return
        }

        if let tappedItem = itemLayer.children.first(where: { $0.contains(location) }) {
            animateItemInteraction(tappedItem)
            return
        }

        addTapPulse(at: location)
    }

    // MARK: - Room Construction

    private func buildRoom() {
        ambientLayer.removeAllChildren()
        floorLayer.removeAllChildren()
        wallLayer.removeAllChildren()
        decorLayer.removeAllChildren()
        frameLayer.removeAllChildren()

        addAmbientBackdrop()
        addFloorGlow()

        for row in 0..<rows {
            for col in 0..<cols {
                let tile = makeTile(col: col, row: row)
                floorLayer.addChild(tile)
            }
        }

        buildWalls()
        addRoomFrame()
        addWindow()
        addBuiltInDecor()
    }

    private func makeTile(col: Int, row: Int) -> SKShapeNode {
        let pos = isoPosition(col: col, row: row)
        let path = isoTilePath()
        let node = SKShapeNode(path: path)

        let warmth = CGFloat(col + row) * 0.012
        node.fillColor = blendedColor(
            from: floorColor,
            to: UIColor(red: 1.0, green: 0.94, blue: 0.76, alpha: 1),
            fraction: warmth
        )
        node.strokeColor = .clear
        node.lineWidth = 0
        node.position = pos
        node.zPosition = CGFloat(row * cols + col)
        node.name = "tile_\(col)_\(row)"
        return node
    }

    private func buildWalls() {
        let wallHeight: CGFloat = 118

        for row in 0..<rows {
            let wall = makeWallLeft(row: row, wallHeight: wallHeight)
            wallLayer.addChild(wall)
        }

        for col in 0..<cols {
            let wall = makeWallBack(col: col, wallHeight: wallHeight)
            wallLayer.addChild(wall)
        }
    }

    private func makeWallLeft(row: Int, wallHeight: CGFloat) -> SKShapeNode {
        let basePos = isoPosition(col: 0, row: row)
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -tileW / 2, y: 0))
        path.addLine(to: CGPoint(x: 0, y: tileH / 2))
        path.addLine(to: CGPoint(x: 0, y: tileH / 2 + wallHeight))
        path.addLine(to: CGPoint(x: -tileW / 2, y: wallHeight))
        path.closeSubpath()

        let node = SKShapeNode(path: path)
        node.fillColor = UIColor(red: 1.00, green: 0.84, blue: 0.73, alpha: 1)
        node.strokeColor = UIColor(red: 0.82, green: 0.57, blue: 0.45, alpha: 1)
        node.lineWidth = 1.8
        node.position = basePos
        node.zPosition = CGFloat(row * cols) - 0.5
        addWallGloss(to: node, size: CGSize(width: tileW * 0.22, height: wallHeight * 0.60), offset: CGPoint(x: -tileW * 0.10, y: wallHeight * 0.18), alpha: 0.14)
        addWallPanel(to: node, width: tileW * 0.52, height: wallHeight * 0.82, yOffset: wallHeight * 0.46)
        return node
    }

    private func makeWallBack(col: Int, wallHeight: CGFloat) -> SKShapeNode {
        let basePos = isoPosition(col: col, row: 0)
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: tileH / 2))
        path.addLine(to: CGPoint(x: tileW / 2, y: 0))
        path.addLine(to: CGPoint(x: tileW / 2, y: wallHeight))
        path.addLine(to: CGPoint(x: 0, y: tileH / 2 + wallHeight))
        path.closeSubpath()

        let node = SKShapeNode(path: path)
        node.fillColor = UIColor(red: 0.88, green: 0.84, blue: 0.98, alpha: 1)
        node.strokeColor = UIColor(red: 0.69, green: 0.58, blue: 0.86, alpha: 1)
        node.lineWidth = 1.8
        node.position = basePos
        node.zPosition = CGFloat(col) - 0.5
        addWallGloss(to: node, size: CGSize(width: tileW * 0.24, height: wallHeight * 0.30), offset: CGPoint(x: tileW * 0.12, y: wallHeight * 0.24), alpha: 0.18)
        addWallPanel(to: node, width: tileW * 0.54, height: wallHeight * 0.80, yOffset: wallHeight * 0.45)
        return node
    }

    private func addWindow() {
        let windowPos = isoPosition(col: 2, row: 0)
        let windowNode = SKShapeNode(path: archedWindowPath(width: 54, height: 74, cornerRadius: 10))
        windowNode.fillColor = UIColor(red: 0.72, green: 0.92, blue: 1.0, alpha: 0.62)
        windowNode.strokeColor = UIColor(red: 0.83, green: 0.62, blue: 0.46, alpha: 1)
        windowNode.lineWidth = 4
        windowNode.position = CGPoint(x: windowPos.x + tileW * 0.52, y: windowPos.y + 100)
        windowNode.zPosition = 200
        addWallGloss(to: windowNode, size: CGSize(width: 30, height: 14), offset: CGPoint(x: -6, y: 14), alpha: 0.28)
        self.windowNode = windowNode

        // Croce della finestra
        let hBar = SKShapeNode(rectOf: CGSize(width: 34, height: 2.5), cornerRadius: 1.2)
        hBar.fillColor = UIColor(red: 0.83, green: 0.62, blue: 0.46, alpha: 1)
        hBar.strokeColor = .clear
        hBar.position.y = -6
        let vBar = SKShapeNode(rectOf: CGSize(width: 2.5, height: 50), cornerRadius: 1.2)
        vBar.fillColor = UIColor(red: 0.83, green: 0.62, blue: 0.46, alpha: 1)
        vBar.strokeColor = .clear
        vBar.position.y = -6
        windowNode.addChild(hBar)
        windowNode.addChild(vBar)

        // Luce solare che filtra
        let light = SKShapeNode(ellipseOf: CGSize(width: 96, height: 34))
        light.fillColor = UIColor(red: 1.0, green: 0.95, blue: 0.72, alpha: 0.18)
        light.strokeColor = .clear
        light.position = CGPoint(x: windowPos.x + tileW * 0.38, y: windowPos.y + 48)
        light.zPosition = 199

        wallLayer.addChild(windowNode)
        wallLayer.addChild(light)
    }

    private func addAmbientBackdrop() {
        let halo = SKShapeNode(ellipseOf: CGSize(width: 320, height: 200))
        halo.fillColor = UIColor.white.withAlphaComponent(0.18)
        halo.strokeColor = .clear
        halo.position = CGPoint(x: 0, y: 58)
        halo.zPosition = -30
        ambientLayer.addChild(halo)

        let vignette = SKShapeNode(ellipseOf: CGSize(width: 420, height: 280))
        vignette.fillColor = UIColor(red: 0.99, green: 0.86, blue: 0.93, alpha: 0.11)
        vignette.strokeColor = .clear
        vignette.position = CGPoint(x: -8, y: 24)
        vignette.zPosition = -31
        ambientLayer.addChild(vignette)
    }

    private func addFloorGlow() {
        let glow = SKShapeNode(ellipseOf: CGSize(width: 280, height: 168))
        glow.fillColor = UIColor(red: 1.0, green: 0.96, blue: 0.84, alpha: 0.16)
        glow.strokeColor = .clear
        glow.position = CGPoint(x: 0, y: -86)
        glow.zPosition = -2
        floorLayer.addChild(glow)
    }

    // MARK: - Pet

    private func addPet() {
        let pet = PetNode()
        let shadow = SKShapeNode(ellipseOf: CGSize(width: 64, height: 14))
        shadow.fillColor = UIColor(red: 0.46, green: 0.34, blue: 0.58, alpha: 0.08)
        shadow.strokeColor = .clear

        let centerPos = isoPosition(col: 2, row: 2)
        pet.position = CGPoint(x: centerPos.x - 2, y: centerPos.y + 42)
        pet.zPosition = 500
        pet.xScale = 0.62
        pet.yScale = 0.58

        shadow.position = CGPoint(x: centerPos.x, y: centerPos.y + 6)
        shadow.zPosition = 499

        addChild(shadow)
        addChild(pet)
        petNode = pet
        petShadowNode = shadow
        updatePetPresentation()
    }

    // MARK: - Items

    private func refreshItems() {
        itemLayer.removeAllChildren()
        for placed in placedItems {
            guard let def = HouseItemDefinition.item(for: placed.itemID) else { continue }
            let itemNode = makeItemNode(def: def)
            itemNode.position = placed.position
            itemNode.zPosition = placed.position.y * -1 + 300
            itemLayer.addChild(itemNode)
        }
    }

    private func addBuiltInDecor() {
        decorLayer.addChild(makePlantNode())
        decorLayer.addChild(makeLampNode())
        decorLayer.addChild(makeWallSparkles())
        decorLayer.addChild(makeHeartSticker())
    }

    private func makeHeartSticker() -> SKNode {
        let sticker = SKShapeNode(path: heartPath())
        sticker.fillColor = UIColor(red: 1.0, green: 0.78, blue: 0.84, alpha: 1)
        sticker.strokeColor = UIColor(red: 0.98, green: 0.62, blue: 0.72, alpha: 1)
        sticker.lineWidth = 2.2
        sticker.position = CGPoint(x: 0, y: -18)
        sticker.zPosition = 340
        sticker.alpha = 0.92
        return sticker
    }

    private func heartPath() -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addCurve(to: CGPoint(x: -18, y: -18), control1: CGPoint(x: -18, y: 8), control2: CGPoint(x: -18, y: -18))
        path.addArc(center: CGPoint(x: -9, y: -18), radius: 9, startAngle: .pi, endAngle: 0, clockwise: false)
        path.addArc(center: CGPoint(x: 9, y: -18), radius: 9, startAngle: .pi, endAngle: 0, clockwise: false)
        path.addCurve(to: CGPoint(x: 0, y: 0), control1: CGPoint(x: 18, y: -18), control2: CGPoint(x: 18, y: 8))
        path.closeSubpath()
        return path
    }

    private func makePlantNode() -> SKNode {
        let container = SKNode()

        let pot = SKShapeNode(rectOf: CGSize(width: 36, height: 24), cornerRadius: 10)
        pot.fillColor = UIColor(red: 0.82, green: 0.95, blue: 0.89, alpha: 1)
        pot.strokeColor = UIColor(red: 0.55, green: 0.73, blue: 0.66, alpha: 1)
        pot.lineWidth = 2

        let soil = SKShapeNode(ellipseOf: CGSize(width: 22, height: 8))
        soil.fillColor = UIColor(red: 0.54, green: 0.40, blue: 0.33, alpha: 0.85)
        soil.strokeColor = .clear
        soil.position = CGPoint(x: 0, y: 8)

        for leaf in plantLeaves() {
            container.addChild(leaf)
        }

        container.addChild(pot)
        container.addChild(soil)
        container.position = CGPoint(x: -126, y: -118)
        container.zPosition = 332
        return container
    }

    private func plantLeaves() -> [SKShapeNode] {
        let specs: [(CGSize, CGPoint, CGFloat, UIColor)] = [
            (CGSize(width: 20, height: 34), CGPoint(x: -10, y: 18), -0.45, UIColor(red: 0.64, green: 0.88, blue: 0.66, alpha: 1)),
            (CGSize(width: 20, height: 38), CGPoint(x: 0, y: 26), 0.0, UIColor(red: 0.71, green: 0.92, blue: 0.73, alpha: 1)),
            (CGSize(width: 20, height: 32), CGPoint(x: 11, y: 16), 0.42, UIColor(red: 0.58, green: 0.84, blue: 0.62, alpha: 1))
        ]

        return specs.map { size, position, angle, fill in
            let leaf = SKShapeNode(ellipseOf: size)
            leaf.fillColor = fill
            leaf.strokeColor = fill.withAlphaComponent(0.85)
            leaf.lineWidth = 1
            leaf.position = position
            leaf.zRotation = angle

            let vein = SKShapeNode(rectOf: CGSize(width: 1.4, height: size.height * 0.72), cornerRadius: 0.7)
            vein.fillColor = UIColor.white.withAlphaComponent(0.45)
            vein.strokeColor = .clear
            leaf.addChild(vein)
            return leaf
        }
    }

    private func makeLampNode() -> SKNode {
        let container = SKNode()

        let stand = SKShapeNode(rectOf: CGSize(width: 18, height: 26), cornerRadius: 8)
        stand.fillColor = UIColor(red: 0.96, green: 0.79, blue: 0.84, alpha: 1)
        stand.strokeColor = UIColor(red: 0.83, green: 0.60, blue: 0.68, alpha: 1)
        stand.lineWidth = 2

        let shade = SKShapeNode(path: lampshadePath())
        shade.fillColor = UIColor(red: 1.0, green: 0.96, blue: 0.92, alpha: 1)
        shade.strokeColor = UIColor(red: 0.88, green: 0.73, blue: 0.69, alpha: 1)
        shade.lineWidth = 2
        shade.position = CGPoint(x: 0, y: 14)

        let glow = SKShapeNode(ellipseOf: CGSize(width: 50, height: 24))
        glow.fillColor = UIColor(red: 1.0, green: 0.94, blue: 0.72, alpha: 0.16)
        glow.strokeColor = .clear
        glow.position = CGPoint(x: -2, y: 6)

        container.addChild(glow)
        container.addChild(stand)
        container.addChild(shade)
        container.position = CGPoint(x: 146, y: -108)
        container.zPosition = 334
        return container
    }

    private func makeWallSparkles() -> SKNode {
        let container = SKNode()
        let specs: [(String, CGPoint, CGFloat, CGFloat)] = [
            ("✦", CGPoint(x: -34, y: 82), 16, 0.52),
            ("♡", CGPoint(x: 102, y: 122), 14, 0.32),
            ("✧", CGPoint(x: 142, y: 76), 12, 0.30)
        ]

        for (symbol, position, size, alpha) in specs {
            let label = SKLabelNode(text: symbol)
            label.fontSize = size
            label.fontColor = UIColor.white.withAlphaComponent(alpha)
            label.position = position
            label.zPosition = 210
            container.addChild(label)
        }

        container.zPosition = 210
        return container
    }

    private func makeItemNode(def: HouseItemDefinition) -> SKNode {
        let container = SKNode()

        // Emoji come label (placeholder finché non ci sono asset reali)
        let label = SKLabelNode(text: emojiFor(def))
        label.fontSize = 28
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center

        // Ombra sotto l'oggetto
        let shadow = SKShapeNode(ellipseOf: CGSize(width: 30, height: 10))
        shadow.fillColor = UIColor.black.withAlphaComponent(0.15)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 0, y: -18)

        container.addChild(shadow)
        container.addChild(label)
        return container
    }

    private func emojiFor(_ def: HouseItemDefinition) -> String {
        switch def.id {
        case "food_carrot":      return "🥕"
        case "food_cookie":      return "🍪"
        case "food_cake":        return "🎂"
        case "food_tea":         return "🍵"
        case "essential_bowl":   return "🥣"
        case "essential_cushion":return "🛋️"
        case "essential_blanket":return "🛏️"
        case "deco_plant":       return "🪴"
        case "deco_lamp":        return "🌙"
        case "deco_rug":         return "🪄"
        case "special_crystal":  return "💎"
        case "special_book":     return "📖"
        case "special_candle":   return "🕯️"
        default:                 return "📦"
        }
    }

    // MARK: - Mood Update

    private func updateMoodColors() {
        buildRoom()
    }

    // MARK: - Isometric Math

    private func isoPosition(col: Int, row: Int) -> CGPoint {
        let x = CGFloat(col - row) * (tileW / 2)
        let y = CGFloat(col + row) * (tileH / 2) * -1
        return CGPoint(x: x, y: y)
    }

    private func isoTilePath() -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: tileH / 2))
        path.addLine(to: CGPoint(x: tileW / 2, y: 0))
        path.addLine(to: CGPoint(x: 0, y: -tileH / 2))
        path.addLine(to: CGPoint(x: -tileW / 2, y: 0))
        path.closeSubpath()
        return path
    }

    private func addWallGloss(to node: SKShapeNode, size: CGSize, offset: CGPoint, alpha: CGFloat) {
        let gloss = SKShapeNode(ellipseOf: size)
        gloss.fillColor = keyLightColor.withAlphaComponent(alpha)
        gloss.strokeColor = .clear
        gloss.position = offset
        gloss.zPosition = 0.1
        node.addChild(gloss)
    }

    private func animatePetInteraction() {
        guard let petNode else { return }
        petNode.bounce()
        let accessory = makeStageAccessory()
        accessory.position = CGPoint(x: petNode.position.x + 28, y: petNode.position.y + 54)
        accessory.alpha = 0
        accessory.zPosition = petNode.zPosition + 1
        addChild(accessory)
        accessory.run(.sequence([.fadeIn(withDuration: 0.10), .moveBy(x: 0, y: 20, duration: 0.45), .fadeOut(withDuration: 0.18), .removeFromParent()]))
    }

    private func animateItemInteraction(_ node: SKNode) {
        node.removeAction(forKey: "itemTap")
        node.run(
            .sequence([
                .rotate(byAngle: 0.12, duration: 0.10),
                .rotate(byAngle: -0.24, duration: 0.16),
                .rotate(byAngle: 0.12, duration: 0.10)
            ]),
            withKey: "itemTap"
        )
    }

    private func animateWindowGlow() {
        guard let windowNode else { return }
        let glow = SKShapeNode(rectOf: CGSize(width: 48, height: 38), cornerRadius: 8)
        glow.fillColor = UIColor.white.withAlphaComponent(0.24)
        glow.strokeColor = .clear
        glow.position = .zero
        glow.zPosition = 0.3
        windowNode.addChild(glow)
        glow.run(.sequence([.fadeIn(withDuration: 0.08), .fadeOut(withDuration: 0.35), .removeFromParent()]))
    }

    private func addTapPulse(at location: CGPoint) {
        let pulse = SKShapeNode(circleOfRadius: 10)
        pulse.position = location
        pulse.fillColor = UIColor.white.withAlphaComponent(0.14)
        pulse.strokeColor = keyLightColor.withAlphaComponent(0.45)
        pulse.lineWidth = 1.4
        pulse.zPosition = 700
        addChild(pulse)
        pulse.run(
            .sequence([
                .group([
                    .scale(to: 3.2, duration: 0.30),
                    .fadeOut(withDuration: 0.30)
                ]),
                .removeFromParent()
            ])
        )
    }

    private func updatePetPresentation() {
        guard let petNode else { return }
        petNode.setColor(petColor, animated: false)
        petNode.setMood(mood)

        let growthScale = min(CGFloat(max(petStage, 0)), 4) * 0.04
        petNode.xScale = 0.62 + growthScale
        petNode.yScale = 0.58 + growthScale * 0.92
        petShadowNode?.xScale = 1.0 + growthScale * 0.65
        petShadowNode?.yScale = 1.0 + growthScale * 0.35

        petStageNode?.removeFromParent()
        let stageNode = makeStageAccessory()
        stageNode.position = CGPoint(x: petNode.position.x + 26, y: petNode.position.y + 48)
        stageNode.zPosition = petNode.zPosition + 1
        addChild(stageNode)
        petStageNode = stageNode
    }

    private func makeStageAccessory() -> SKNode {
        let node = SKNode()
        let symbol: String
        let size: CGFloat
        let bubble = SKShapeNode(circleOfRadius: 16)
        bubble.fillColor = UIColor.white.withAlphaComponent(0.72)
        bubble.strokeColor = UIColor(red: 0.86, green: 0.73, blue: 0.92, alpha: 0.8)
        bubble.lineWidth = 1.2
        bubble.glowWidth = petStage >= 3 ? 4 : 0
        node.addChild(bubble)

        switch petStage {
        case 0:
            symbol = "♡"
            size = 13
        case 1:
            symbol = "🌱"
            size = 18
        case 2:
            symbol = "🌸"
            size = 18
        case 3:
            symbol = "✨"
            size = 20
        default:
            symbol = "👑"
            size = 20
        }
        let label = SKLabelNode(text: symbol)
        label.fontSize = size
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.position.y = -1
        node.addChild(label)
        return node
    }

    private func addRoomFrame() {
        let backLeft = isoPosition(col: 0, row: 0)
        let backRight = isoPosition(col: cols - 1, row: 0)
        let frontLeft = isoPosition(col: 0, row: rows - 1)
        let frontRight = isoPosition(col: cols - 1, row: rows - 1)
        let wallHeight: CGFloat = 118

        let outline = CGMutablePath()
        outline.move(to: CGPoint(x: frontLeft.x - tileW / 2, y: frontLeft.y))
        outline.addLine(to: CGPoint(x: backLeft.x - tileW / 2, y: backLeft.y + wallHeight))
        outline.addLine(to: CGPoint(x: backRight.x + tileW / 2, y: backRight.y + wallHeight))
        outline.addLine(to: CGPoint(x: frontRight.x + tileW / 2, y: frontRight.y))

        let frame = SKShapeNode(path: outline)
        frame.strokeColor = UIColor(red: 0.78, green: 0.56, blue: 0.47, alpha: 0.82)
        frame.lineWidth = 2.0
        frame.lineCap = .round
        frame.lineJoin = .round
        frame.zPosition = 260
        frameLayer.addChild(frame)
    }

    private func blendedColor(from start: UIColor, to end: UIColor, fraction: CGFloat) -> UIColor {
        let clamped = max(0, min(1, fraction))
        var sr: CGFloat = 0
        var sg: CGFloat = 0
        var sb: CGFloat = 0
        var sa: CGFloat = 0
        var er: CGFloat = 0
        var eg: CGFloat = 0
        var eb: CGFloat = 0
        var ea: CGFloat = 0
        start.getRed(&sr, green: &sg, blue: &sb, alpha: &sa)
        end.getRed(&er, green: &eg, blue: &eb, alpha: &ea)

        return UIColor(
            red: sr + (er - sr) * clamped,
            green: sg + (eg - sg) * clamped,
            blue: sb + (eb - sb) * clamped,
            alpha: sa + (ea - sa) * clamped
        )
    }

    private func addWallPanel(to node: SKShapeNode, width: CGFloat, height: CGFloat, yOffset: CGFloat) {
        let panel = SKShapeNode(path: roundedPanelPath(width: width, height: height))
        panel.fillColor = UIColor.white.withAlphaComponent(0.14)
        panel.strokeColor = UIColor.white.withAlphaComponent(0.22)
        panel.lineWidth = 0.8
        panel.position = CGPoint(x: 0, y: yOffset)
        panel.zPosition = 0.08
        node.addChild(panel)
    }

    private func roundedPanelPath(width: CGFloat, height: CGFloat) -> CGPath {
        let radius = width * 0.22
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -width / 2, y: height / 2))
        path.addLine(to: CGPoint(x: width / 2, y: height / 2))
        path.addLine(to: CGPoint(x: width / 2, y: -height / 2 + radius))
        path.addQuadCurve(to: CGPoint(x: width / 2 - radius, y: -height / 2),
                          control: CGPoint(x: width / 2, y: -height / 2))
        path.addLine(to: CGPoint(x: -width / 2 + radius, y: -height / 2))
        path.addQuadCurve(to: CGPoint(x: -width / 2, y: -height / 2 + radius),
                          control: CGPoint(x: -width / 2, y: -height / 2))
        path.closeSubpath()
        return path
    }

    private func lampshadePath() -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -18, y: -10))
        path.addQuadCurve(to: CGPoint(x: 18, y: -10), control: CGPoint(x: 0, y: -18))
        path.addLine(to: CGPoint(x: 12, y: 12))
        path.addQuadCurve(to: CGPoint(x: -12, y: 12), control: CGPoint(x: 0, y: 18))
        path.closeSubpath()
        return path
    }

    private func archedWindowPath(width: CGFloat, height: CGFloat, cornerRadius: CGFloat) -> CGPath {
        let rectHeight = height * 0.62
        let archRadius = width / 2
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -width / 2, y: -height / 2 + cornerRadius))
        path.addLine(to: CGPoint(x: -width / 2, y: -height / 2 + rectHeight))
        path.addArc(center: CGPoint(x: 0, y: -height / 2 + rectHeight), radius: archRadius, startAngle: .pi, endAngle: 0, clockwise: false)
        path.addLine(to: CGPoint(x: width / 2, y: -height / 2 + cornerRadius))
        path.addQuadCurve(to: CGPoint(x: width / 2 - cornerRadius, y: -height / 2),
                          control: CGPoint(x: width / 2, y: -height / 2))
        path.addLine(to: CGPoint(x: -width / 2 + cornerRadius, y: -height / 2))
        path.addQuadCurve(to: CGPoint(x: -width / 2, y: -height / 2 + cornerRadius),
                          control: CGPoint(x: -width / 2, y: -height / 2))
        path.closeSubpath()
        return path
    }
}
