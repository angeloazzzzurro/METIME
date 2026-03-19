import SpriteKit

// MARK: - Isometric helpers
//
// Proiezione isometrica classica a 45°:
//   screen.x = (tile.col - tile.row) * (tileW / 2)
//   screen.y = (tile.col + tile.row) * (tileH / 2)
// dove tileH = tileW / 2  (rapporto 2:1 tipico dell'iso a 45°)

private struct IsoGrid {
    let tileW: CGFloat
    var tileH: CGFloat { tileW / 2 }

    /// Converte coordinate griglia (col, row) in coordinate schermo SpriteKit.
    func screenPoint(col: CGFloat, row: CGFloat, originX: CGFloat, originY: CGFloat) -> CGPoint {
        let sx = originX + (col - row) * (tileW / 2)
        let sy = originY + (col + row) * (tileH / 2)
        return CGPoint(x: sx, y: sy)
    }
}

// MARK: - GardenScene

final class GardenScene: SKScene {
    private let keyLightColor = UIColor(red: 1.00, green: 0.98, blue: 0.86, alpha: 1)
    private let isoShadowColor = UIColor(red: 0.12, green: 0.22, blue: 0.10, alpha: 1)

    // MARK: - Costanti isometriche
    private let grid = IsoGrid(tileW: 72)
    private let gridCols = 9
    private let gridRows = 7

    // MARK: - Nodi
    private let isoRoot  = SKNode()   // radice di tutto il mondo iso
    let petNode  = PetNode()          // internal: il cambio colore viene applicato da fuori
    private var weather: SKEmitterNode?

    /// Callback chiamata quando l'utente tocca il pet
    var onPetTapped: (() -> Void)?

    private enum CropState {
        case empty
        case tilled
        case sprout
        case grown
    }

    private var cropStates: [String: CropState] = [:]
    private var cropNodes: [String: SKNode] = [:]

    // MARK: - Mood
    var mood: PetMood = .calm {
        didSet {
            petNode.setMood(mood)
            updateWeather()
            updateTileColors()
        }
    }

    // MARK: - Lifecycle

    override func didMove(to view: SKView) {
        backgroundColor = .clear

        // Origine della griglia isometrica: centro-basso della scena
        let originX = size.width  / 2
        let originY = size.height * 0.12

        isoRoot.position = .zero
        addChild(isoRoot)

        buildGround(originX: originX, originY: originY)
        buildDecorations(originX: originX, originY: originY)
        placePet(originX: originX, originY: originY)

        // Particelle ambientali leggere
        let ambient = ParticleFactory.ambient(size: size)
        ambient.position = CGPoint(x: size.width / 2, y: size.height)
        addChild(ambient)

        updateWeather()
    }

