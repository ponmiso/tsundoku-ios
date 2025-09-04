import Foundation
import UIKit

@MainActor
final class ShortcutActionState: ObservableObject {
    static let shared = ShortcutActionState()
    private init() {}

    @Published var shortcutItem: ShortcutItem?
}

extension ShortcutActionState {
    func setShortcutItem(from item: UIApplicationShortcutItem?) {
        guard let item, let shortcutItem = ShortcutItem(rawValue: item.type) else {
            shortcutItem = nil
            return
        }
        self.shortcutItem = shortcutItem
    }
}
