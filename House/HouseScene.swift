import SpriteKit
import Foundation

// MARK: - HouseScene

final class HouseScene: SKScene {
    // MARK: Config
    private var tileW: CGFloat = 84
    private var tileH: CGFloat = 42
    private var wallHeight: CGFloat = 96
    private var sceneConfigured = false

    // MARK: Nodes
    private var floorLayer = SKNode()
    private var wallLayer  = SKNode()
    private var itemLayer  = SKNode()
    private var decorLayer = SKNode()
    private var petNode: PetNode?
    private var petShadowNode: SKShapeNode?

    // MARK: State
    var mood: PetMood = .calm { didSet { updateMoodColors() } }
    var petStage: Int = 0 {
        didSet {
            guard oldValue != petStage, sceneConfigured else { return }
            refreshPetAppearance(animated: true)
        }
    }
    var placedItems: [(itemID: String, position: CGPoint)] = [] {
        didSet { refreshItems() }
    }
    private var petColor: PetColor = .cream {
        didSet {
            guard oldValue != petColor else { return }
            petNode?.setColor(petColor)
        }
    }
    private var movementVector: CGVector = .zero
    private var lastMovementUpdateTime: TimeInterval?
    private let movementSpeed: CGFloat = 132

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

    private var isCompactScene: Bool {
        size.width < 390 || size.height < 340
    }

