import SwiftUI

class NavigationState: ObservableObject {
    enum Section: CaseIterable {
        case home, garden, games, diary, store, inventory, decorate, meTime, ritual, map, restaurant, farm

        var displayName: String {
            switch self {
            case .home:       return "Casa"
            case .garden:     return "Giardino"
            case .games:      return "Giochi"
            case .diary:      return "Diario"
            case .store:      return "Store"
            case .inventory:  return "Zaino"
            case .decorate:   return "Decora"
            case .meTime:     return "Me Time"
            case .ritual:     return "Rituale"
            case .map:        return "Mappa"
            case .restaurant: return "Cucina"
            case .farm:       return "Fattoria"
            }
        }
    }
    @Published var activeSection: Section = .home
}
