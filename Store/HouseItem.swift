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
        HouseItemDefinition(
            id: "food_strawberry",
            name: "Fragola Dolce",
            description: "Uno snack fresco e allegro per il pet.",
            category: .food, rarity: .common,
            spriteAsset: "item_strawberry", iconAsset: "icon_strawberry",
            price: 18, currency: .coins, storeKitProductID: nil,
            hungerBoost: 0.16, happinessBoost: 0.10, calmBoost: 0.0, energyBoost: 0.03,
            isPlaceable: false, isConsumable: true
        ),
        HouseItemDefinition(
            id: "food_honey_toast",
            name: "Toast al Miele",
            description: "Croccante, dorato e pieno di energia morbida.",
            category: .food, rarity: .common,
            spriteAsset: "item_honey_toast", iconAsset: "icon_honey_toast",
            price: 32, currency: .coins, storeKitProductID: nil,
            hungerBoost: 0.24, happinessBoost: 0.08, calmBoost: 0.03, energyBoost: 0.08,
            isPlaceable: false, isConsumable: true
        ),
        HouseItemDefinition(
            id: "food_milk",
            name: "Latte alla Vaniglia",
            description: "Una bevanda soffice che aiuta a recuperare.",
            category: .food, rarity: .common,
            spriteAsset: "item_milk", iconAsset: "icon_milk",
            price: 22, currency: .coins, storeKitProductID: nil,
            hungerBoost: 0.10, happinessBoost: 0.06, calmBoost: 0.06, energyBoost: 0.12,
            isPlaceable: false, isConsumable: true
        ),
        HouseItemDefinition(
            id: "food_bento",
            name: "Bento Kawaii",
            description: "Un pasto completo e colorato per giornate piene.",
            category: .food, rarity: .rare,
            spriteAsset: "item_bento", iconAsset: "icon_bento",
            price: 58, currency: .coins, storeKitProductID: nil,
            hungerBoost: 0.34, happinessBoost: 0.16, calmBoost: 0.04, energyBoost: 0.10,
            isPlaceable: false, isConsumable: true
        ),
        HouseItemDefinition(
            id: "food_jam",
            name: "Confettura di Bosco",
            description: "Piccola, brillante, migliora subito l'umore.",
            category: .food, rarity: .common,
            spriteAsset: "item_jam", iconAsset: "icon_jam",
            price: 20, currency: .coins, storeKitProductID: nil,
            hungerBoost: 0.12, happinessBoost: 0.12, calmBoost: 0.0, energyBoost: 0.02,
            isPlaceable: false, isConsumable: true
        ),
        HouseItemDefinition(
            id: "food_soup",
            name: "Zuppa Serena",
            description: "Una zuppa calda che coccola il pet nei giorni lenti.",
            category: .food, rarity: .common,
            spriteAsset: "item_soup", iconAsset: "icon_soup",
            price: 28, currency: .coins, storeKitProductID: nil,
            hungerBoost: 0.22, happinessBoost: 0.06, calmBoost: 0.12, energyBoost: 0.04,
            isPlaceable: false, isConsumable: true
        ),
        HouseItemDefinition(
            id: "food_mochi",
            name: "Mochi Nuvola",
            description: "Dolcetti soffici che migliorano il mood all'istante.",
            category: .food, rarity: .rare,
            spriteAsset: "item_mochi", iconAsset: "icon_mochi",
            price: 46, currency: .coins, storeKitProductID: nil,
            hungerBoost: 0.18, happinessBoost: 0.20, calmBoost: 0.05, energyBoost: 0.0,
            isPlaceable: false, isConsumable: true
        ),
        HouseItemDefinition(
            id: "food_lemonade",
            name: "Limonata Frizzante",
            description: "Disseta e dà una piccola spinta di vitalità.",
            category: .food, rarity: .common,
            spriteAsset: "item_lemonade", iconAsset: "icon_lemonade",
            price: 24, currency: .coins, storeKitProductID: nil,
            hungerBoost: 0.08, happinessBoost: 0.10, calmBoost: 0.02, energyBoost: 0.10,
            isPlaceable: false, isConsumable: true
        ),
        HouseItemDefinition(
            id: "food_pancakes",
            name: "Pancake Cuoricino",
            description: "Una colazione dolce che riempie e fa sorridere.",
            category: .food, rarity: .rare,
            spriteAsset: "item_pancakes", iconAsset: "icon_pancakes",
            price: 52, currency: .coins, storeKitProductID: nil,
            hungerBoost: 0.30, happinessBoost: 0.18, calmBoost: 0.04, energyBoost: 0.08,
            isPlaceable: false, isConsumable: true
        ),
        HouseItemDefinition(
            id: "food_smoothie",
            name: "Smoothie Pastello",
            description: "Frullato delicato con colori soft e tanta energia.",
            category: .food, rarity: .common,
            spriteAsset: "item_smoothie", iconAsset: "icon_smoothie",
            price: 30, currency: .coins, storeKitProductID: nil,
            hungerBoost: 0.14, happinessBoost: 0.10, calmBoost: 0.04, energyBoost: 0.14,
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
        HouseItemDefinition(
            id: "essential_bed",
            name: "Lettino Nuvola",
            description: "Un lettino compatto per sonnellini teneri.",
            category: .essentials, rarity: .common,
            spriteAsset: "item_bed", iconAsset: "icon_bed",
            price: 78, currency: .coins, storeKitProductID: nil,
            hungerBoost: 0.0, happinessBoost: 0.08, calmBoost: 0.10, energyBoost: 0.22,
            isPlaceable: true, isConsumable: false
        ),
        HouseItemDefinition(
            id: "essential_bookshelf",
            name: "Libreria Mini",
            description: "Ordine e atmosfera cozy per la stanza del pet.",
            category: .essentials, rarity: .common,
            spriteAsset: "item_bookshelf", iconAsset: "icon_bookshelf",
            price: 68, currency: .coins, storeKitProductID: nil,
            hungerBoost: 0.0, happinessBoost: 0.05, calmBoost: 0.08, energyBoost: 0.05,
            isPlaceable: true, isConsumable: false
        ),
        HouseItemDefinition(
            id: "essential_closet",
            name: "Armadio Biscotto",
            description: "Un piccolo armadio rotondo per tenere tutto in ordine.",
            category: .essentials, rarity: .rare,
            spriteAsset: "item_closet", iconAsset: "icon_closet",
            price: 92, currency: .coins, storeKitProductID: nil,
            hungerBoost: 0.0, happinessBoost: 0.06, calmBoost: 0.12, energyBoost: 0.08,
            isPlaceable: true, isConsumable: false
        ),
        HouseItemDefinition(
            id: "essential_bath",
            name: "Vaschetta Relax",
            description: "Un bagnetto rapido per riportare pace al pet.",
            category: .essentials, rarity: .rare,
            spriteAsset: "item_bath", iconAsset: "icon_bath",
            price: 98, currency: .coins, storeKitProductID: nil,
            hungerBoost: 0.0, happinessBoost: 0.08, calmBoost: 0.16, energyBoost: 0.10,
            isPlaceable: true, isConsumable: false
        ),
        HouseItemDefinition(
            id: "essential_stool",
            name: "Sgabello Miele",
            description: "Seduta piccola ma utile, perfetta vicino al pet.",
            category: .essentials, rarity: .common,
            spriteAsset: "item_stool", iconAsset: "icon_stool",
            price: 42, currency: .coins, storeKitProductID: nil,
            hungerBoost: 0.0, happinessBoost: 0.03, calmBoost: 0.04, energyBoost: 0.03,
            isPlaceable: true, isConsumable: false
        ),
        HouseItemDefinition(
            id: "essential_desk",
            name: "Scrivania Petalo",
            description: "Un piano morbido per attività calme e journaling.",
            category: .essentials, rarity: .rare,
            spriteAsset: "item_desk", iconAsset: "icon_desk",
            price: 88, currency: .coins, storeKitProductID: nil,
            hungerBoost: 0.0, happinessBoost: 0.05, calmBoost: 0.13, energyBoost: 0.06,
            isPlaceable: true, isConsumable: false
        ),
        HouseItemDefinition(
            id: "essential_nightstand",
            name: "Comodino Lume",
            description: "Un piccolo supporto che rende la stanza più completa.",
            category: .essentials, rarity: .common,
            spriteAsset: "item_nightstand", iconAsset: "icon_nightstand",
            price: 48, currency: .coins, storeKitProductID: nil,
            hungerBoost: 0.0, happinessBoost: 0.03, calmBoost: 0.06, energyBoost: 0.04,
            isPlaceable: true, isConsumable: false
        ),
        HouseItemDefinition(
            id: "essential_hammock",
            name: "Amaca Interna",
            description: "Un angolo dondolante che abbassa lo stress.",
            category: .essentials, rarity: .rare,
            spriteAsset: "item_hammock", iconAsset: "icon_hammock",
            price: 110, currency: .coins, storeKitProductID: nil,
            hungerBoost: 0.0, happinessBoost: 0.10, calmBoost: 0.18, energyBoost: 0.20,
            isPlaceable: true, isConsumable: false
        ),
        HouseItemDefinition(
            id: "essential_mirror",
            name: "Specchio Fiocco",
            description: "Illumina la stanza e la fa sembrare più ampia.",
            category: .essentials, rarity: .common,
            spriteAsset: "item_mirror", iconAsset: "icon_mirror",
            price: 58, currency: .coins, storeKitProductID: nil,
            hungerBoost: 0.0, happinessBoost: 0.06, calmBoost: 0.05, energyBoost: 0.02,
            isPlaceable: true, isConsumable: false
        ),
        HouseItemDefinition(
            id: "essential_screen",
            name: "Separé Sakura",
            description: "Divide gli spazi e dà un tocco molto cozy alla casa.",
            category: .essentials, rarity: .rare,
            spriteAsset: "item_screen", iconAsset: "icon_screen",
            price: 84, currency: .coins, storeKitProductID: nil,
            hungerBoost: 0.0, happinessBoost: 0.05, calmBoost: 0.12, energyBoost: 0.04,
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
        HouseItemDefinition(
            id: "deco_window",
            name: "Finestra Panoramica",
            description: "Una finestra grande e luminosa da montare nella stanza.",
            category: .decorations, rarity: .rare,
            spriteAsset: "item_window", iconAsset: "icon_window",
            price: 95, currency: .coins, storeKitProductID: nil,
            hungerBoost: 0.0, happinessBoost: 0.06, calmBoost: 0.08, energyBoost: 0.0,
            isPlaceable: true, isConsumable: false
        ),
        HouseItemDefinition(
            id: "deco_clock",
            name: "Orologio Ciliegia",
            description: "Un piccolo orologio decorativo dal tono allegro.",
            category: .decorations, rarity: .common,
            spriteAsset: "item_clock", iconAsset: "icon_clock",
            price: 44, currency: .coins, storeKitProductID: nil,
            hungerBoost: 0.0, happinessBoost: 0.04, calmBoost: 0.04, energyBoost: 0.0,
            isPlaceable: true, isConsumable: false
        ),
        HouseItemDefinition(
            id: "deco_frame",
            name: "Cornice Ricordo",
            description: "Una cornice morbida che rende la stanza più personale.",
            category: .decorations, rarity: .common,
            spriteAsset: "item_frame", iconAsset: "icon_frame",
            price: 36, currency: .coins, storeKitProductID: nil,
            hungerBoost: 0.0, happinessBoost: 0.05, calmBoost: 0.03, energyBoost: 0.0,
            isPlaceable: true, isConsumable: false
        ),
        HouseItemDefinition(
            id: "deco_poster",
            name: "Poster Arcobaleno",
            description: "Un poster colorato per una parete più viva.",
            category: .decorations, rarity: .common,
            spriteAsset: "item_poster", iconAsset: "icon_poster",
            price: 34, currency: .coins, storeKitProductID: nil,
            hungerBoost: 0.0, happinessBoost: 0.04, calmBoost: 0.01, energyBoost: 0.0,
            isPlaceable: true, isConsumable: false
        ),
        HouseItemDefinition(
            id: "deco_garland",
            name: "Ghirlanda Lucine",
            description: "Un filo di lucine soffuse che rende tutto più tenero.",
            category: .decorations, rarity: .rare,
            spriteAsset: "item_garland", iconAsset: "icon_garland",
            price: 72, currency: .coins, storeKitProductID: nil,
            hungerBoost: 0.0, happinessBoost: 0.08, calmBoost: 0.10, energyBoost: 0.0,
            isPlaceable: true, isConsumable: false
        ),
        HouseItemDefinition(
            id: "deco_vase",
            name: "Vaso Pastello",
            description: "Un vaso alto con un tocco da boutique kawaii.",
            category: .decorations, rarity: .common,
            spriteAsset: "item_vase", iconAsset: "icon_vase",
            price: 38, currency: .coins, storeKitProductID: nil,
            hungerBoost: 0.0, happinessBoost: 0.03, calmBoost: 0.04, energyBoost: 0.0,
            isPlaceable: true, isConsumable: false
        ),
        HouseItemDefinition(
            id: "deco_plush",
            name: "Peluche Orsetto",
            description: "Un piccolo amico di stoffa da tenere in stanza.",
            category: .decorations, rarity: .rare,
            spriteAsset: "item_plush", iconAsset: "icon_plush",
            price: 66, currency: .coins, storeKitProductID: nil,
            hungerBoost: 0.0, happinessBoost: 0.10, calmBoost: 0.08, energyBoost: 0.0,
            isPlaceable: true, isConsumable: false
        ),
        HouseItemDefinition(
            id: "deco_musicbox",
            name: "Carillon Fiore",
            description: "Una melodia delicata che rilassa il pet.",
            category: .decorations, rarity: .rare,
            spriteAsset: "item_musicbox", iconAsset: "icon_musicbox",
            price: 82, currency: .coins, storeKitProductID: nil,
            hungerBoost: 0.0, happinessBoost: 0.06, calmBoost: 0.14, energyBoost: 0.02,
            isPlaceable: true, isConsumable: false
        ),
        HouseItemDefinition(
            id: "deco_planter",
            name: "Fioriera Lunga",
            description: "Più verde, più serenità, più atmosfera domestica.",
            category: .decorations, rarity: .common,
            spriteAsset: "item_planter", iconAsset: "icon_planter",
            price: 52, currency: .coins, storeKitProductID: nil,
            hungerBoost: 0.0, happinessBoost: 0.03, calmBoost: 0.06, energyBoost: 0.0,
            isPlaceable: true, isConsumable: false
        ),
        HouseItemDefinition(
            id: "deco_mobile",
            name: "Mobile Stelline",
            description: "Un decoro sospeso che dà movimento alla stanza.",
            category: .decorations, rarity: .rare,
            spriteAsset: "item_mobile", iconAsset: "icon_mobile",
            price: 74, currency: .coins, storeKitProductID: nil,
            hungerBoost: 0.0, happinessBoost: 0.07, calmBoost: 0.10, energyBoost: 0.0,
            isPlaceable: true, isConsumable: false
        ),
        HouseItemDefinition(
            id: "deco_painting",
            name: "Quadro Alba",
            description: "Un quadro caldo per dare profondità alla parete.",
            category: .decorations, rarity: .common,
            spriteAsset: "item_painting", iconAsset: "icon_painting",
            price: 50, currency: .coins, storeKitProductID: nil,
            hungerBoost: 0.0, happinessBoost: 0.04, calmBoost: 0.05, energyBoost: 0.0,
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
        HouseItemDefinition(
            id: "special_orb",
            name: "Orbita di Luce",
            description: "Una sfera magica che dona atmosfera e serenità.",
            category: .specials, rarity: .legendary,
            spriteAsset: "item_orb", iconAsset: "icon_orb",
            price: 24, currency: .gems, storeKitProductID: "com.metime.item.orb",
            hungerBoost: 0.0, happinessBoost: 0.14, calmBoost: 0.20, energyBoost: 0.04,
            isPlaceable: true, isConsumable: false
        ),
        HouseItemDefinition(
            id: "special_star_map",
            name: "Mappa delle Stelle",
            description: "Sblocca una sensazione di viaggio e meraviglia.",
            category: .specials, rarity: .rare,
            spriteAsset: "item_star_map", iconAsset: "icon_star_map",
            price: 16, currency: .gems, storeKitProductID: "com.metime.item.star_map",
            hungerBoost: 0.0, happinessBoost: 0.10, calmBoost: 0.16, energyBoost: 0.02,
            isPlaceable: true, isConsumable: false
        ),
        HouseItemDefinition(
            id: "special_lotus",
            name: "Loto di Cristallo",
            description: "Un fiore raro che aumenta il calm della stanza.",
            category: .specials, rarity: .legendary,
            spriteAsset: "item_lotus", iconAsset: "icon_lotus",
            price: 22, currency: .gems, storeKitProductID: "com.metime.item.lotus",
            hungerBoost: 0.0, happinessBoost: 0.08, calmBoost: 0.24, energyBoost: 0.0,
            isPlaceable: true, isConsumable: false
        ),
        HouseItemDefinition(
            id: "special_moon_mirror",
            name: "Specchio Lunare",
            description: "Un oggetto speciale che riflette una luce da sogno.",
            category: .specials, rarity: .rare,
            spriteAsset: "item_moon_mirror", iconAsset: "icon_moon_mirror",
            price: 14, currency: .gems, storeKitProductID: "com.metime.item.moon_mirror",
            hungerBoost: 0.0, happinessBoost: 0.10, calmBoost: 0.12, energyBoost: 0.04,
            isPlaceable: true, isConsumable: false
        ),
        HouseItemDefinition(
            id: "special_fountain",
            name: "Fontana Piccola",
            description: "Il suono dell'acqua rende la stanza più viva e calma.",
            category: .specials, rarity: .legendary,
            spriteAsset: "item_fountain", iconAsset: "icon_fountain",
            price: 26, currency: .gems, storeKitProductID: "com.metime.item.fountain",
            hungerBoost: 0.0, happinessBoost: 0.12, calmBoost: 0.20, energyBoost: 0.02,
            isPlaceable: true, isConsumable: false
        ),
        HouseItemDefinition(
            id: "special_fairy_jar",
            name: "Barattolo di Fate",
            description: "Piccole luci sospese, perfette per la sera.",
            category: .specials, rarity: .rare,
            spriteAsset: "item_fairy_jar", iconAsset: "icon_fairy_jar",
            price: 13, currency: .gems, storeKitProductID: "com.metime.item.fairy_jar",
            hungerBoost: 0.0, happinessBoost: 0.11, calmBoost: 0.14, energyBoost: 0.0,
            isPlaceable: true, isConsumable: false
        ),
        HouseItemDefinition(
            id: "special_comet",
            name: "Coda di Cometa",
            description: "Una decorazione rara che dà sprint e stupore.",
            category: .specials, rarity: .legendary,
            spriteAsset: "item_comet", iconAsset: "icon_comet",
            price: 28, currency: .gems, storeKitProductID: "com.metime.item.comet",
            hungerBoost: 0.0, happinessBoost: 0.16, calmBoost: 0.12, energyBoost: 0.08,
            isPlaceable: true, isConsumable: false
        ),
        HouseItemDefinition(
            id: "special_music_crystal",
            name: "Cristallo Sonoro",
            description: "Emette una nota delicata quando il pet passa vicino.",
            category: .specials, rarity: .rare,
            spriteAsset: "item_music_crystal", iconAsset: "icon_music_crystal",
            price: 18, currency: .gems, storeKitProductID: "com.metime.item.music_crystal",
            hungerBoost: 0.0, happinessBoost: 0.12, calmBoost: 0.16, energyBoost: 0.0,
            isPlaceable: true, isConsumable: false
        ),
        HouseItemDefinition(
            id: "special_snow_globe",
            name: "Sfera di Neve",
            description: "Una piccola scena magica che rende tutto più cozy.",
            category: .specials, rarity: .rare,
            spriteAsset: "item_snow_globe", iconAsset: "icon_snow_globe",
            price: 17, currency: .gems, storeKitProductID: "com.metime.item.snow_globe",
            hungerBoost: 0.0, happinessBoost: 0.09, calmBoost: 0.17, energyBoost: 0.0,
            isPlaceable: true, isConsumable: false
        ),
        HouseItemDefinition(
            id: "special_portal",
            name: "Portale Aurora",
            description: "Oggetto ultra raro per una stanza davvero speciale.",
            category: .specials, rarity: .legendary,
            spriteAsset: "item_portal", iconAsset: "icon_portal",
            price: 30, currency: .gems, storeKitProductID: "com.metime.item.portal",
            hungerBoost: 0.0, happinessBoost: 0.18, calmBoost: 0.22, energyBoost: 0.06,
            isPlaceable: true, isConsumable: false
        ),
    ]

    static func item(for id: String) -> HouseItemDefinition? {
        catalog.first { $0.id == id }
    }
}
