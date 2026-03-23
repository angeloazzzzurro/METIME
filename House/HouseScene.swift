import SpriteKit
import Foundation

// MARK: - HouseScene

final class HouseScene: SKScene {
    private struct TileCoordinate: Hashable {
        let col: Int
        let row: Int
    }

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

    private let cols: Int = 13
    private let rows: Int = 13
    private var centerCol: Int { max(cols / 2, 0) }
    private var centerRow: Int { max(rows / 2, 0) }
    private var petCol: Int { centerCol }
    private var petRow: Int { min(centerRow + 1, rows - 1) }
    private var activeTiles: Set<TileCoordinate> { squareTileCoordinates() }

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
        anchorPoint = CGPoint(x: 0.5, y: 0.34)

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

    // MARK: - Room Construction

    private func buildRoom() {
        floorLayer.removeAllChildren()
        wallLayer.removeAllChildren()
        decorLayer.removeAllChildren()

        // Pavimento isometrico
        for row in 0..<rows {
            for col in 0..<cols where containsTile(col: col, row: row) {
                let tile = makeTile(col: col, row: row)
                floorLayer.addChild(tile)
            }
        }

        // Pareti solo sul perimetro visibile della stanza
        for tile in activeTiles {
            if !containsTile(col: tile.col - 1, row: tile.row) {
                wallLayer.addChild(makeWallLeft(col: tile.col, row: tile.row))
            }
            if !containsTile(col: tile.col, row: tile.row - 1) {
                wallLayer.addChild(makeWallBack(col: tile.col, row: tile.row))
            }
        }

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
        let availableWidth = max(size.width * 1.02, 380)
        let availableHeight = max(size.height * 0.72, 280)

        let widthBasedTile = availableWidth / CGFloat(cols + rows)
        let heightBasedTile = availableHeight / CGFloat(rows + cols) * 2.55
        let resolvedTileW = min(max(min(widthBasedTile, heightBasedTile), 40), 118)

        tileW = resolvedTileW
        tileH = resolvedTileW * 0.5
        let baseWallHeight = min(max(size.height * 0.34, 110), 196)
        wallHeight = baseWallHeight
    }

    private func makeTile(col: Int, row: Int) -> SKShapeNode {
        let pos = isoPosition(col: col, row: row)
        let path = isoTilePath()
        let node = SKShapeNode(path: path)

        let brightness: CGFloat = 1.0 - CGFloat(col + row) * 0.015
        node.fillColor = floorColor.withAlphaComponent(brightness)
        node.strokeColor = UIColor.white.withAlphaComponent(0.22)
        node.lineWidth = 0.5
        node.position = pos
        node.zPosition = CGFloat(row * cols + col)
        node.name = "tile_\(col)_\(row)"
        return node
    }

    private func makeWallLeft(col: Int, row: Int) -> SKShapeNode {
        let basePos = isoPosition(col: col, row: row)

        let path = CGMutablePath()
        path.move(to: CGPoint(x: -tileW / 2, y: 0))
        path.addLine(to: CGPoint(x: 0, y: tileH / 2))
        path.addLine(to: CGPoint(x: 0, y: tileH / 2 + wallHeight))
        path.addLine(to: CGPoint(x: -tileW / 2, y: wallHeight))
        path.closeSubpath()

        let node = SKShapeNode(path: path)
        node.fillColor = wallColor.withAlphaComponent(0.90)
        node.strokeColor = UIColor.white.withAlphaComponent(0.2)
        node.lineWidth = 0.5
        node.position = basePos
        node.zPosition = CGFloat(row * cols) - 0.5
        return node
    }

