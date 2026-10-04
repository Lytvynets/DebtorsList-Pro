

import Foundation

enum DebtDirection: String, Codable, CaseIterable {
    case owedToMe
    case iOwe

    var displayName: String {
        switch self {
        case .owedToMe: return "They owe me"
        case .iOwe: return "I owe"
        }
    }
}

enum DebtUnitType: String, Codable, CaseIterable {
    case currency
    case item
}
