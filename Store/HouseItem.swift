import Foundation
import SwiftData

// MARK: - Item Category

enum ItemCategory: String, Codable, CaseIterable {
    case food        = "food"
    case essentials  = "essentials"
    case decorations = "decorations"
    case specials    = "specials"

    var displayName: String {
        switch self {
        case .food:        return "Cibo"
        case .essentials:  return "Essenziali"
        case .decorations: return "Decorazioni"
        case .specials:    return "Speciali"
        }
    }

    var emoji: String {
        switch self {
        case .food:        return "🍎"
        case .essentials:  return "🛏"
        case .decorations: return "🪴"
        case .specials:    return "✨"
        }
    }

    var sfSymbol: String {
        switch self {
        case .food:        return "fork.knife"
        case .essentials:  return "house.fill"
        case .decorations: return "paintbrush.fill"
        case .specials:    return "sparkles"
        }
    }
}

// MARK: - Item Rarity

enum ItemRarity: String, Codable {
    case common    = "common"
    case rare      = "rare"
    case legendary = "legendary"

    var color: String {
        switch self {
        case .common:    return "#A0A0A5"
        case .rare:      return "#7C3AED"
        case .legendary: return "#F59E0B"
        }
    }
}

// MARK: - Currency Type

enum CurrencyType: String, Codable {
    case coins     = "coins"      // Valuta virtuale guadagnata giocando
    case gems      = "gems"       // Valuta premium acquistabile con StoreKit 2
}

// MARK: - House Item Definition (catalogo statico)

struct HouseItemDefinition: Identifiable, Hashable {
    let id: String
    let name: String
    let description: String
    let category: ItemCategory
    let rarity: ItemRarity
    let spriteAsset: String       // nome asset SpriteKit
    let iconAsset: String         // nome asset icona UI
    let price: Int
    let currency: CurrencyType
    let storeKitProductID: String? // nil se solo valuta virtuale

    // Effetti sul pet quando usato
    let hungerBoost: Double
    let happinessBoost: Double
    let calmBoost: Double
    let energyBoost: Double

    // Posizionamento nella stanza
    let isPlaceable: Bool         // può essere posizionato nella stanza
    let isConsumable: Bool        // scompare dopo l'uso (es. cibo)

