import SpriteKit

final class PetNode: SKNode {
    private let sprite = SKShapeNode(circleOfRadius: 40)

    override init() {
        super.init()
        sprite.fillColor = .white
        sprite.strokeColor = .clear
        addChild(sprite)
        startIdle()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setMood(_ mood: PetMood) {
        switch mood {
        case .calm: sprite.fillColor = .white
        case .happy: sprite.fillColor = .systemYellow
        case .anxious: sprite.fillColor = .systemOrange
        case .sleepy: sprite.fillColor = .systemBlue
        case .sick: sprite.fillColor = .systemGray
        case .evolving: sprite.fillColor = .systemPink
        }
    }

    func bounce() {
        let up = SKAction.scale(to: 1.2, duration: 0.1)
        let down = SKAction.scale(to: 1.0, duration: 0.15)
        run(.sequence([up, down]))
    }

    private func startIdle() {
        let a = SKAction.moveBy(x: 0, y: 8, duration: 1.4)
        let b = SKAction.moveBy(x: 0, y: -8, duration: 1.4)
        run(.repeatForever(.sequence([a, b])))
    }
}
