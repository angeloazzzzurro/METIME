import UIKit
import SwiftUI

// MARK: - PetColor
//
// Palette di colori pastello intercambiabili per il pet "Me".
// Toccando il pet si cicla tra questi colori con animazione fluida.
// L'indice corrente viene persistito in Pet.colorIndex via SwiftData.

enum PetColor: Int, CaseIterable {
    case cream    = 0
    case lavender = 1
    case peach    = 2
    case mint     = 3
    case sky      = 4
    case rose     = 5
    case butter   = 6
    case lilac    = 7

    // MARK: - UIColor (usato da SpriteKit)

    var uiColor: UIColor {
        switch self {
        case .cream:    return UIColor(red: 0.98, green: 0.95, blue: 0.90, alpha: 1) // bianco/crema
        case .lavender: return UIColor(red: 0.88, green: 0.80, blue: 0.98, alpha: 1) // lilla
        case .peach:    return UIColor(red: 1.00, green: 0.82, blue: 0.72, alpha: 1) // pesca
        case .mint:     return UIColor(red: 0.75, green: 0.96, blue: 0.85, alpha: 1) // menta
        case .sky:      return UIColor(red: 0.72, green: 0.88, blue: 1.00, alpha: 1) // azzurro
        case .rose:     return UIColor(red: 1.00, green: 0.78, blue: 0.84, alpha: 1) // rosa
        case .butter:   return UIColor(red: 1.00, green: 0.95, blue: 0.68, alpha: 1) // burro
        case .lilac:    return UIColor(red: 0.82, green: 0.72, blue: 0.98, alpha: 1) // glicine
        }
    }

    // MARK: - SwiftUI Color (usato per UI)

    var color: Color {
        Color(uiColor: uiColor)
    }

    // MARK: - Nome visualizzato

    var displayName: String {
        switch self {
        case .cream:    return "Crema"
        case .lavender: return "Lavanda"
        case .peach:    return "Pesca"
        case .mint:     return "Menta"
        case .sky:      return "Cielo"
        case .rose:     return "Rosa"
        case .butter:   return "Burro"
        case .lilac:    return "Glicine"
        }
    }

    // MARK: - Colore bordo (leggermente più scuro del fill)

    var strokeUIColor: UIColor {
        uiColor.withAlphaComponent(0.5)
    }

    // MARK: - Ciclo al prossimo colore

    var next: PetColor {
        PetColor(rawValue: (rawValue + 1) % PetColor.allCases.count) ?? .cream
    }
}
