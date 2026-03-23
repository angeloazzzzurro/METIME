import SwiftUI

class NavigationState: ObservableObject {
    enum Section: CaseIterable {
        case home, garden, store, inventory, decorate, meTime

        var displayName: String {
            switch self {
            case .home:      return "Casa"
            case .garden:    return "Giardino"
            case .store:     return "Store"
            case .inventory: return "Zaino"
            case .decorate:  return "Decora"
            case .meTime:    return "Me Time"
            }
        }
    }
    @Published var activeSection: Section = .home
}
