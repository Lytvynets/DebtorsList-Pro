

import Foundation
import SwiftData

@Model
final class Payment {

    var id: UUID = UUID()
    var amount: Double = 0
    var date: Date = Date.now
    var note: String?
    var debtor: Debtor?

    init(amount: Double, date: Date = .now, note: String? = nil, debtor: Debtor? = nil) {
        self.amount = amount
        self.date = date
        self.note = note
        self.debtor = debtor
    }
}
