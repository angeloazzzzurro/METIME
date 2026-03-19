import SwiftUI

class NavigationState: ObservableObject {
    enum Section: CaseIterable {
        case home, garden, store, inventory, decorate, meTime
    }

    @Published private(set) var activeSection: Section = .garden
    private var history: [Section] = []

    var canGoBack: Bool {
        !history.isEmpty
    }

    func navigate(to section: Section) {
        guard activeSection != section else { return }
        history.append(activeSection)
        activeSection = section
    }

    func goBack() {
        guard let previous = history.popLast() else { return }
        activeSection = previous
    }

    func reset(to section: Section) {
        history.removeAll()
        activeSection = section
    }
}
