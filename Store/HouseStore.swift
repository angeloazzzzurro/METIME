import Foundation
import StoreKit
import SwiftData
import OSLog

private let log = Logger(subsystem: "com.metime", category: "HouseStore")

// MARK: - Purchase Result

enum PurchaseResult {
    case success
    case insufficientFunds(needed: Int, currency: CurrencyType)
    case storeKitPending
    case storeKitFailed(Error)
    case alreadyOwned
}

// MARK: - Gem Pack (StoreKit 2 products)

struct GemPack: Identifiable {
    let id: String           // StoreKit product ID
    let gems: Int
    let bonusLabel: String?

    static let all: [GemPack] = [
        GemPack(id: "com.metime.gems.small",  gems: 10,  bonusLabel: nil),
        GemPack(id: "com.metime.gems.medium", gems: 30,  bonusLabel: "+5 Bonus"),
        GemPack(id: "com.metime.gems.large",  gems: 80,  bonusLabel: "+20 Bonus"),
    ]
}

// MARK: - HouseStore

@MainActor
final class HouseStore: ObservableObject {

    // MARK: Published State
    @Published private(set) var wallet: Wallet
    @Published private(set) var inventory: [OwnedItem] = []
    @Published private(set) var storeKitProducts: [Product] = []
    @Published private(set) var isPurchasing: Bool = false
    @Published var lastPurchaseResult: PurchaseResult?

    // MARK: Dependencies
    private let modelContext: ModelContext
    private var transactionListener: Task<Void, Never>?

    // MARK: Init
    init(modelContext: ModelContext) {
        self.modelContext = modelContext

        // Carica o crea il wallet
        let wallets = (try? modelContext.fetch(FetchDescriptor<Wallet>())) ?? []
        if let existing = wallets.first {
            self.wallet = existing
        } else {
            let newWallet = Wallet(coins: 100, gems: 5)
            modelContext.insert(newWallet)
            self.wallet = newWallet
            try? modelContext.save()
        }

        // Carica inventario
        self.inventory = (try? modelContext.fetch(FetchDescriptor<OwnedItem>())) ?? []

        // Avvia listener transazioni StoreKit 2
        transactionListener = listenForTransactions()

        // Carica prodotti StoreKit 2
        Task { await loadStoreKitProducts() }
    }

    deinit {
        transactionListener?.cancel()
    }

    // MARK: - Coins Purchase (valuta virtuale)

    func purchase(item: HouseItemDefinition) -> PurchaseResult {
        guard item.currency == .coins else {
            // Per gli item in gems, usa StoreKit
            return .storeKitPending
        }

        guard wallet.canAfford(price: item.price, currency: .coins) else {
            return .insufficientFunds(needed: item.price, currency: .coins)
        }

        wallet.deduct(price: item.price, currency: .coins)
        addToInventory(itemID: item.id)
        save()
        log.info("Purchased \(item.id) for \(item.price) coins")
        return .success
    }

    // MARK: - StoreKit 2 Purchase (gems o item premium)

