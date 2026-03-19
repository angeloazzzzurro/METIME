import SwiftUI

class NavigationState: ObservableObject {
    enum Section: CaseIterable {
        case home, garden, store, inventory, decorate, meTime
    }
    @Published var activeSection: Section = .home
}
