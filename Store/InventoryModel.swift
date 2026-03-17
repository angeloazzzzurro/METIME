import Foundation
import SwiftData

// MARK: - Owned Item (SwiftData)

@Model
final class OwnedItem {
    var itemID: String
    var quantity: Int
    var acquiredAt: Date

    // Posizionamento nella stanza (nil = non posizionato)
    var roomPositionX: Double?
    var roomPositionY: Double?
    var isPlacedInRoom: Bool

    init(itemID: String, quantity: Int = 1) {
        self.itemID = itemID
        self.quantity = quantity
        self.acquiredAt = Date()
        self.roomPositionX = nil
        self.roomPositionY = nil
        self.isPlacedInRoom = false
    }

    var definition: HouseItemDefinition? {
        HouseItemDefinition.item(for: itemID)
    }
}

// MARK: - Wallet (SwiftData)

@Model
final class Wallet {
    var coins: Int
    var gems: Int

    init(coins: Int = 100, gems: Int = 5) {
        self.coins = coins
        self.gems = gems
    }

    func canAfford(price: Int, currency: CurrencyType) -> Bool {
        switch currency {
        case .coins: return coins >= price
        case .gems:  return gems >= price
        }
    }

    func deduct(price: Int, currency: CurrencyType) {
        switch currency {
        case .coins: coins = max(0, coins - price)
        case .gems:  gems  = max(0, gems - price)
        }
    }

    func add(coins amount: Int) {
        coins += amount
    }

    func add(gems amount: Int) {
        gems += amount
    }
}
