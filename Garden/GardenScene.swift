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

    // MARK: - Costanti isometriche
    private let grid = IsoGrid(tileW: 72)
    private let gridCols = 7
    private let gridRows = 5

    // MARK: - Nodi
    private let isoRoot  = SKNode()   // radice di tutto il mondo iso
    let petNode  = PetNode()          // internal: il cambio colore viene applicato da fuori
    private var weather: SKEmitterNode?

    /// Callback chiamata quando l'utente tocca il pet
    var onPetTapped: (() -> Void)?

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
        let originY = size.height * 0.18

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
        } else {
            petNode.bounce()
        }
    }

    /// Applica il colore base al pet con animazione fluida.
    func applyPetColor(_ color: PetColor, animated: Bool = true) {
        petNode.setColor(color, animated: animated)
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
        tile.strokeColor = UIColor(red: 0.55, green: 0.85, blue: 0.55, alpha: 0.35)
        tile.lineWidth   = 0.8
        // zPosition: i tile più in basso (row+col alto) sono davanti
        tile.zPosition   = CGFloat(col + row)
        tile.name        = "tile_\(col)_\(row)"
        return tile
    }

    private func tileColor(col: Int, row: Int) -> UIColor {
        // Alternanza chiaro/scuro per effetto scacchiera isometrica
        let isLight = (col + row) % 2 == 0
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
        // Cespuglio (col:5, row:1)
        addIsoBush(col: 5, row: 1, originX: originX, originY: originY)
        // Fiori sparsi
        let flowerPositions: [(col: Int, row: Int)] = [(2,3),(3,2),(4,3),(1,3),(5,2)]
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
        }
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
        }
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
