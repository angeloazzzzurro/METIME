import SpriteKit

final class GardenScene: SKScene {
    private let pet = PetNode()
    private var weather: SKEmitterNode?

    var mood: PetMood = .calm {
        didSet {
            pet.setMood(mood)
            updateWeather()
        }
    }

    // MARK: - Lifecycle

    override func didMove(to view: SKView) {
        // Sfondo trasparente: il gradiente kawaii di SwiftUI è visibile sotto
        backgroundColor = .clear

        // Terreno kawaii: erba verde pastello arrotondata
        let ground = SKShapeNode(rectOf: CGSize(width: size.width * 1.2,
                                                height: size.height * 0.28),
                                 cornerRadius: size.height * 0.14)
        ground.fillColor   = UIColor(red: 0.72, green: 0.94, blue: 0.72, alpha: 0.85)
        ground.strokeColor = UIColor(red: 0.55, green: 0.85, blue: 0.55, alpha: 0.5)
        ground.lineWidth   = 2
        ground.position    = CGPoint(x: size.width / 2, y: size.height * 0.10)
        addChild(ground)

        // Piccoli fiorellini decorativi sul terreno
        addFlowers()

        // Pet centrato
        pet.position = CGPoint(x: size.width / 2, y: size.height * 0.42)
        addChild(pet)

        // Particelle ambientali leggere
        let ambient = ParticleFactory.ambient(size: size)
        ambient.position = CGPoint(x: size.width / 2, y: size.height)
        addChild(ambient)

        updateWeather()
    }

    // MARK: - Touch

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        pet.bounce()
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

    // MARK: - Decorazioni

    private func addFlowers() {
        let positions: [CGPoint] = [
            CGPoint(x: size.width * 0.18, y: size.height * 0.24),
            CGPoint(x: size.width * 0.30, y: size.height * 0.22),
            CGPoint(x: size.width * 0.68, y: size.height * 0.23),
            CGPoint(x: size.width * 0.82, y: size.height * 0.25),
        ]
        let colors: [UIColor] = [
            UIColor(red: 1.0, green: 0.6, blue: 0.75, alpha: 0.9),
            UIColor(red: 1.0, green: 0.9, blue: 0.4, alpha: 0.9),
            UIColor(red: 0.8, green: 0.6, blue: 1.0, alpha: 0.9),
            UIColor(red: 1.0, green: 0.7, blue: 0.4, alpha: 0.9),
        ]
        for (i, pos) in positions.enumerated() {
            let flower = SKShapeNode(circleOfRadius: 6)
            flower.fillColor   = colors[i % colors.count]
            flower.strokeColor = .clear
            flower.position    = pos
            addChild(flower)

            // Gambo
            let stem = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: CGPoint(x: pos.x, y: pos.y - 6))
            path.addLine(to: CGPoint(x: pos.x, y: pos.y - 16))
            stem.path        = path
            stem.strokeColor = UIColor(red: 0.4, green: 0.75, blue: 0.4, alpha: 0.8)
            stem.lineWidth   = 2
            addChild(stem)
        }
    }
}
