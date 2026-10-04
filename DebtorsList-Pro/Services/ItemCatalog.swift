

import Foundation

struct ItemOption: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let emoji: String
}

enum ItemCatalog {
    static let presets: [ItemOption] = [
        ItemOption(name: "Beer", emoji: "🍺"),
        ItemOption(name: "Pizza", emoji: "🍕"),
        ItemOption(name: "Coffee", emoji: "☕"),
        ItemOption(name: "Gift", emoji: "🎁"),
        ItemOption(name: "Service", emoji: "🔧"),
        ItemOption(name: "Purchase", emoji: "🛍️"),
        ItemOption(name: "Fuel", emoji: "🚗"),
        ItemOption(name: "Study", emoji: "📚")
    ]
}