    private func makeWallBack(col: Int, row: Int) -> SKShapeNode {
        let basePos = isoPosition(col: col, row: row)

        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: tileH / 2))
        path.addLine(to: CGPoint(x: tileW / 2, y: 0))
        path.addLine(to: CGPoint(x: tileW / 2, y: wallHeight))
        path.addLine(to: CGPoint(x: 0, y: tileH / 2 + wallHeight))
        path.closeSubpath()

        let node = SKShapeNode(path: path)
        node.fillColor = wallColor.withAlphaComponent(0.78)
        node.strokeColor = UIColor.white.withAlphaComponent(0.2)
        node.lineWidth = 0.5
        node.position = basePos
        node.zPosition = CGFloat(col) - 0.5
        return node
    }

    private func addAmbientDecor() {
        let decorAnchor = decorAnchorTile()
        let centerPos = isoPosition(col: decorAnchor.col, row: decorAnchor.row)

        let rugWidth = tileW * min(CGFloat(cols) * 0.42, 4.6)
        let rugHeight = tileH * min(CGFloat(rows) * 0.72, 4.2)
        let rug = SKShapeNode(path: roundedDiamondPath(width: rugWidth, height: rugHeight, cornerRadius: 18))
        rug.fillColor = UIColor(red: 0.92, green: 0.88, blue: 1.0, alpha: 0.95)
        rug.strokeColor = UIColor.white.withAlphaComponent(0.35)
        rug.lineWidth = 1
        rug.position = CGPoint(x: centerPos.x, y: centerPos.y - 6)
        rug.zPosition = 120
        decorLayer.addChild(rug)

        let glow = SKShapeNode(ellipseOf: CGSize(width: tileW * 2.8, height: tileH * 1.2))
        glow.fillColor = UIColor.white.withAlphaComponent(0.12)
        glow.strokeColor = .clear
        glow.position = CGPoint(x: centerPos.x + tileW * 0.75, y: centerPos.y + wallHeight * 0.9)
        glow.zPosition = 180
        decorLayer.addChild(glow)

        let sparkleSpan = max(CGFloat(cols), CGFloat(rows)) * 0.18
        let sparkles = [
            CGPoint(x: -tileW * (1.2 + sparkleSpan), y: wallHeight * 1.1),
            CGPoint(x: tileW * (1.1 + sparkleSpan), y: wallHeight * 1.0),
            CGPoint(x: tileW * 1.15, y: wallHeight * 1.35)
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

    private func roundedDiamondPath(width: CGFloat, height: CGFloat, cornerRadius: CGFloat) -> CGPath {
        let halfW = width / 2
        let halfH = height / 2
        let radius = min(cornerRadius, min(halfW, halfH) * 0.45)

        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: halfH))
        path.addQuadCurve(to: CGPoint(x: halfW, y: 0), controlPoint: CGPoint(x: radius, y: halfH - radius))
        path.addQuadCurve(to: CGPoint(x: 0, y: -halfH), controlPoint: CGPoint(x: halfW - radius, y: -radius))
        path.addQuadCurve(to: CGPoint(x: -halfW, y: 0), controlPoint: CGPoint(x: -radius, y: -halfH + radius))
        path.addQuadCurve(to: CGPoint(x: 0, y: halfH), controlPoint: CGPoint(x: -halfW + radius, y: radius))
        path.close()
        return path.cgPath
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

        // Posizione centrale nella stanza
        let anchor = petAnchorTile()
        let centerPos = isoPosition(col: anchor.col, row: anchor.row)
        pet.position = CGPoint(x: centerPos.x, y: centerPos.y + tileH * 1.18)
        pet.zPosition = 500

        shadow.position = CGPoint(x: centerPos.x, y: centerPos.y + tileH * 0.05)
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
        let anchor = petAnchorTile()
        let centerPos = isoPosition(col: anchor.col, row: anchor.row)
        let newSize = petBodySize(for: petStage)

        guard let petNode, let petShadowNode else {
            addPet()
            return
        }

        let previousPosition = petNode.position
        petNode.removeAllActions()
        petNode.setStage(petStage)
        petNode.setMood(mood)
        petNode.position = CGPoint(x: centerPos.x, y: centerPos.y + tileH * 1.18)
        petNode.setScale(min(newSize.width / 92, newSize.height / 82))

        petShadowNode.path = CGPath(ellipseIn: CGRect(
            x: -newSize.width / 2,
            y: -(tileH * 0.32) / 2,
            width: newSize.width,
            height: tileH * 0.32
        ), transform: nil)
        petShadowNode.position = CGPoint(x: centerPos.x, y: centerPos.y + tileH * 0.05)

        guard animated else { return }
        petNode.position = previousPosition
        petNode.run(.repeatForever(.sequence([
            .moveBy(x: 0, y: 5, duration: 0.95),
            .moveBy(x: 0, y: -5, duration: 0.95)
        ])))
        petNode.run(.move(to: CGPoint(x: centerPos.x, y: centerPos.y + tileH * 1.18), duration: 0.2))
        runEvolutionCelebration()
    }

    private func petBodySize(for stage: Int) -> CGSize {
        let stageScale = 1.0 + CGFloat(min(stage, 4)) * 0.12
        return CGSize(width: tileW * 0.98 * stageScale, height: tileH * 1.95 * stageScale)
    }

    private func squareTileCoordinates() -> Set<TileCoordinate> {
        Set((0..<rows).flatMap { row in
            (0..<cols).map { col in
                TileCoordinate(col: col, row: row)
            }
        })
    }

    private func containsTile(col: Int, row: Int) -> Bool {
        activeTiles.contains(TileCoordinate(col: col, row: row))
    }

    private func petAnchorTile() -> TileCoordinate {
        let preferred = TileCoordinate(col: petCol, row: petRow)
        if activeTiles.contains(preferred) {
            return preferred
        }

        return activeTiles
            .min { lhs, rhs in
                let lhsDistance = abs(lhs.col - centerCol) + abs(lhs.row - petRow)
                let rhsDistance = abs(rhs.col - centerCol) + abs(rhs.row - petRow)
                if lhsDistance == rhsDistance {
                    return lhs.row < rhs.row
                }
                return lhsDistance < rhsDistance
            } ?? TileCoordinate(col: centerCol, row: centerRow)
    }

    private func decorAnchorTile() -> TileCoordinate {
        let preferred = TileCoordinate(col: centerCol, row: max(centerRow - 1, 1))
        if activeTiles.contains(preferred) {
            return preferred
        }

        return activeTiles
            .sorted { lhs, rhs in
                if lhs.row == rhs.row {
                    return lhs.col < rhs.col
                }
                return lhs.row < rhs.row
            }
            .dropFirst(activeTiles.count / 2)
            .first ?? petAnchorTile()
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
}
