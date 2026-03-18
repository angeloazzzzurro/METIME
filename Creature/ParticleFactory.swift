import SpriteKit

@MainActor
enum ParticleFactory {
    static func ambient(size: CGSize) -> SKEmitterNode {
        let e = SKEmitterNode()
        e.particleBirthRate = 3
        e.particleLifetime = 8
        e.particleSpeed = 20
        e.particleAlpha = 0.6
        e.particleScale = 0.08
        e.particlePositionRange = CGVector(dx: size.width, dy: 0)
        e.emissionAngle = -.pi / 2
        e.particleColor = .white
        return e
    }

    static func rain(size: CGSize) -> SKEmitterNode {
        let e = SKEmitterNode()
        e.particleBirthRate = 70
        e.particleLifetime = 1.7
        e.particleSpeed = 300
        e.particleScale = 0.04
        e.particleAlpha = 0.5
        e.particlePositionRange = CGVector(dx: size.width, dy: 0)
        e.emissionAngle = -.pi / 2
        e.particleColor = .systemBlue
        return e
    }

    static func sparkle(size: CGSize) -> SKEmitterNode {
        let e = SKEmitterNode()
        e.particleBirthRate = 6
        e.particleLifetime = 2.5
        e.particleSpeed = 30
        e.particleScale = 0.12
        e.particleAlpha = 0.8
        e.particlePositionRange = CGVector(dx: size.width * 0.6, dy: size.height * 0.3)
        e.emissionAngleRange = .pi * 2
        e.particleColor = .systemYellow
        return e
    }
}