    override func didMove(to view: SKView) {
        backgroundColor = .clear
        anchorPoint = CGPoint(x: 0.5, y: isCompactScene ? 0.40 : 0.34)

        addChild(floorLayer)
        addChild(wallLayer)
        addChild(decorLayer)
        addChild(itemLayer)

        configureLayout(for: size)
        buildRoom()
        addPet()
        sceneConfigured = true
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        guard sceneConfigured, oldSize != size else { return }
        configureLayout(for: size)
        rebuildScene()
    }

    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)

        guard movementVector != .zero else {
            lastMovementUpdateTime = currentTime
            return
        }

        let deltaTime: CGFloat
        if let lastMovementUpdateTime {
            deltaTime = CGFloat(min(currentTime - lastMovementUpdateTime, 1.0 / 20.0))
        } else {
            deltaTime = 1.0 / 60.0
        }
        lastMovementUpdateTime = currentTime

        movePet(
            by: CGVector(
                dx: movementVector.dx * movementSpeed * deltaTime,
                dy: movementVector.dy * movementSpeed * deltaTime
            )
        )
    }

    // MARK: - Room Construction

    private func buildRoom() {
        floorLayer.removeAllChildren()
        wallLayer.removeAllChildren()
        decorLayer.removeAllChildren()

        buildFrontRoom()
        addArchitecturalDecor()
        addAmbientDecor()
    }

    private func rebuildScene() {
        floorLayer.removeAllChildren()
        wallLayer.removeAllChildren()
        decorLayer.removeAllChildren()
        itemLayer.removeAllChildren()
        petNode?.removeFromParent()
        petShadowNode?.removeFromParent()
        petNode = nil
        petShadowNode = nil
        buildRoom()
        addPet()
        refreshItems()
    }

    private func configureLayout(for size: CGSize) {
        let compact = size.width < 390 || size.height < 340
        let baseTileWidth = compact ? size.width * 0.125 : size.width * 0.112
        tileW = min(max(baseTileWidth, compact ? 34 : 46), compact ? 72 : 88)
        tileH = tileW * 0.58
        let baseWallHeight = compact
            ? min(max(size.height * 0.34, 96), 160)
            : min(max(size.height * 0.42, 150), 248)
        wallHeight = baseWallHeight
        anchorPoint = CGPoint(x: 0.5, y: compact ? 0.48 : 0.44)
    }

    private func addAmbientDecor() {
        let centerPos = CGPoint(x: 0, y: -tileH * 1.1)

        let rugWidth = tileW * 3.8
        let rugHeight = tileH * 2.3
        let rug = SKShapeNode(rectOf: CGSize(width: rugWidth, height: rugHeight), cornerRadius: 26)
        rug.fillColor = UIColor(red: 0.92, green: 0.88, blue: 1.0, alpha: 0.95)
        rug.strokeColor = UIColor.white.withAlphaComponent(0.35)
        rug.lineWidth = 1
        rug.position = centerPos
        rug.zPosition = 120
        decorLayer.addChild(rug)

        let glow = SKShapeNode(ellipseOf: CGSize(width: tileW * 4.2, height: tileH * 1.8))
        glow.fillColor = UIColor.white.withAlphaComponent(0.12)
        glow.strokeColor = .clear
        glow.position = CGPoint(x: centerPos.x + tileW * 1.1, y: wallHeight * 0.9)
        glow.zPosition = 180
        decorLayer.addChild(glow)

        let sparkles = [
            CGPoint(x: -tileW * 2.6, y: wallHeight * 0.92),
            CGPoint(x: tileW * 2.7, y: wallHeight * 0.86),
            CGPoint(x: tileW * 0.8, y: wallHeight * 1.16)
        ]
        for point in sparkles {
            let sparkle = SKLabelNode(text: "✦")
            sparkle.fontSize = 18
            sparkle.fontColor = UIColor.white.withAlphaComponent(0.45)
            sparkle.position = point
            sparkle.zPosition = 185
            decorLayer.addChild(sparkle)
        }
    }

    private func buildFrontRoom() {
        let compact = isCompactScene
        let roomWidth = tileW * (compact ? 6.4 : 7.6)
        let roomDepth = tileH * (compact ? 3.4 : 4.2)
        let floorY = -tileH * (compact ? 1.6 : 1.8)

        let wall = SKShapeNode(rectOf: CGSize(width: roomWidth, height: wallHeight * 1.18), cornerRadius: 30)
        wall.fillColor = wallColor.withAlphaComponent(0.92)
        wall.strokeColor = UIColor.white.withAlphaComponent(0.32)
        wall.lineWidth = 1.2
        wall.position = CGPoint(x: 0, y: floorY + wallHeight * 0.64)
        wall.zPosition = 5
        wallLayer.addChild(wall)

        let wallPanel = SKShapeNode(rectOf: CGSize(width: roomWidth * 0.88, height: wallHeight * 0.78), cornerRadius: 22)
        wallPanel.fillColor = wallColor.withAlphaComponent(0.58)
        wallPanel.strokeColor = UIColor.white.withAlphaComponent(0.14)
        wallPanel.lineWidth = 1
        wallPanel.position = CGPoint(x: 0, y: floorY + wallHeight * 0.68)
        wallPanel.zPosition = 6
        wallLayer.addChild(wallPanel)

        let skirting = SKShapeNode(rectOf: CGSize(width: roomWidth * 0.94, height: 16), cornerRadius: 8)
        skirting.fillColor = UIColor(red: 0.93, green: 0.88, blue: 0.82, alpha: 0.98)
        skirting.strokeColor = UIColor(red: 0.79, green: 0.70, blue: 0.62, alpha: 0.72)
        skirting.lineWidth = 1
        skirting.position = CGPoint(x: 0, y: floorY + 6)
        skirting.zPosition = 8
        wallLayer.addChild(skirting)

        let floor = SKShapeNode(rectOf: CGSize(width: roomWidth * 1.02, height: roomDepth), cornerRadius: 22)
        floor.fillColor = floorColor.withAlphaComponent(0.98)
        floor.strokeColor = UIColor.white.withAlphaComponent(0.18)
        floor.lineWidth = 1
        floor.position = CGPoint(x: 0, y: floorY - roomDepth * 0.25)
        floor.zPosition = 20
        floorLayer.addChild(floor)

        let floorInner = SKShapeNode(rectOf: CGSize(width: roomWidth * 0.92, height: roomDepth * 0.68), cornerRadius: 18)
        floorInner.fillColor = floorColor.withAlphaComponent(0.74)
        floorInner.strokeColor = UIColor.clear
        floorInner.position = CGPoint(x: 0, y: floorY - roomDepth * 0.20)
        floorInner.zPosition = 21
        floorLayer.addChild(floorInner)

        addFloorLines(roomWidth: roomWidth, floorY: floorY, roomDepth: roomDepth)
    }

    private func addFloorLines(roomWidth: CGFloat, floorY: CGFloat, roomDepth: CGFloat) {
        let lineColor = UIColor.white.withAlphaComponent(0.14)
        for index in -2...2 {
            let x = CGFloat(index) * roomWidth * 0.17
            let path = CGMutablePath()
            path.move(to: CGPoint(x: x, y: floorY - roomDepth * 0.47))
            path.addLine(to: CGPoint(x: x, y: floorY + roomDepth * 0.04))
            let line = SKShapeNode(path: path)
            line.strokeColor = lineColor
            line.lineWidth = 1
            line.zPosition = 22
            floorLayer.addChild(line)
        }
    }

    private func addArchitecturalDecor() {
        let wallY = wallHeight * 0.34
        addWallWindow(at: CGPoint(x: tileW * 1.95, y: wallY))
        addFloatingShelf(at: CGPoint(x: -tileW * 1.95, y: wallY + wallHeight * 0.04))
        addHangingLamp(at: CGPoint(x: 0, y: wallHeight * 0.96))
        addFloorPlant(at: CGPoint(x: tileW * 2.75, y: -tileH * 2.45))
        addSidePouf(at: CGPoint(x: -tileW * 2.15, y: -tileH * 2.95))
    }

    private func addWallWindow(at position: CGPoint) {
        let glow = SKShapeNode(ellipseOf: CGSize(width: tileW * 2.0, height: wallHeight * 0.58))
        glow.fillColor = UIColor(red: 1.0, green: 0.95, blue: 0.80, alpha: 0.12)
        glow.strokeColor = .clear
        glow.position = CGPoint(x: position.x, y: position.y - wallHeight * 0.06)
        glow.zPosition = 90
        decorLayer.addChild(glow)

        let frame = SKShapeNode(rectOf: CGSize(width: tileW * 1.5, height: wallHeight * 0.82), cornerRadius: 12)
        frame.fillColor = UIColor(red: 0.98, green: 0.94, blue: 0.86, alpha: 0.98)
        frame.strokeColor = UIColor(red: 0.79, green: 0.66, blue: 0.50, alpha: 0.88)
        frame.lineWidth = 2
        frame.position = position
        frame.zPosition = 96
        decorLayer.addChild(frame)

        let glass = SKShapeNode(rectOf: CGSize(width: tileW * 1.22, height: wallHeight * 0.62), cornerRadius: 9)
        glass.fillColor = UIColor(red: 0.77, green: 0.90, blue: 1.0, alpha: 0.78)
        glass.strokeColor = UIColor.white.withAlphaComponent(0.62)
        glass.lineWidth = 1.2
        glass.position = position
        glass.zPosition = 97
        decorLayer.addChild(glass)

        let curtainL = SKShapeNode(rectOf: CGSize(width: tileW * 0.28, height: wallHeight * 0.88), cornerRadius: 10)
        curtainL.fillColor = UIColor(red: 0.96, green: 0.77, blue: 0.86, alpha: 0.94)
        curtainL.strokeColor = UIColor.clear
        curtainL.position = CGPoint(x: position.x - tileW * 0.74, y: position.y)
        curtainL.zPosition = 95
        decorLayer.addChild(curtainL)

        let curtainR = SKShapeNode(rectOf: CGSize(width: tileW * 0.28, height: wallHeight * 0.88), cornerRadius: 10)
        curtainR.fillColor = UIColor(red: 0.88, green: 0.82, blue: 1.0, alpha: 0.94)
        curtainR.strokeColor = UIColor.clear
        curtainR.position = CGPoint(x: position.x + tileW * 0.74, y: position.y)
        curtainR.zPosition = 95
        decorLayer.addChild(curtainR)
    }

    private func addFloatingShelf(at position: CGPoint) {
        let plank = SKShapeNode(rectOf: CGSize(width: tileW * 1.45, height: 10), cornerRadius: 5)
        plank.fillColor = UIColor(red: 0.83, green: 0.63, blue: 0.45, alpha: 0.98)
        plank.strokeColor = UIColor(red: 0.63, green: 0.44, blue: 0.28, alpha: 0.82)
        plank.lineWidth = 1
        plank.position = position
        plank.zPosition = 92
        decorLayer.addChild(plank)

        let book = SKShapeNode(rectOf: CGSize(width: 12, height: 24), cornerRadius: 3)
        book.fillColor = UIColor(red: 0.56, green: 0.73, blue: 0.96, alpha: 0.98)
        book.strokeColor = .clear
        book.position = CGPoint(x: position.x - 18, y: position.y + 12)
        book.zPosition = 93
        decorLayer.addChild(book)

        let vase = SKShapeNode(ellipseOf: CGSize(width: 18, height: 24))
        vase.fillColor = UIColor(red: 0.95, green: 0.81, blue: 0.88, alpha: 0.96)
        vase.strokeColor = UIColor.white.withAlphaComponent(0.48)
        vase.lineWidth = 1
        vase.position = CGPoint(x: position.x + 20, y: position.y + 15)
        vase.zPosition = 93
        decorLayer.addChild(vase)
    }

    private func addHangingLamp(at position: CGPoint) {
        let cordPath = CGMutablePath()
        cordPath.move(to: CGPoint(x: position.x, y: position.y + 30))
        cordPath.addLine(to: CGPoint(x: position.x, y: position.y))
        let cord = SKShapeNode(path: cordPath)
        cord.strokeColor = UIColor(red: 0.65, green: 0.57, blue: 0.50, alpha: 0.76)
        cord.lineWidth = 2
        cord.zPosition = 110
        decorLayer.addChild(cord)

        let shade = SKShapeNode(rectOf: CGSize(width: tileW * 0.72, height: 20), cornerRadius: 10)
        shade.fillColor = UIColor(red: 0.98, green: 0.92, blue: 0.82, alpha: 0.98)
        shade.strokeColor = UIColor(red: 0.82, green: 0.70, blue: 0.55, alpha: 0.86)
        shade.lineWidth = 1.2
        shade.position = position
        shade.zPosition = 111
        decorLayer.addChild(shade)

        let lightGlow = SKShapeNode(ellipseOf: CGSize(width: tileW * 2.4, height: wallHeight * 0.58))
        lightGlow.fillColor = UIColor(red: 1.0, green: 0.97, blue: 0.82, alpha: 0.16)
        lightGlow.strokeColor = .clear
        lightGlow.position = CGPoint(x: position.x, y: position.y - wallHeight * 0.28)
        lightGlow.zPosition = 89
        decorLayer.addChild(lightGlow)
    }

    private func addFloorPlant(at position: CGPoint) {
        let pot = SKShapeNode(rectOf: CGSize(width: tileW * 0.46, height: 18), cornerRadius: 8)
        pot.fillColor = UIColor(red: 0.89, green: 0.66, blue: 0.49, alpha: 0.98)
        pot.strokeColor = UIColor(red: 0.67, green: 0.48, blue: 0.33, alpha: 0.86)
        pot.lineWidth = 1
        pot.position = position
        pot.zPosition = 205
        decorLayer.addChild(pot)

        for (offset, scale) in [(-10.0, 1.0), (0.0, 1.18), (11.0, 0.94)] {
            let leaf = SKShapeNode(ellipseOf: CGSize(width: 14 * scale, height: 30 * scale))
            leaf.fillColor = UIColor(red: 0.52, green: 0.84, blue: 0.56, alpha: 0.96)
            leaf.strokeColor = UIColor.clear
            leaf.position = CGPoint(x: position.x + offset, y: position.y + 18 + 10 * scale)
            leaf.zRotation = offset < 0 ? -.pi / 7 : .pi / 8
            leaf.zPosition = 206
            decorLayer.addChild(leaf)
        }
    }

    private func addSidePouf(at position: CGPoint) {
        let pouf = SKShapeNode(ellipseOf: CGSize(width: tileW * 0.70, height: tileH * 0.92))
        pouf.fillColor = UIColor(red: 0.96, green: 0.80, blue: 0.87, alpha: 0.95)
        pouf.strokeColor = UIColor(red: 0.86, green: 0.63, blue: 0.77, alpha: 0.74)
        pouf.lineWidth = 1.2
        pouf.position = position
        pouf.zPosition = 214
        decorLayer.addChild(pouf)

        let tuft = SKShapeNode(circleOfRadius: 4)
        tuft.fillColor = UIColor.white.withAlphaComponent(0.52)
        tuft.strokeColor = .clear
        tuft.position = CGPoint(x: position.x, y: position.y + 3)
        tuft.zPosition = 215
        decorLayer.addChild(tuft)
    }

    // MARK: - Pet

    private func addPet() {
        let size = petBodySize(for: petStage)
        let pet = PetNode()
        pet.setColor(petColor, animated: false)
        pet.setMood(mood)
        pet.setStage(petStage)
        pet.setScale(min(size.width / 92, size.height / 82))

        // Ombra
        let shadow = SKShapeNode(ellipseOf: CGSize(width: size.width, height: tileH * 0.32))
        shadow.fillColor = UIColor(red: 0.5, green: 0.4, blue: 0.7, alpha: 0.25)
        shadow.strokeColor = .clear

        let centerPos = CGPoint(x: 0, y: -tileH * 1.55)
        pet.position = CGPoint(x: centerPos.x, y: centerPos.y + tileH * 1.16)
        pet.zPosition = 500

        shadow.position = CGPoint(x: centerPos.x, y: centerPos.y - tileH * 0.18)
        shadow.zPosition = 499

        // Animazione idle
        let bob = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 5, duration: 0.95),
            SKAction.moveBy(x: 0, y: -5, duration: 0.95)
        ])
        pet.run(SKAction.repeatForever(bob))

        addChild(shadow)
        addChild(pet)
        petNode = pet
        petShadowNode = shadow

        if mood == .evolving {
            runEvolutionCelebration()
        }
    }

    func setMovementVector(_ vector: CGVector) {
        let length = hypot(vector.dx, vector.dy)
        guard length > 0.01 else {
            stopMovement()
            return
        }

        movementVector = CGVector(dx: vector.dx / length, dy: vector.dy / length)
        updatePetFacing(for: movementVector.dx)
    }

    func stopMovement() {
        movementVector = .zero
        lastMovementUpdateTime = nil
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

    private func makeItemNode(def: HouseItemDefinition) -> SKNode {
        let container = SKNode()

        if def.id == "deco_window" {
            return makeWindowItemNode()
        }

        // Emoji come label (placeholder finché non ci sono asset reali)
        let label = SKLabelNode(text: emojiFor(def))
        label.fontSize = max(tileW * 0.35, 20)
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
        let id = def.id

        if id.contains("carrot") { return "🥕" }
        if id.contains("cookie") { return "🍪" }
        if id.contains("cake") || id.contains("pancakes") { return "🎂" }
        if id.contains("tea") || id.contains("milk") || id.contains("smoothie") || id.contains("lemonade") { return "🍵" }
        if id.contains("strawberry") { return "🍓" }
        if id.contains("toast") { return "🍞" }
        if id.contains("bento") { return "🍱" }
        if id.contains("jam") { return "🫙" }
        if id.contains("soup") { return "🥣" }
        if id.contains("mochi") { return "🍡" }

        if id.contains("bowl") { return "🥣" }
        if id.contains("cushion") { return "🛋️" }
        if id.contains("blanket") || id.contains("bed") { return "🛏️" }
        if id.contains("bookshelf") { return "🪜" }
        if id.contains("closet") { return "🚪" }
        if id.contains("bath") { return "🛁" }
        if id.contains("stool") { return "🪑" }
        if id.contains("desk") { return "🧸" }
        if id.contains("nightstand") { return "🗄️" }
        if id.contains("hammock") { return "🪢" }
        if id.contains("mirror") { return "🪞" }
        if id.contains("screen") { return "🧧" }

        if id.contains("plant") || id.contains("planter") { return "🪴" }
        if id.contains("lamp") { return "🌙" }
        if id.contains("rug") { return "🪄" }
        if id.contains("window") { return "🪟" }
        if id.contains("clock") { return "🕰️" }
        if id.contains("frame") || id.contains("poster") || id.contains("painting") { return "🖼️" }
        if id.contains("garland") { return "🎐" }
        if id.contains("vase") { return "🏺" }
        if id.contains("plush") { return "🧸" }
        if id.contains("musicbox") { return "🎼" }
        if id.contains("mobile") { return "✨" }

        if id.contains("crystal") || id.contains("orb") { return "💎" }
        if id.contains("book") || id.contains("map") { return "📖" }
        if id.contains("candle") { return "🕯️" }
        if id.contains("lotus") { return "🪷" }
        if id.contains("moon_mirror") { return "🌙" }
        if id.contains("fountain") { return "⛲" }
        if id.contains("fairy_jar") { return "🫙" }
        if id.contains("comet") { return "☄️" }
        if id.contains("snow_globe") { return "❄️" }
        if id.contains("portal") { return "🪐" }

        return "📦"
    }

    private func makeWindowItemNode() -> SKNode {
        let container = SKNode()

        let shadow = SKShapeNode(ellipseOf: CGSize(width: tileW * 0.92, height: tileH * 0.34))
        shadow.fillColor = UIColor.black.withAlphaComponent(0.12)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 0, y: -26)

        let frame = SKShapeNode(rectOf: CGSize(width: tileW * 1.18, height: wallHeight * 0.92), cornerRadius: 12)
        frame.fillColor = UIColor(red: 0.96, green: 0.92, blue: 0.80, alpha: 0.98)
        frame.strokeColor = UIColor(red: 0.83, green: 0.71, blue: 0.55, alpha: 0.94)
        frame.lineWidth = 2
        frame.position = CGPoint(x: 0, y: wallHeight * 0.36)

        let glass = SKShapeNode(rectOf: CGSize(width: tileW * 0.95, height: wallHeight * 0.72), cornerRadius: 9)
        glass.fillColor = UIColor(red: 0.74, green: 0.90, blue: 1.0, alpha: 0.78)
        glass.strokeColor = UIColor.white.withAlphaComponent(0.65)
        glass.lineWidth = 1.2
        glass.position = CGPoint(x: 0, y: wallHeight * 0.36)

        let verticalBar = SKShapeNode(rectOf: CGSize(width: 3, height: wallHeight * 0.70), cornerRadius: 1.5)
        verticalBar.fillColor = UIColor.white.withAlphaComponent(0.62)
        verticalBar.strokeColor = .clear
        verticalBar.position = glass.position

        let horizontalBar = SKShapeNode(rectOf: CGSize(width: tileW * 0.90, height: 3), cornerRadius: 1.5)
        horizontalBar.fillColor = UIColor.white.withAlphaComponent(0.62)
        horizontalBar.strokeColor = .clear
        horizontalBar.position = glass.position

        let sunGlow = SKShapeNode(ellipseOf: CGSize(width: tileW * 1.25, height: tileH * 0.62))
        sunGlow.fillColor = UIColor(red: 1.0, green: 0.95, blue: 0.74, alpha: 0.16)
        sunGlow.strokeColor = .clear
        sunGlow.position = CGPoint(x: tileW * 0.16, y: 0)

        container.addChild(shadow)
        container.addChild(frame)
        container.addChild(glass)
        container.addChild(verticalBar)
        container.addChild(horizontalBar)
        container.addChild(sunGlow)

        return container
    }

    // MARK: - Mood Update

    private func updateMoodColors() {
        buildRoom()
        petNode?.setMood(mood)
        if mood == .evolving {
            runEvolutionCelebration()
        }
    }

    func runEvolutionCelebration() {
        guard let petNode, let petShadowNode else { return }

        petNode.removeAction(forKey: "evolutionPulse")
        petNode.setStage(petStage)
        petNode.setMood(.evolving)

        let pulse = SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 1.14, duration: 0.22),
                SKAction.fadeAlpha(to: 1.0, duration: 0.22)
            ]),
            SKAction.scale(to: 1.0, duration: 0.24)
        ])
        petNode.run(pulse, withKey: "evolutionPulse")

        let shadowPulse = SKAction.sequence([
            SKAction.scaleX(to: 1.2, y: 1.08, duration: 0.22),
            SKAction.scale(to: 1.0, duration: 0.24)
        ])
        petShadowNode.run(shadowPulse)

        let sparkleCount = 7 + min(petStage, 3)
        for index in 0..<sparkleCount {
            let sparkle = SKLabelNode(text: index.isMultiple(of: 2) ? "✦" : "✧")
            sparkle.fontSize = 14 + CGFloat(index % 3) * 4
            sparkle.fontColor = UIColor.white.withAlphaComponent(0.85)
            sparkle.position = petNode.position
            sparkle.zPosition = 560 + CGFloat(index)

            let angle = CGFloat(index) / CGFloat(sparkleCount) * .pi * 2
            let radius = tileW * (0.7 + CGFloat(index % 2) * 0.18)
            let destination = CGPoint(
                x: petNode.position.x + cos(angle) * radius,
                y: petNode.position.y + sin(angle) * radius * 0.65 + wallHeight * 0.22
            )

            addChild(sparkle)
            sparkle.run(.sequence([
                .group([
                    .move(to: destination, duration: 0.65),
                    .fadeOut(withDuration: 0.65),
                    .scale(to: 1.35, duration: 0.65)
                ]),
                .removeFromParent()
            ]))
        }
    }

    func applyPetColor(_ color: PetColor, animated: Bool = true) {
        petColor = color
        petNode?.setColor(color, animated: animated)
    }

    private func refreshPetAppearance(animated: Bool) {
        let centerPos = CGPoint(x: 0, y: -tileH * 1.55)
        let newSize = petBodySize(for: petStage)

        guard let petNode, let petShadowNode else {
            addPet()
            return
        }

        let previousPosition = petNode.position
        petNode.removeAllActions()
        petNode.setStage(petStage)
        petNode.setMood(mood)
        petNode.position = CGPoint(x: centerPos.x, y: centerPos.y + tileH * 1.16)
        petNode.setScale(min(newSize.width / 92, newSize.height / 82))

        petShadowNode.path = CGPath(ellipseIn: CGRect(
            x: -newSize.width / 2,
            y: -(tileH * 0.32) / 2,
            width: newSize.width,
            height: tileH * 0.32
        ), transform: nil)
        petShadowNode.position = CGPoint(x: centerPos.x, y: centerPos.y - tileH * 0.18)

        guard animated else { return }
        petNode.position = previousPosition
        petNode.run(.repeatForever(.sequence([
            .moveBy(x: 0, y: 5, duration: 0.95),
            .moveBy(x: 0, y: -5, duration: 0.95)
        ])))
        petNode.run(.move(to: CGPoint(x: centerPos.x, y: centerPos.y + tileH * 1.16), duration: 0.2))
        runEvolutionCelebration()
    }

    private func movePet(by delta: CGVector) {
        guard let petNode, let petShadowNode else { return }

        let targetPosition = CGPoint(
            x: petNode.position.x + delta.dx,
            y: petNode.position.y + delta.dy
        )
        let clampedPosition = clampedPetPosition(targetPosition)

        petNode.position = clampedPosition
        petShadowNode.position = CGPoint(
            x: clampedPosition.x,
            y: clampedPosition.y - tileH * 1.34
        )
    }

    private func clampedPetPosition(_ position: CGPoint) -> CGPoint {
        let bounds = petMovementBounds()
        return CGPoint(
            x: min(max(position.x, bounds.minX), bounds.maxX),
            y: min(max(position.y, bounds.minY), bounds.maxY)
        )
    }

    private func petMovementBounds() -> CGRect {
        let roomWidth = tileW * (isCompactScene ? 6.4 : 7.6)
        let roomDepth = tileH * (isCompactScene ? 3.4 : 4.2)
        let minX = -roomWidth * 0.39
        let maxX = roomWidth * 0.39
        let minY = -tileH * 2.25 - roomDepth * 0.18
        let maxY = -tileH * 0.35

        return CGRect(
            x: minX,
            y: minY,
            width: max(maxX - minX, 1),
            height: max(maxY - minY, 1)
        )
    }

    private func updatePetFacing(for horizontalComponent: CGFloat) {
        guard let petNode, abs(horizontalComponent) > 0.08 else { return }
        let direction: CGFloat = horizontalComponent < 0 ? -1 : 1
        petNode.xScale = abs(petNode.xScale) * direction
    }

    private func petBodySize(for stage: Int) -> CGSize {
        let stageScale = 1.0 + CGFloat(min(stage, 4)) * 0.12
        return CGSize(width: tileW * 0.98 * stageScale, height: tileH * 1.95 * stageScale)
    }

}