    func purchaseWithStoreKit(item: HouseItemDefinition) async -> PurchaseResult {
        guard let productID = item.storeKitProductID,
              let product = storeKitProducts.first(where: { $0.id == productID }) else {
            log.error("StoreKit product not found for \(item.id)")
            return .storeKitFailed(NSError(domain: "HouseStore", code: -1,
                                           userInfo: [NSLocalizedDescriptionKey: "Prodotto non trovato"]))
        }

        isPurchasing = true
        defer { isPurchasing = false }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                addToInventory(itemID: item.id)
                save()
                await transaction.finish()
                log.info("StoreKit purchase success: \(item.id)")
                return .success
            case .pending:
                return .storeKitPending
            case .userCancelled:
                return .storeKitFailed(NSError(domain: "HouseStore", code: -2,
                                               userInfo: [NSLocalizedDescriptionKey: "Acquisto annullato"]))
            @unknown default:
                return .storeKitFailed(NSError(domain: "HouseStore", code: -3,
                                               userInfo: [NSLocalizedDescriptionKey: "Errore sconosciuto"]))
            }
        } catch {
            log.error("StoreKit purchase failed: \(error.localizedDescription)")
            return .storeKitFailed(error)
        }
    }

    // MARK: - Gem Pack Purchase (StoreKit 2)

    func purchaseGemPack(_ pack: GemPack) async -> PurchaseResult {
        guard let product = storeKitProducts.first(where: { $0.id == pack.id }) else {
            return .storeKitFailed(NSError(domain: "HouseStore", code: -1,
                                           userInfo: [NSLocalizedDescriptionKey: "Pacchetto non trovato"]))
        }

        isPurchasing = true
        defer { isPurchasing = false }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                wallet.add(gems: pack.gems)
                save()
                await transaction.finish()
                log.info("Purchased gem pack: \(pack.gems) gems")
                return .success
            case .pending:
                return .storeKitPending
            case .userCancelled:
                return .storeKitFailed(NSError(domain: "HouseStore", code: -2,
                                               userInfo: [NSLocalizedDescriptionKey: "Acquisto annullato"]))
            @unknown default:
                return .storeKitFailed(NSError(domain: "HouseStore", code: -3,
                                               userInfo: [NSLocalizedDescriptionKey: "Errore sconosciuto"]))
            }
        } catch {
            return .storeKitFailed(error)
        }
    }

    // MARK: - Use Item (consuma o applica effetti)

    func useItem(_ ownedItem: OwnedItem, on gameStore: GameStore) -> Bool {
        guard let def = ownedItem.definition else { return false }

        gameStore.applyBoost(
            hunger: def.hungerBoost,
            happiness: def.happinessBoost,
            calm: def.calmBoost,
            energy: def.energyBoost
        )

        if def.isConsumable {
            ownedItem.quantity -= 1
            if ownedItem.quantity <= 0 {
                modelContext.delete(ownedItem)
                inventory.removeAll { $0.itemID == ownedItem.itemID }
            }
        }

        save()
        log.info("Used item \(def.id)")
        return true
    }

    // MARK: - Room Placement

    func place(item: OwnedItem, at position: CGPoint) {
        item.roomPositionX = position.x
        item.roomPositionY = position.y
        item.isPlacedInRoom = true
        save()
    }

    func removeFromRoom(item: OwnedItem) {
        item.roomPositionX = nil
        item.roomPositionY = nil
        item.isPlacedInRoom = false
        save()
    }

    // MARK: - Coins Reward (guadagnati giocando)

    func rewardCoins(_ amount: Int) {
        wallet.add(coins: amount)
        save()
        log.info("Rewarded \(amount) coins")
    }

    // MARK: - Helpers

    func owns(itemID: String) -> Bool {
        inventory.contains { $0.itemID == itemID && $0.quantity > 0 }
    }

    func quantity(of itemID: String) -> Int {
        inventory.first { $0.itemID == itemID }?.quantity ?? 0
    }

    func itemsPlacedInRoom() -> [OwnedItem] {
        inventory.filter { $0.isPlacedInRoom }
    }

    // MARK: - Private

    private func addToInventory(itemID: String) {
        if let existing = inventory.first(where: { $0.itemID == itemID }) {
            existing.quantity += 1
        } else {
            let newItem = OwnedItem(itemID: itemID)
            modelContext.insert(newItem)
            inventory.append(newItem)
        }
    }

    private func save() {
        do {
            try modelContext.save()
        } catch {
            log.error("Save failed: \(error.localizedDescription)")
        }
    }

    private func loadStoreKitProducts() async {
        let allIDs: [String] = HouseItemDefinition.catalog.compactMap { $0.storeKitProductID }
            + GemPack.all.map { $0.id }
        do {
            storeKitProducts = try await Product.products(for: Set(allIDs))
            log.info("Loaded \(self.storeKitProducts.count) StoreKit products")
        } catch {
            log.error("Failed to load StoreKit products: \(error.localizedDescription)")
        }
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task(priority: .background) { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                do {
                    let transaction = try self.checkVerified(result)
                    // Gestione resi/revoche
                    if transaction.revocationDate != nil {
                        await MainActor.run {
                            self.inventory.removeAll { $0.itemID == transaction.productID }
                            self.save()
                        }
                    }
                    await transaction.finish()
                } catch {
                    log.error("Unverified transaction: \(error.localizedDescription)")
                }
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let value):
            return value
        }
    }
}