    // MARK: - Touch

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let loc = touch.location(in: isoRoot)
        // Se il tocco è vicino al pet (raggio 60pt) cicla il colore, altrimenti bounce
        let petPos = petNode.position
        let dist = hypot(loc.x - petPos.x, loc.y - petPos.y)
        if dist < 60 {
            onPetTapped?()
        } else if let tile = tiles.first(where: { $0.contains(loc) }),
                  let tileName = tile.name,
                  isCultivableTile(colRowKey: tileName.replacingOccurrences(of: "tile_", with: "")) {
            cultivateTile(named: tileName)
        } else {
            petNode.bounce()
        }
    }

    /// Applica il colore base al pet con animazione fluida.
    func applyPetColor(_ color: PetColor, animated: Bool = true) {
        petNode.setColor(color, animated: animated)
    }

    func waterCrops() {
        for key in cropStates.keys {
            advanceCropGrowth(for: key)
        }
    }

    // MARK: - Ground (tile isometrici)

    private var tiles: [SKShapeNode] = []

    private func buildGround(originX: CGFloat, originY: CGFloat) {
        for row in 0..<gridRows {
            for col in 0..<gridCols {
                let tile = makeTile(col: col, row: row,
                                    originX: originX, originY: originY)
                isoRoot.addChild(tile)
                tiles.append(tile)
            }
        }
    }

    private func makeTile(col: Int, row: Int,
                          originX: CGFloat, originY: CGFloat) -> SKShapeNode {
        let center = grid.screenPoint(col: CGFloat(col), row: CGFloat(row),
                                      originX: originX, originY: originY)
        let hw = grid.tileW / 2   // half-width
        let hh = grid.tileH / 2   // half-height

        // Rombo isometrico (4 vertici)
        let path = CGMutablePath()
        path.move(to:    CGPoint(x: center.x,      y: center.y + hh))  // top
        path.addLine(to: CGPoint(x: center.x + hw, y: center.y))       // right
        path.addLine(to: CGPoint(x: center.x,      y: center.y - hh))  // bottom
        path.addLine(to: CGPoint(x: center.x - hw, y: center.y))       // left
        path.closeSubpath()

        let tile = SKShapeNode(path: path)
        tile.fillColor   = tileColor(col: col, row: row)
        let key = cropKey(col: col, row: row)
        tile.strokeColor = isCultivableTile(colRowKey: key)
            ? UIColor(red: 0.67, green: 0.50, blue: 0.28, alpha: 0.55)
            : UIColor(red: 0.55, green: 0.85, blue: 0.55, alpha: 0.35)
        tile.lineWidth   = 0.8
        // zPosition: i tile più in basso (row+col alto) sono davanti
        tile.zPosition   = CGFloat(col + row)
        tile.name        = "tile_\(col)_\(row)"
        addTileBevel(to: tile, center: center, hw: hw, hh: hh)
        if isCultivableTile(colRowKey: key) {
            addCultivableHighlight(to: tile)
            cropStates[key] = cropStates[key] ?? .empty
        }
        return tile
    }

    private func tileColor(col: Int, row: Int) -> UIColor {
        // Alternanza chiaro/scuro per effetto scacchiera isometrica
        let isLight = (col + row) % 2 == 0
        if isCultivableTile(colRowKey: cropKey(col: col, row: row)) {
            return isLight
                ? UIColor(red: 0.76, green: 0.62, blue: 0.42, alpha: 0.92)
                : UIColor(red: 0.68, green: 0.53, blue: 0.34, alpha: 0.92)
        }
        switch mood {
        case .calm, .sleepy:
            return isLight
                ? UIColor(red: 0.72, green: 0.94, blue: 0.72, alpha: 0.90)
                : UIColor(red: 0.65, green: 0.88, blue: 0.65, alpha: 0.90)
        case .happy, .evolving:
            return isLight
                ? UIColor(red: 0.80, green: 0.96, blue: 0.70, alpha: 0.90)
                : UIColor(red: 0.72, green: 0.90, blue: 0.62, alpha: 0.90)
        case .anxious, .sick:
            return isLight
                ? UIColor(red: 0.78, green: 0.90, blue: 0.78, alpha: 0.85)
                : UIColor(red: 0.70, green: 0.84, blue: 0.70, alpha: 0.85)
        }
    }

    private func updateTileColors() {
        for tile in tiles {
            guard let name = tile.name,
                  let parts = name.split(separator: "_").map({ Int($0) }) as? [Int?],
                  parts.count == 3,
                  let col = parts[1], let row = parts[2] else { continue }
            let action = SKAction.customAction(withDuration: 0.4) { [weak self] node, _ in
                guard let self, let t = node as? SKShapeNode else { return }
                t.fillColor = self.tileColor(col: col, row: row)
            }
            tile.run(action)
        }
    }

    // MARK: - Decorazioni isometriche

    private func buildDecorations(originX: CGFloat, originY: CGFloat) {
        // Albero isometrico (col:1, row:1)
        addIsoTree(col: 1, row: 1, originX: originX, originY: originY)
        // Albero aggiuntivo per dare più profondità al giardino espanso
        addIsoTree(col: 7, row: 1, originX: originX, originY: originY)
        // Cespugli laterali
        addIsoBush(col: 1, row: 5, originX: originX, originY: originY)
        addIsoBush(col: 7, row: 5, originX: originX, originY: originY)
        addBedNode(col: 7, row: 3, originX: originX, originY: originY)
        // Fiori sparsi
        let flowerPositions: [(col: Int, row: Int)] = [(1,2), (2,1), (7,2), (8,3), (1,6), (8,6)]
        for pos in flowerPositions {
            addIsoFlower(col: pos.col, row: pos.row,
                         originX: originX, originY: originY)
        }
        // Ombra del sole (luce dall'alto-destra)
        addGroundShadow(originX: originX, originY: originY)
    }

    // MARK: - Albero isometrico

    private func addIsoTree(col: Int, row: Int, originX: CGFloat, originY: CGFloat) {
        let base = grid.screenPoint(col: CGFloat(col), row: CGFloat(row),
                                    originX: originX, originY: originY)
        let z = CGFloat(col + row + 1)

        // Tronco (rettangolo isometrico stretto)
        let trunk = SKShapeNode(rectOf: CGSize(width: 8, height: 22), cornerRadius: 3)
        trunk.fillColor   = UIColor(red: 0.65, green: 0.45, blue: 0.28, alpha: 1)
        trunk.strokeColor = .clear
        trunk.position    = CGPoint(x: base.x, y: base.y + 16)
        trunk.zPosition   = z
        isoRoot.addChild(trunk)
        addGloss(to: trunk, size: CGSize(width: 3, height: 18), offset: CGPoint(x: -2, y: 0), alpha: 0.18)

        // Chioma: tre cerchi sovrapposti per effetto volume
        let crownColors: [UIColor] = [
            UIColor(red: 0.45, green: 0.82, blue: 0.45, alpha: 0.95),
            UIColor(red: 0.55, green: 0.90, blue: 0.50, alpha: 0.90),
            UIColor(red: 0.65, green: 0.95, blue: 0.55, alpha: 0.85),
        ]
        let crownOffsets: [(CGFloat, CGFloat, CGFloat)] = [
            (0, 44, 22), (-12, 38, 18), (12, 38, 18)
        ]
        for (i, (dx, dy, r)) in crownOffsets.enumerated() {
            let crown = SKShapeNode(circleOfRadius: r)
            crown.fillColor   = crownColors[i]
            crown.strokeColor = UIColor(red: 0.35, green: 0.70, blue: 0.35, alpha: 0.4)
            crown.lineWidth   = 1
            crown.position    = CGPoint(x: base.x + dx, y: base.y + dy)
            crown.zPosition   = z + CGFloat(i) * 0.1
            isoRoot.addChild(crown)
            addGloss(to: crown, size: CGSize(width: r * 1.2, height: r * 0.8),
                     offset: CGPoint(x: -r * 0.25, y: r * 0.25), alpha: 0.10)
        }

        addShadow(at: CGPoint(x: base.x + 6, y: base.y + 2), size: CGSize(width: 44, height: 16), zPosition: z - 0.1, alpha: 0.16)
    }

    // MARK: - Cespuglio isometrico

    private func addIsoBush(col: Int, row: Int, originX: CGFloat, originY: CGFloat) {
        let base = grid.screenPoint(col: CGFloat(col), row: CGFloat(row),
                                    originX: originX, originY: originY)
        let z = CGFloat(col + row + 1)

        let offsets: [(CGFloat, CGFloat, CGFloat)] = [
            (0, 14, 14), (-10, 10, 11), (10, 10, 11)
        ]
        for (dx, dy, r) in offsets {
            let bush = SKShapeNode(circleOfRadius: r)
            bush.fillColor   = UIColor(red: 0.50, green: 0.88, blue: 0.50, alpha: 0.92)
            bush.strokeColor = UIColor(red: 0.35, green: 0.70, blue: 0.35, alpha: 0.5)
            bush.lineWidth   = 1
            bush.position    = CGPoint(x: base.x + dx, y: base.y + dy)
            bush.zPosition   = z
            isoRoot.addChild(bush)
            addGloss(to: bush, size: CGSize(width: r * 1.1, height: r * 0.75),
                     offset: CGPoint(x: -r * 0.2, y: r * 0.2), alpha: 0.10)
        }
        addShadow(at: CGPoint(x: base.x + 5, y: base.y + 1), size: CGSize(width: 34, height: 12), zPosition: z - 0.1, alpha: 0.14)
    }

    // MARK: - Fiore isometrico

    private func addIsoFlower(col: Int, row: Int, originX: CGFloat, originY: CGFloat) {
        let base = grid.screenPoint(col: CGFloat(col), row: CGFloat(row),
                                    originX: originX, originY: originY)
        let z = CGFloat(col + row + 1)

        let petalColors: [UIColor] = [
            UIColor(red: 1.0, green: 0.60, blue: 0.75, alpha: 0.95),
            UIColor(red: 1.0, green: 0.90, blue: 0.40, alpha: 0.95),
            UIColor(red: 0.80, green: 0.60, blue: 1.00, alpha: 0.95),
            UIColor(red: 1.0, green: 0.70, blue: 0.40, alpha: 0.95),
            UIColor(red: 0.60, green: 0.90, blue: 1.00, alpha: 0.95),
        ]
        let color = petalColors[(col * 3 + row) % petalColors.count]

        // Gambo
        let stem = SKShapeNode()
        let stemPath = CGMutablePath()
        stemPath.move(to:    CGPoint(x: base.x, y: base.y))
        stemPath.addLine(to: CGPoint(x: base.x, y: base.y + 12))
        stem.path        = stemPath
        stem.strokeColor = UIColor(red: 0.40, green: 0.75, blue: 0.40, alpha: 0.9)
        stem.lineWidth   = 1.5
        stem.zPosition   = z
        isoRoot.addChild(stem)

        // Petali (4 ellissi attorno al centro)
        let petalAngles: [CGFloat] = [0, .pi/2, .pi, .pi * 3/2]
        for angle in petalAngles {
            let petal = SKShapeNode(ellipseOf: CGSize(width: 7, height: 4))
            petal.fillColor   = color
            petal.strokeColor = .clear
            petal.zRotation   = angle
            petal.position    = CGPoint(
                x: base.x + cos(angle) * 5,
                y: base.y + 14 + sin(angle) * 3
            )
            petal.zPosition   = z + 0.1
            isoRoot.addChild(petal)
        }

        // Centro del fiore
        let center = SKShapeNode(circleOfRadius: 3.5)
        center.fillColor   = UIColor(red: 1.0, green: 0.95, blue: 0.60, alpha: 1)
        center.strokeColor = .clear
        center.position    = CGPoint(x: base.x, y: base.y + 14)
        center.zPosition   = z + 0.2
        isoRoot.addChild(center)
    }

    // MARK: - Ombra al suolo

    private func addGroundShadow(originX: CGFloat, originY: CGFloat) {
        // Ellisse piatta sotto il pet per simulare ombra proiettata
        let petBase = grid.screenPoint(col: CGFloat(gridCols) / 2,
                                       row: CGFloat(gridRows) / 2,
                                       originX: originX, originY: originY)
        let shadow = SKShapeNode(ellipseOf: CGSize(width: 60, height: 22))
        shadow.fillColor   = UIColor(red: 0.30, green: 0.50, blue: 0.30, alpha: 0.18)
        shadow.strokeColor = .clear
        shadow.position    = CGPoint(x: petBase.x + 6, y: petBase.y - 4)
        shadow.zPosition   = CGFloat(gridCols + gridRows) - 0.5
        isoRoot.addChild(shadow)
    }

    private func addBedNode(col: Int, row: Int, originX: CGFloat, originY: CGFloat) {
        let base = grid.screenPoint(col: CGFloat(col), row: CGFloat(row), originX: originX, originY: originY)
        let bed = BedNode()
        bed.setScale(0.72)
        bed.position = CGPoint(x: base.x + 4, y: base.y + BedNode.groundOffset * 0.72 - 8)
        bed.zPosition = CGFloat(col + row + 3)
        if mood == .sleepy {
            bed.startSleepingZZZ()
        }
        isoRoot.addChild(bed)
    }

    private func addTileBevel(to tile: SKShapeNode, center: CGPoint, hw: CGFloat, hh: CGFloat) {
        let highlightPath = CGMutablePath()
        highlightPath.move(to: CGPoint(x: center.x - hw, y: center.y))
        highlightPath.addLine(to: CGPoint(x: center.x, y: center.y + hh))
        highlightPath.addLine(to: CGPoint(x: center.x + hw, y: center.y))

        let highlight = SKShapeNode(path: highlightPath)
        highlight.strokeColor = keyLightColor.withAlphaComponent(0.34)
        highlight.lineWidth = 1.4
        highlight.lineCap = .round
        highlight.zPosition = tile.zPosition + 0.02
        isoRoot.addChild(highlight)

        let shadePath = CGMutablePath()
        shadePath.move(to: CGPoint(x: center.x + hw, y: center.y))
        shadePath.addLine(to: CGPoint(x: center.x, y: center.y - hh))
        shadePath.addLine(to: CGPoint(x: center.x - hw, y: center.y))

        let shade = SKShapeNode(path: shadePath)
        shade.strokeColor = isoShadowColor.withAlphaComponent(0.16)
        shade.lineWidth = 1.6
        shade.lineCap = .round
        shade.zPosition = tile.zPosition + 0.01
        isoRoot.addChild(shade)
    }

    private func addGloss(to node: SKShapeNode, size: CGSize, offset: CGPoint, alpha: CGFloat) {
        let gloss = SKShapeNode(ellipseOf: size)
        gloss.fillColor = keyLightColor.withAlphaComponent(alpha)
        gloss.strokeColor = .clear
        gloss.position = offset
        gloss.zPosition = 0.1
        node.addChild(gloss)
    }

    private func addShadow(at position: CGPoint, size: CGSize, zPosition: CGFloat, alpha: CGFloat) {
        let shadow = SKShapeNode(ellipseOf: size)
        shadow.fillColor = isoShadowColor.withAlphaComponent(alpha)
        shadow.strokeColor = .clear
        shadow.position = position
        shadow.zPosition = zPosition
        isoRoot.addChild(shadow)
    }

    private func addCultivableHighlight(to tile: SKShapeNode) {
        let accent = SKShapeNode(path: tile.path!)
        accent.fillColor = .clear
        accent.strokeColor = UIColor.white.withAlphaComponent(0.10)
        accent.lineWidth = 1
        accent.zPosition = tile.zPosition + 0.03
        isoRoot.addChild(accent)
    }

    private func cultivateTile(named tileName: String) {
        let key = tileName.replacingOccurrences(of: "tile_", with: "")
        let nextState: CropState
        switch cropStates[key, default: .empty] {
        case .empty:
            nextState = .tilled
        case .tilled:
            nextState = .sprout
        case .sprout:
            nextState = .grown
        case .grown:
            nextState = .empty
        }
        cropStates[key] = nextState
        updateCropNode(for: key, state: nextState)
    }

    private func advanceCropGrowth(for key: String) {
        let current = cropStates[key, default: .empty]
        let nextState: CropState
        switch current {
        case .empty:
            nextState = .empty
        case .tilled:
            nextState = .sprout
        case .sprout:
            nextState = .grown
        case .grown:
            nextState = .grown
        }
        cropStates[key] = nextState
        updateCropNode(for: key, state: nextState)
    }

    private func updateCropNode(for key: String, state: CropState) {
        cropNodes[key]?.removeFromParent()
        cropNodes[key] = nil

        let parts = key.split(separator: "_")
        guard parts.count == 2,
              let col = Int(parts[0]),
              let row = Int(parts[1]) else { return }

        let base = grid.screenPoint(col: CGFloat(col), row: CGFloat(row), originX: size.width / 2, originY: size.height * 0.12)
        let z = CGFloat(col + row) + 0.4

        let node: SKNode
        switch state {
        case .empty:
            return
        case .tilled:
            let soil = SKShapeNode(ellipseOf: CGSize(width: 30, height: 12))
            soil.fillColor = UIColor(red: 0.47, green: 0.32, blue: 0.18, alpha: 0.95)
            soil.strokeColor = UIColor(red: 0.62, green: 0.45, blue: 0.26, alpha: 0.7)
            soil.lineWidth = 1
            node = soil
        case .sprout:
            let sprout = SKNode()
            let soil = SKShapeNode(ellipseOf: CGSize(width: 30, height: 12))
            soil.fillColor = UIColor(red: 0.47, green: 0.32, blue: 0.18, alpha: 0.95)
            soil.strokeColor = .clear
            sprout.addChild(soil)

            let stem = SKShapeNode(rectOf: CGSize(width: 2, height: 12), cornerRadius: 1)
            stem.fillColor = UIColor(red: 0.34, green: 0.74, blue: 0.32, alpha: 1)
            stem.strokeColor = .clear
            stem.position = CGPoint(x: 0, y: 8)
            sprout.addChild(stem)

            let leafLeft = SKShapeNode(ellipseOf: CGSize(width: 8, height: 5))
            leafLeft.fillColor = UIColor(red: 0.56, green: 0.90, blue: 0.42, alpha: 1)
            leafLeft.strokeColor = .clear
            leafLeft.zRotation = -.pi / 6
            leafLeft.position = CGPoint(x: -4, y: 13)
            sprout.addChild(leafLeft)

            let leafRight = SKShapeNode(ellipseOf: CGSize(width: 8, height: 5))
            leafRight.fillColor = UIColor(red: 0.56, green: 0.90, blue: 0.42, alpha: 1)
            leafRight.strokeColor = .clear
            leafRight.zRotation = .pi / 6
            leafRight.position = CGPoint(x: 4, y: 13)
            sprout.addChild(leafRight)
            node = sprout
        case .grown:
            let grown = SKNode()
            let soil = SKShapeNode(ellipseOf: CGSize(width: 30, height: 12))
            soil.fillColor = UIColor(red: 0.47, green: 0.32, blue: 0.18, alpha: 0.95)
            soil.strokeColor = .clear
            grown.addChild(soil)

            let stem = SKShapeNode(rectOf: CGSize(width: 3, height: 18), cornerRadius: 1.5)
            stem.fillColor = UIColor(red: 0.31, green: 0.67, blue: 0.28, alpha: 1)
            stem.strokeColor = .clear
            stem.position = CGPoint(x: 0, y: 12)
            grown.addChild(stem)

            let blossom = SKShapeNode(circleOfRadius: 8)
            blossom.fillColor = UIColor(red: 1.0, green: 0.80, blue: 0.32, alpha: 1)
            blossom.strokeColor = UIColor(red: 1.0, green: 0.92, blue: 0.60, alpha: 0.7)
            blossom.lineWidth = 1
            blossom.position = CGPoint(x: 0, y: 22)
            grown.addChild(blossom)
            node = grown
        }

        node.position = CGPoint(x: base.x, y: base.y + 2)
        node.zPosition = z
        cropNodes[key] = node
        isoRoot.addChild(node)

        node.run(.sequence([
            .scale(to: 1.08, duration: 0.10),
            .scale(to: 1.0, duration: 0.14)
        ]))
    }

    private func cropKey(col: Int, row: Int) -> String {
        "\(col)_\(row)"
    }

    private func isCultivableTile(colRowKey: String) -> Bool {
        let parts = colRowKey.split(separator: "_")
        guard parts.count == 2,
              let col = Int(parts[0]),
              let row = Int(parts[1]) else { return false }
        return (2...6).contains(col) && (3...5).contains(row)
    }

    // MARK: - Pet

    private func placePet(originX: CGFloat, originY: CGFloat) {
        // Il pet è posizionato al centro della griglia, sopra i tile
        let petBase = grid.screenPoint(col: CGFloat(gridCols) / 2,
                                       row: CGFloat(gridRows) / 2,
                                       originX: originX, originY: originY)
        // Schiacciamento isometrico: scaleY = 0.75 simula la prospettiva dall'alto
        petNode.xScale    = 1.0
        petNode.yScale    = 0.75
        petNode.position  = CGPoint(x: petBase.x, y: petBase.y + 30)
        petNode.zPosition = CGFloat(gridCols + gridRows)
        isoRoot.addChild(petNode)
    }

    // MARK: - Weather

    private func updateWeather() {
        weather?.removeFromParent()
        weather = nil

        switch mood {
        case .anxious, .sick:
            let rain = ParticleFactory.rain(size: size)
            rain.position = CGPoint(x: size.width / 2, y: size.height)
            addChild(rain)
            weather = rain
        case .happy, .evolving:
            let sparkle = ParticleFactory.sparkle(size: size)
            sparkle.position = CGPoint(x: size.width / 2, y: size.height * 0.65)
            addChild(sparkle)
            weather = sparkle
        default:
            break
        }
    }
}
