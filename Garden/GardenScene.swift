import SpriteKit

final class GardenScene: SKScene {
    private let worldLayer = SKNode()
    private let groundLayer = SKNode()
    private let plotLayer = SKNode()
    private let decorLayer = SKNode()
    private let petShadow = SKShapeNode(ellipseOf: CGSize(width: 84, height: 26))
    let petNode = PetNode()

    private var weather: SKEmitterNode?
    private var hasBuiltScene = false
    private var movementVector: CGVector = .zero
    private var lastMovementUpdateTime: TimeInterval?
    private let movementSpeed: CGFloat = 138
    private var currentBoardFrame: CGRect = .zero

    var onPetTapped: (() -> Void)?

    var mood: PetMood = .calm {
        didSet {
            petNode.setMood(mood)
            rebuildGarden()
            updateWeather()
        }
    }

    var unlockedPlotCount: Int = 3 {
        didSet {
            guard unlockedPlotCount != oldValue else { return }
            rebuildGarden()
        }
    }

    var terrainExpansionLevel: Int = 0 {
        didSet {
            guard terrainExpansionLevel != oldValue else { return }
            rebuildGarden()
        }
    }

    override func didMove(to view: SKView) {
        backgroundColor = .clear
        addChild(worldLayer)
        worldLayer.addChild(groundLayer)
        worldLayer.addChild(plotLayer)
        worldLayer.addChild(decorLayer)
        worldLayer.addChild(petShadow)
        worldLayer.addChild(petNode)
        rebuildGarden()
        updateWeather()
        hasBuiltScene = true
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        guard hasBuiltScene, oldSize != size else { return }
        rebuildGarden()
        updateWeather()
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

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: worldLayer)
        let petPosition = petNode.position
        if hypot(location.x - petPosition.x, location.y - petPosition.y) < 74 {
            onPetTapped?()
        } else {
            petNode.bounce()
        }
    }

    func applyPetColor(_ color: PetColor, animated: Bool = true) {
        petNode.setColor(color, animated: animated)
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

    private func rebuildGarden() {
        guard size.width > 0, size.height > 0 else { return }

        groundLayer.removeAllChildren()
        plotLayer.removeAllChildren()
        decorLayer.removeAllChildren()

        let centerX = size.width * 0.5
        let widthScale = 0.76 + (CGFloat(terrainExpansionLevel) * 0.07)
        let heightScale = 0.44 + (CGFloat(terrainExpansionLevel) * 0.05)
        let boardWidth = min(size.width * widthScale, 430 + CGFloat(terrainExpansionLevel) * 48)
        let boardHeight = min(size.height * heightScale, 270 + CGFloat(terrainExpansionLevel) * 30)
        let boardCenterY = size.height * (0.44 + CGFloat(terrainExpansionLevel) * 0.012)
        currentBoardFrame = CGRect(
            x: centerX - boardWidth * 0.5,
            y: boardCenterY - boardHeight * 0.5,
            width: boardWidth,
            height: boardHeight
        )

        let grassBoard = SKShapeNode(rectOf: CGSize(width: boardWidth, height: boardHeight), cornerRadius: 34)
        grassBoard.fillColor = lawnColor
        grassBoard.strokeColor = lawnStrokeColor
        grassBoard.lineWidth = 3
        grassBoard.position = CGPoint(x: centerX, y: boardCenterY)
        groundLayer.addChild(grassBoard)

        let boardInner = SKShapeNode(rectOf: CGSize(width: boardWidth - 18, height: boardHeight - 18), cornerRadius: 28)
        boardInner.fillColor = lawnInnerColor
        boardInner.strokeColor = UIColor.white.withAlphaComponent(0.16)
        boardInner.lineWidth = 1
        boardInner.position = CGPoint(x: centerX, y: boardCenterY + 4)
        groundLayer.addChild(boardInner)

        let path = SKShapeNode(
            rectOf: CGSize(width: boardWidth - 42, height: 42 + CGFloat(terrainExpansionLevel) * 4),
            cornerRadius: 21
        )
        path.fillColor = UIColor(red: 0.96, green: 0.89, blue: 0.70, alpha: 0.92)
        path.strokeColor = UIColor(red: 0.85, green: 0.73, blue: 0.53, alpha: 0.9)
        path.lineWidth = 1.4
        path.position = CGPoint(x: centerX, y: boardCenterY - boardHeight * 0.24)
        groundLayer.addChild(path)

        addFence(boardWidth: boardWidth, boardHeight: boardHeight, centerX: centerX, centerY: boardCenterY)
        addCornerDecor(boardWidth: boardWidth, boardHeight: boardHeight, centerX: centerX, centerY: boardCenterY)
        addPlots(boardWidth: boardWidth, boardHeight: boardHeight, centerX: centerX, centerY: boardCenterY)
        placePet(boardWidth: boardWidth, centerX: centerX, centerY: boardCenterY)
    }

    private func addFence(boardWidth: CGFloat, boardHeight: CGFloat, centerX: CGFloat, centerY: CGFloat) {
        let fenceY = centerY + boardHeight * 0.33
        let startX = centerX - boardWidth * 0.42
        let spacing = boardWidth * 0.12

        for index in 0..<8 {
            let post = SKShapeNode(rectOf: CGSize(width: 10, height: 28), cornerRadius: 4)
            post.fillColor = UIColor(red: 0.88, green: 0.79, blue: 0.64, alpha: 1)
            post.strokeColor = UIColor(red: 0.71, green: 0.57, blue: 0.40, alpha: 0.9)
            post.lineWidth = 1
            post.position = CGPoint(x: startX + CGFloat(index) * spacing, y: fenceY)
            decorLayer.addChild(post)
        }

        let rail = SKShapeNode(rectOf: CGSize(width: boardWidth * 0.88, height: 8), cornerRadius: 4)
        rail.fillColor = UIColor(red: 0.94, green: 0.87, blue: 0.73, alpha: 1)
        rail.strokeColor = UIColor(red: 0.76, green: 0.62, blue: 0.46, alpha: 0.9)
        rail.lineWidth = 1
        rail.position = CGPoint(x: centerX, y: fenceY + 4)
        decorLayer.addChild(rail)
    }

    private func addCornerDecor(boardWidth: CGFloat, boardHeight: CGFloat, centerX: CGFloat, centerY: CGFloat) {
        addBush(at: CGPoint(x: centerX - boardWidth * 0.37, y: centerY + boardHeight * 0.15))
        addBush(at: CGPoint(x: centerX + boardWidth * 0.35, y: centerY + boardHeight * 0.14))
        addFlowerCluster(at: CGPoint(x: centerX - boardWidth * 0.28, y: centerY - boardHeight * 0.06))
        addFlowerCluster(at: CGPoint(x: centerX + boardWidth * 0.08, y: centerY - boardHeight * 0.05))
        addTree(at: CGPoint(x: centerX - boardWidth * 0.47, y: centerY + boardHeight * 0.28))
        addTree(at: CGPoint(x: centerX + boardWidth * 0.46, y: centerY + boardHeight * 0.30))
    }

    private func addPlots(boardWidth: CGFloat, boardHeight: CGFloat, centerX: CGFloat, centerY: CGFloat) {
        let plotWidth: CGFloat = 68 + CGFloat(terrainExpansionLevel) * 6
        let plotHeight: CGFloat = 50 + CGFloat(terrainExpansionLevel) * 4
        let horizontalSpacing: CGFloat = 18 + CGFloat(terrainExpansionLevel) * 3
        let verticalSpacing: CGFloat = 20 + CGFloat(terrainExpansionLevel) * 3
        let startX = centerX - ((plotWidth * 2) + horizontalSpacing * 1.5)
        let firstRowY = centerY + boardHeight * 0.08

        for index in 0..<HouseStore.maxGardenPlots {
            let row = index / 4
            let column = index % 4
            let x = startX + CGFloat(column) * (plotWidth + horizontalSpacing)
            let y = firstRowY - CGFloat(row) * (plotHeight + verticalSpacing)

            let node = index < unlockedPlotCount
                ? unlockedPlotNode(index: index, size: CGSize(width: plotWidth, height: plotHeight))
                : lockedPlotNode(size: CGSize(width: plotWidth, height: plotHeight))
            node.position = CGPoint(x: x, y: y)
            plotLayer.addChild(node)
        }
    }

    private func unlockedPlotNode(index: Int, size: CGSize) -> SKNode {
        let container = SKNode()

        let shadow = SKShapeNode(ellipseOf: CGSize(width: size.width * 0.95, height: 18))
        shadow.fillColor = UIColor.black.withAlphaComponent(0.14)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 3, y: -size.height * 0.5 - 6)
        container.addChild(shadow)

        let base = SKShapeNode(rectOf: size, cornerRadius: 18)
        base.fillColor = UIColor(red: 0.69, green: 0.46, blue: 0.28, alpha: 1)
        base.strokeColor = UIColor(red: 0.46, green: 0.27, blue: 0.16, alpha: 0.88)
        base.lineWidth = 1.4
        container.addChild(base)

        let grass = SKShapeNode(rectOf: CGSize(width: size.width - 10, height: size.height - 12), cornerRadius: 14)
        grass.fillColor = plotGrassColor(index: index)
        grass.strokeColor = UIColor(red: 0.40, green: 0.70, blue: 0.34, alpha: 0.76)
        grass.lineWidth = 1
        grass.position = CGPoint(x: 0, y: 5)
        container.addChild(grass)

        let soil = SKShapeNode(rectOf: CGSize(width: size.width - 18, height: size.height - 26), cornerRadius: 12)
        soil.fillColor = UIColor(red: 0.56, green: 0.34, blue: 0.19, alpha: 0.96)
        soil.strokeColor = UIColor(red: 0.38, green: 0.23, blue: 0.14, alpha: 0.72)
        soil.lineWidth = 1
        soil.position = CGPoint(x: 0, y: -2)
        container.addChild(soil)

        let shine = SKShapeNode(rectOf: CGSize(width: size.width * 0.32, height: 10), cornerRadius: 5)
        shine.fillColor = UIColor.white.withAlphaComponent(0.14)
        shine.strokeColor = .clear
        shine.position = CGPoint(x: -size.width * 0.16, y: size.height * 0.23)
        container.addChild(shine)

        for offset in [CGPoint(x: -12, y: 2), CGPoint(x: 0, y: -5), CGPoint(x: 13, y: 4)] {
            let sprout = SKShapeNode(ellipseOf: CGSize(width: 6, height: 12))
            sprout.fillColor = UIColor(red: 0.48, green: 0.82, blue: 0.36, alpha: 0.95)
            sprout.strokeColor = .clear
            sprout.position = offset
            sprout.zRotation = offset.x < 0 ? -.pi / 10 : .pi / 10
            container.addChild(sprout)
        }

        return container
    }

    private func lockedPlotNode(size: CGSize) -> SKNode {
        let container = SKNode()

        let shadow = SKShapeNode(ellipseOf: CGSize(width: size.width * 0.92, height: 16))
        shadow.fillColor = UIColor.black.withAlphaComponent(0.06)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 2, y: -size.height * 0.5 - 4)
        container.addChild(shadow)

        let placeholder = SKShapeNode(rectOf: size, cornerRadius: 18)
        placeholder.fillColor = UIColor(red: 0.94, green: 0.92, blue: 0.84, alpha: 0.92)
        placeholder.strokeColor = UIColor(red: 0.77, green: 0.72, blue: 0.60, alpha: 0.88)
        placeholder.lineWidth = 1.2
        container.addChild(placeholder)

        let inset = SKShapeNode(rectOf: CGSize(width: size.width - 12, height: size.height - 14), cornerRadius: 14)
        inset.fillColor = UIColor(red: 0.98, green: 0.96, blue: 0.90, alpha: 0.94)
        inset.strokeColor = UIColor.clear
        inset.position = CGPoint(x: 0, y: 3)
        container.addChild(inset)

        let plus = SKLabelNode(text: "+")
        plus.fontName = "AvenirNext-Heavy"
        plus.fontSize = 24
        plus.fontColor = UIColor(red: 0.54, green: 0.58, blue: 0.42, alpha: 0.95)
        plus.verticalAlignmentMode = .center
        plus.horizontalAlignmentMode = .center
        plus.position = CGPoint(x: 0, y: 4)
        container.addChild(plus)

        return container
    }

    private func addBush(at position: CGPoint) {
        let colors = [
            UIColor(red: 0.47, green: 0.80, blue: 0.42, alpha: 0.95),
            UIColor(red: 0.56, green: 0.88, blue: 0.48, alpha: 0.92),
            UIColor(red: 0.66, green: 0.95, blue: 0.58, alpha: 0.88)
        ]
        let offsets: [CGPoint] = [.zero, CGPoint(x: -14, y: -4), CGPoint(x: 14, y: -4)]
        for (index, offset) in offsets.enumerated() {
            let bush = SKShapeNode(circleOfRadius: index == 0 ? 16 : 13)
            bush.fillColor = colors[index]
            bush.strokeColor = UIColor(red: 0.35, green: 0.68, blue: 0.31, alpha: 0.45)
            bush.lineWidth = 1
            bush.position = CGPoint(x: position.x + offset.x, y: position.y + offset.y)
            decorLayer.addChild(bush)
        }
    }

    private func addFlowerCluster(at position: CGPoint) {
        let colors: [UIColor] = [
            UIColor(red: 1.0, green: 0.64, blue: 0.75, alpha: 0.96),
            UIColor(red: 0.96, green: 0.87, blue: 0.42, alpha: 0.96),
            UIColor(red: 0.70, green: 0.76, blue: 1.0, alpha: 0.96)
        ]
        for index in 0..<3 {
            let flower = SKShapeNode(circleOfRadius: 6)
            flower.fillColor = colors[index]
            flower.strokeColor = UIColor.white.withAlphaComponent(0.4)
            flower.lineWidth = 0.8
            flower.position = CGPoint(x: position.x + CGFloat(index) * 10 - 10, y: position.y + CGFloat(index % 2) * 4)
            decorLayer.addChild(flower)
        }
    }

    private func addTree(at position: CGPoint) {
        let trunk = SKShapeNode(rectOf: CGSize(width: 12, height: 36), cornerRadius: 4)
        trunk.fillColor = UIColor(red: 0.62, green: 0.42, blue: 0.25, alpha: 1)
        trunk.strokeColor = UIColor.clear
        trunk.position = position
        decorLayer.addChild(trunk)

        let crownOffsets = [CGPoint(x: 0, y: 28), CGPoint(x: -16, y: 20), CGPoint(x: 16, y: 20)]
        let crownColors = [
            UIColor(red: 0.54, green: 0.84, blue: 0.43, alpha: 0.95),
            UIColor(red: 0.45, green: 0.78, blue: 0.39, alpha: 0.92),
            UIColor(red: 0.66, green: 0.92, blue: 0.55, alpha: 0.88)
        ]

        for index in 0..<3 {
            let crown = SKShapeNode(circleOfRadius: index == 0 ? 20 : 16)
            crown.fillColor = crownColors[index]
            crown.strokeColor = UIColor(red: 0.33, green: 0.67, blue: 0.28, alpha: 0.35)
            crown.lineWidth = 1
            crown.position = CGPoint(x: position.x + crownOffsets[index].x, y: position.y + crownOffsets[index].y)
            decorLayer.addChild(crown)
        }
    }

    private func placePet(boardWidth: CGFloat, centerX: CGFloat, centerY: CGFloat) {
        petNode.xScale = 0.92
        petNode.yScale = 0.72
        petNode.position = CGPoint(x: centerX + boardWidth * 0.33, y: centerY - 6)
        petNode.zPosition = 400

        petShadow.fillColor = UIColor(red: 0.22, green: 0.35, blue: 0.22, alpha: 0.18)
        petShadow.strokeColor = .clear
        petShadow.position = CGPoint(x: petNode.position.x, y: petNode.position.y - 34)
        petShadow.zPosition = 399
    }

    private func movePet(by delta: CGVector) {
        let targetPosition = CGPoint(
            x: petNode.position.x + delta.dx,
            y: petNode.position.y + delta.dy
        )
        let clampedPosition = clampedPetPosition(targetPosition)

        petNode.position = clampedPosition
        petShadow.position = CGPoint(x: clampedPosition.x, y: clampedPosition.y - 34)
    }

    private func clampedPetPosition(_ position: CGPoint) -> CGPoint {
        let insetX = max(currentBoardFrame.width * 0.12, 44)
        let insetY = max(currentBoardFrame.height * 0.18, 42)
        let minX = currentBoardFrame.minX + insetX
        let maxX = currentBoardFrame.maxX - insetX
        let minY = currentBoardFrame.minY + insetY
        let maxY = currentBoardFrame.maxY - insetY

        return CGPoint(
            x: min(max(position.x, minX), maxX),
            y: min(max(position.y, minY), maxY)
        )
    }

    private func updatePetFacing(for horizontalComponent: CGFloat) {
        guard abs(horizontalComponent) > 0.08 else { return }
        let direction: CGFloat = horizontalComponent < 0 ? -1 : 1
        petNode.xScale = abs(petNode.xScale) * direction
    }

    private var lawnColor: UIColor {
        switch mood {
        case .happy, .evolving:
            return UIColor(red: 0.63, green: 0.86, blue: 0.49, alpha: 1)
        case .anxious, .sick:
            return UIColor(red: 0.72, green: 0.82, blue: 0.62, alpha: 1)
        case .sleepy:
            return UIColor(red: 0.65, green: 0.80, blue: 0.70, alpha: 1)
        case .calm:
            return UIColor(red: 0.58, green: 0.82, blue: 0.48, alpha: 1)
        }
    }

    private var lawnInnerColor: UIColor {
        switch mood {
        case .happy, .evolving:
            return UIColor(red: 0.76, green: 0.93, blue: 0.60, alpha: 1)
        case .anxious, .sick:
            return UIColor(red: 0.82, green: 0.88, blue: 0.72, alpha: 1)
        case .sleepy:
            return UIColor(red: 0.76, green: 0.88, blue: 0.82, alpha: 1)
        case .calm:
            return UIColor(red: 0.70, green: 0.90, blue: 0.62, alpha: 1)
        }
    }

    private var lawnStrokeColor: UIColor {
        UIColor(red: 0.34, green: 0.63, blue: 0.28, alpha: 0.72)
    }

    private func plotGrassColor(index: Int) -> UIColor {
        let palette = [
            UIColor(red: 0.58, green: 0.86, blue: 0.42, alpha: 1),
            UIColor(red: 0.52, green: 0.82, blue: 0.36, alpha: 1),
            UIColor(red: 0.65, green: 0.90, blue: 0.48, alpha: 1)
        ]
        return palette[index % palette.count]
    }

    private func updateWeather() {
        weather?.removeFromParent()
        weather = nil

        let emitter: SKEmitterNode?
        switch mood {
        case .happy, .evolving:
            emitter = ParticleFactory.sparkle(size: size)
        case .anxious:
            emitter = ParticleFactory.rain(size: size)
        default:
            emitter = ParticleFactory.ambient(size: size)
        }

        guard let emitter else { return }
        emitter.position = CGPoint(x: size.width / 2, y: size.height)
        emitter.zPosition = 900
        addChild(emitter)
        weather = emitter
    }
}
