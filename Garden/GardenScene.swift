import SpriteKit

final class GardenScene: SKScene {
    private let pet = PetNode()
    private var weather: SKEmitterNode?

    var mood: PetMood = .calm {
        didSet {
            updateBackground()
            pet.setMood(mood)
            updateWeather()
        }
    }

    // MARK: - Lifecycle

    override func didMove(to view: SKView) {
        updateBackground()

        let ground = SKShapeNode(rectOf: CGSize(width: size.width,
                                                height: size.height * 0.25),
                                 cornerRadius: 8)
        ground.fillColor = .systemGreen
        ground.strokeColor = .clear
        ground.position = CGPoint(x: size.width / 2, y: size.height * 0.15)
        addChild(ground)

        pet.position = CGPoint(x: size.width / 2, y: size.height * 0.45)
        addChild(pet)

        let ambient = ParticleFactory.ambient(size: size)
        ambient.position = CGPoint(x: size.width / 2, y: size.height)
        addChild(ambient)

        updateWeather()
    }

    // MARK: - Touch

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        pet.bounce()
    }

    // MARK: - Private

    private func updateBackground() {
        let colorName = ColorResource.background(for: mood).rawValue
        backgroundColor = UIColor(named: colorName) ?? .systemMint
    }

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
            sparkle.position = CGPoint(x: size.width / 2, y: size.height * 0.6)
            addChild(sparkle)
            weather = sparkle

        default:
            break
        }
    }
}
