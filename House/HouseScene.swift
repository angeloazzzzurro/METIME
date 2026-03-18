import SpriteKit
import Foundation

// MARK: - HouseScene

final class HouseScene: SKScene {

    // MARK: Config
    private let tileW: CGFloat = 80
    private let tileH: CGFloat = 40
    private let cols = 7
    private let rows = 5

    // MARK: Nodes
    private var floorLayer = SKNode()
    private var wallLayer  = SKNode()
    private var itemLayer  = SKNode()
    private var petNode: SKShapeNode?

    // MARK: State
    var mood: PetMood = .calm { didSet { updateMoodColors() } }
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
        anchorPoint = CGPoint(x: 0.5, y: 0.3)

        addChild(floorLayer)
        addChild(wallLayer)
        addChild(itemLayer)

        buildRoom()
        addPet()
    }

    // MARK: - Room Construction

    private func buildRoom() {
        floorLayer.removeAllChildren()
        wallLayer.removeAllChildren()

        // Pavimento isometrico
        for row in 0..<rows {
            for col in 0..<cols {
                let tile = makeTile(col: col, row: row)
                floorLayer.addChild(tile)
            }
        }

        // Parete sinistra (colonna 0, estesa verso l'alto)
        for row in 0..<rows {
            let wall = makeWallLeft(row: row)
            wallLayer.addChild(wall)
        }

        // Parete posteriore (riga 0, estesa verso l'alto)
        for col in 0..<cols {
            let wall = makeWallBack(col: col)
            wallLayer.addChild(wall)
        }

        // Finestra sulla parete posteriore
        addWindow()
    }

    private func makeTile(col: Int, row: Int) -> SKShapeNode {
        let pos = isoPosition(col: col, row: row)
        let path = isoTilePath()
        let node = SKShapeNode(path: path)

        let brightness: CGFloat = 1.0 - CGFloat(col + row) * 0.015
        node.fillColor = floorColor.withAlphaComponent(brightness)
        node.strokeColor = UIColor.white.withAlphaComponent(0.3)
        node.lineWidth = 0.5
        node.position = pos
        node.zPosition = CGFloat(row * cols + col)
        node.name = "tile_\(col)_\(row)"
        return node
    }

    private func makeWallLeft(row: Int) -> SKShapeNode {
        let basePos = isoPosition(col: 0, row: row)
        let wallHeight: CGFloat = 90

        let path = CGMutablePath()
        path.move(to: CGPoint(x: -tileW / 2, y: 0))
        path.addLine(to: CGPoint(x: 0, y: tileH / 2))
        path.addLine(to: CGPoint(x: 0, y: tileH / 2 + wallHeight))
        path.addLine(to: CGPoint(x: -tileW / 2, y: wallHeight))
        path.closeSubpath()

        let node = SKShapeNode(path: path)
        node.fillColor = wallColor.withAlphaComponent(0.85)
        node.strokeColor = UIColor.white.withAlphaComponent(0.2)
        node.lineWidth = 0.5
        node.position = basePos
        node.zPosition = CGFloat(row * cols) - 0.5
        return node
    }

    private func makeWallBack(col: Int) -> SKShapeNode {
        let basePos = isoPosition(col: col, row: 0)
        let wallHeight: CGFloat = 90

        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: tileH / 2))
        path.addLine(to: CGPoint(x: tileW / 2, y: 0))
        path.addLine(to: CGPoint(x: tileW / 2, y: wallHeight))
        path.addLine(to: CGPoint(x: 0, y: tileH / 2 + wallHeight))
        path.closeSubpath()

        let node = SKShapeNode(path: path)
        node.fillColor = wallColor.withAlphaComponent(0.70)
        node.strokeColor = UIColor.white.withAlphaComponent(0.2)
        node.lineWidth = 0.5
        node.position = basePos
        node.zPosition = CGFloat(col) - 0.5
        return node
    }

    private func addWindow() {
        // Finestra sulla parete posteriore centrale
        let windowPos = isoPosition(col: 3, row: 0)
        let windowNode = SKShapeNode(rectOf: CGSize(width: 36, height: 28), cornerRadius: 4)
        windowNode.fillColor = UIColor(red: 0.7, green: 0.9, blue: 1.0, alpha: 0.6)
        windowNode.strokeColor = UIColor.white.withAlphaComponent(0.5)
        windowNode.lineWidth = 1.5
        windowNode.position = CGPoint(x: windowPos.x + tileW * 0.25, y: windowPos.y + 70)
        windowNode.zPosition = 200

        // Croce della finestra
        let hBar = SKShapeNode(rectOf: CGSize(width: 36, height: 1.5))
        hBar.fillColor = UIColor.white.withAlphaComponent(0.5)
        hBar.strokeColor = .clear
        let vBar = SKShapeNode(rectOf: CGSize(width: 1.5, height: 28))
        vBar.fillColor = UIColor.white.withAlphaComponent(0.5)
        vBar.strokeColor = .clear
        windowNode.addChild(hBar)
        windowNode.addChild(vBar)

        // Luce solare che filtra
        let light = SKShapeNode(ellipseOf: CGSize(width: 60, height: 20))
        light.fillColor = UIColor(red: 1.0, green: 0.95, blue: 0.7, alpha: 0.15)
        light.strokeColor = .clear
        light.position = CGPoint(x: windowPos.x + tileW * 0.25, y: windowPos.y + 30)
        light.zPosition = 199

        wallLayer.addChild(windowNode)
        wallLayer.addChild(light)
    }

    // MARK: - Pet

    private func addPet() {
        let pet = SKShapeNode(ellipseOf: CGSize(width: 52, height: 40))
        pet.fillColor = UIColor(red: 0.85, green: 0.75, blue: 1.0, alpha: 1)
        pet.strokeColor = UIColor.white.withAlphaComponent(0.4)
        pet.lineWidth = 1.5

        // Occhi
        let leftEye = SKShapeNode(circleOfRadius: 4)
        leftEye.fillColor = UIColor(red: 0.2, green: 0.1, blue: 0.3, alpha: 1)
        leftEye.strokeColor = .clear
        leftEye.position = CGPoint(x: -10, y: 6)
        let rightEye = SKShapeNode(circleOfRadius: 4)
        rightEye.fillColor = UIColor(red: 0.2, green: 0.1, blue: 0.3, alpha: 1)
        rightEye.strokeColor = .clear
        rightEye.position = CGPoint(x: 10, y: 6)

        // Guancette
        let leftCheek = SKShapeNode(ellipseOf: CGSize(width: 12, height: 7))
        leftCheek.fillColor = UIColor(red: 1.0, green: 0.6, blue: 0.7, alpha: 0.6)
        leftCheek.strokeColor = .clear
        leftCheek.position = CGPoint(x: -16, y: -1)
        let rightCheek = SKShapeNode(ellipseOf: CGSize(width: 12, height: 7))
        rightCheek.fillColor = UIColor(red: 1.0, green: 0.6, blue: 0.7, alpha: 0.6)
        rightCheek.strokeColor = .clear
        rightCheek.position = CGPoint(x: 16, y: -1)

        // Ombra
        let shadow = SKShapeNode(ellipseOf: CGSize(width: 52, height: 12))
        shadow.fillColor = UIColor(red: 0.5, green: 0.4, blue: 0.7, alpha: 0.25)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 0, y: -28)

        pet.addChild(leftEye)
        pet.addChild(rightEye)
        pet.addChild(leftCheek)
        pet.addChild(rightCheek)

        // Posizione centrale nella stanza
        let centerPos = isoPosition(col: 3, row: 3)
        pet.position = CGPoint(x: centerPos.x, y: centerPos.y + 30)
        pet.zPosition = 500

        shadow.position = CGPoint(x: centerPos.x, y: centerPos.y + 2)
        shadow.zPosition = 499

        // Animazione idle
        let bob = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 4, duration: 0.9),
            SKAction.moveBy(x: 0, y: -4, duration: 0.9)
        ])
        pet.run(SKAction.repeatForever(bob))

        addChild(shadow)
        addChild(pet)
        petNode = pet
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
}