    static let catalog: [HouseItemDefinition] = [

        // MARK: Cibo
        HouseItemDefinition(
            id: "food_carrot",
            name: "Carota Magica",
            description: "Una carota fresca dal giardino. Sana e nutriente.",
            category: .food, rarity: .common,
            spriteAsset: "item_carrot", iconAsset: "icon_carrot",
            price: 20, currency: .coins, storeKitProductID: nil,
            hungerBoost: 0.3, happinessBoost: 0.05, calmBoost: 0.0, energyBoost: 0.05,
            isPlaceable: false, isConsumable: true
        ),
        HouseItemDefinition(
            id: "food_cookie",
            name: "Biscotto Stellato",
            description: "Un biscotto a forma di stella. Rende felice all'istante.",
            category: .food, rarity: .common,
            spriteAsset: "item_cookie", iconAsset: "icon_cookie",
            price: 35, currency: .coins, storeKitProductID: nil,
            hungerBoost: 0.2, happinessBoost: 0.2, calmBoost: 0.0, energyBoost: 0.0,
            isPlaceable: false, isConsumable: true
        ),
        HouseItemDefinition(
            id: "food_cake",
            name: "Torta Rosa",
            description: "Una torta kawaii per le occasioni speciali.",
            category: .food, rarity: .rare,
            spriteAsset: "item_cake", iconAsset: "icon_cake",
            price: 5, currency: .gems, storeKitProductID: "com.metime.item.cake",
            hungerBoost: 0.5, happinessBoost: 0.4, calmBoost: 0.1, energyBoost: 0.1,
            isPlaceable: false, isConsumable: true
        ),
        HouseItemDefinition(
            id: "food_tea",
            name: "Tè alla Camomilla",
            description: "Una tazza di tè caldo. Calma e rilassa.",
            category: .food, rarity: .common,
            spriteAsset: "item_tea", iconAsset: "icon_tea",
            price: 25, currency: .coins, storeKitProductID: nil,
            hungerBoost: 0.1, happinessBoost: 0.1, calmBoost: 0.35, energyBoost: 0.05,
            isPlaceable: false, isConsumable: true
        ),

        // MARK: Essenziali
        HouseItemDefinition(
            id: "essential_bowl",
            name: "Ciotola di Ceramica",
            description: "Una ciotola artigianale per il cibo del pet.",
            category: .essentials, rarity: .common,
            spriteAsset: "item_bowl", iconAsset: "icon_bowl",
            price: 50, currency: .coins, storeKitProductID: nil,
            hungerBoost: 0.0, happinessBoost: 0.05, calmBoost: 0.0, energyBoost: 0.0,
            isPlaceable: true, isConsumable: false
        ),
        HouseItemDefinition(
            id: "essential_cushion",
            name: "Cuscino Lilla",
            description: "Un cuscino morbidissimo per riposare.",
            category: .essentials, rarity: .common,
            spriteAsset: "item_cushion", iconAsset: "icon_cushion",
            price: 60, currency: .coins, storeKitProductID: nil,
            hungerBoost: 0.0, happinessBoost: 0.05, calmBoost: 0.1, energyBoost: 0.15,
            isPlaceable: true, isConsumable: false
        ),
        HouseItemDefinition(
            id: "essential_blanket",
            name: "Copertina Stellata",
            description: "Una coperta con stelle dorate. Aumenta il recupero di energia.",
            category: .essentials, rarity: .rare,
            spriteAsset: "item_blanket", iconAsset: "icon_blanket",
            price: 8, currency: .gems, storeKitProductID: "com.metime.item.blanket",
            hungerBoost: 0.0, happinessBoost: 0.1, calmBoost: 0.15, energyBoost: 0.3,
            isPlaceable: true, isConsumable: false
        ),

        // MARK: Decorazioni
        HouseItemDefinition(
            id: "deco_plant",
            name: "Piantina Felice",
            description: "Una piccola pianta che porta serenità alla stanza.",
            category: .decorations, rarity: .common,
            spriteAsset: "item_plant", iconAsset: "icon_plant",
            price: 40, currency: .coins, storeKitProductID: nil,
            hungerBoost: 0.0, happinessBoost: 0.02, calmBoost: 0.02, energyBoost: 0.0,
            isPlaceable: true, isConsumable: false
        ),
        HouseItemDefinition(
            id: "deco_lamp",
            name: "Lampada Lunare",
            description: "Una lampada a forma di luna. Illumina la stanza con luce soffusa.",
            category: .decorations, rarity: .rare,
            spriteAsset: "item_lamp", iconAsset: "icon_lamp",
            price: 10, currency: .gems, storeKitProductID: "com.metime.item.lamp",
            hungerBoost: 0.0, happinessBoost: 0.05, calmBoost: 0.05, energyBoost: 0.0,
            isPlaceable: true, isConsumable: false
        ),
        HouseItemDefinition(
            id: "deco_rug",
            name: "Tappeto Arcobaleno",
            description: "Un tappeto coloratissimo che rende la stanza più vivace.",
            category: .decorations, rarity: .common,
            spriteAsset: "item_rug", iconAsset: "icon_rug",
            price: 55, currency: .coins, storeKitProductID: nil,
            hungerBoost: 0.0, happinessBoost: 0.03, calmBoost: 0.0, energyBoost: 0.0,
            isPlaceable: true, isConsumable: false
        ),

        // MARK: Speciali
        HouseItemDefinition(
            id: "special_crystal",
            name: "Cristallo Viola",
            description: "Un cristallo magico. Sblocca l'animazione 'danza' del pet.",
            category: .specials, rarity: .legendary,
            spriteAsset: "item_crystal", iconAsset: "icon_crystal",
            price: 20, currency: .gems, storeKitProductID: "com.metime.item.crystal",
            hungerBoost: 0.0, happinessBoost: 0.2, calmBoost: 0.2, energyBoost: 0.0,
            isPlaceable: true, isConsumable: false
        ),
        HouseItemDefinition(
            id: "special_book",
            name: "Libro dei Sogni",
            description: "Un libro illustrato. Sblocca nuove riflessioni nel diario.",
            category: .specials, rarity: .rare,
            spriteAsset: "item_book", iconAsset: "icon_book",
            price: 12, currency: .gems, storeKitProductID: "com.metime.item.book",
            hungerBoost: 0.0, happinessBoost: 0.1, calmBoost: 0.15, energyBoost: 0.0,
            isPlaceable: true, isConsumable: false
        ),
        HouseItemDefinition(
            id: "special_candle",
            name: "Candela Aromatica",
            description: "Una candela profumata. Aumenta il calm passivamente nel tempo.",
            category: .specials, rarity: .rare,
            spriteAsset: "item_candle", iconAsset: "icon_candle",
            price: 15, currency: .gems, storeKitProductID: "com.metime.item.candle",
            hungerBoost: 0.0, happinessBoost: 0.05, calmBoost: 0.25, energyBoost: 0.0,
            isPlaceable: true, isConsumable: false
        ),
    ]

    static func item(for id: String) -> HouseItemDefinition? {
        catalog.first { $0.id == id }
    }
}
