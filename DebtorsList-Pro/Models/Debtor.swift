

import Foundation
import SwiftData

@Model
final class Debtor {

    var id: UUID = UUID()
    var name: String = ""
    var contactIdentifier: String?


    var directionRaw: String = DebtDirection.owedToMe.rawValue
    var unitTypeRaw: String = DebtUnitType.currency.rawValue

    var currencyCode: String? = "USD"
    var itemName: String?
    var itemEmoji: String?

    var originalAmount: Double = 0
    var createdAt: Date = Date.now
    var dueDate: Date?
    var isSettled: Bool = false
    var notes: String?

    @Relationship(deleteRule: .cascade, inverse: \Payment.debtor)
    var payments: [Payment]? = []

    init(
        name: String,
        direction: DebtDirection,
        unitType: DebtUnitType = .currency,
        currencyCode: String? = "USD",
        itemName: String? = nil,
        itemEmoji: String? = nil,
        originalAmount: Double,
        dueDate: Date? = nil,
        notes: String? = nil,
        contactIdentifier: String? = nil
    ) {
        self.name = name
        self.directionRaw = direction.rawValue
        self.unitTypeRaw = unitType.rawValue
        self.currencyCode = currencyCode
        self.itemName = itemName
        self.itemEmoji = itemEmoji
        self.originalAmount = originalAmount
        self.dueDate = dueDate
        self.notes = notes
        self.contactIdentifier = contactIdentifier
    }

    var direction: DebtDirection {
        get { DebtDirection(rawValue: directionRaw) ?? .owedToMe }
        set { directionRaw = newValue.rawValue }
    }

    var unitType: DebtUnitType {
        get { DebtUnitType(rawValue: unitTypeRaw) ?? .currency }
        set { unitTypeRaw = newValue.rawValue }
    }

    var initials: String {
        let letters = name.split(separator: " ").prefix(2).compactMap { $0.first }
        let result = String(letters).uppercased()
        return result.isEmpty ? "?" : result
    }

    var totalPaid: Double {
        (payments ?? []).reduce(0) { $0 + $1.amount }
    }

    var remainingAmount: Double {
        max(originalAmount - totalPaid, 0)
    }

    var isOverdue: Bool {
        guard let dueDate, !isSettled else { return false }
        return dueDate < .now
    }

    var lastActivityDate: Date {
        payments?.map(\.date).max() ?? createdAt
    }
}
