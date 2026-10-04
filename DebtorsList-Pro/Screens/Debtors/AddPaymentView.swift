

import SwiftUI
import SwiftData

struct AddPaymentView: View {

    let debtor: Debtor

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var amountText = ""
    @State private var date = Date.now
    @State private var note = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Amount") {
                    TextField("0.00", text: $amountText)
                        .keyboardType(.decimalPad)
                }
                Section("Date") {
                    DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                }
                Section("Note (optional)") {
                    TextField("Add a note...", text: $note)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Add Payment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(Double(amountText.replacingOccurrences(of: ",", with: ".")) == nil)
                }
            }
        }
    }

    private func save() {
        guard let amount = Double(amountText.replacingOccurrences(of: ",", with: ".")) else { return }

        let payment = Payment(amount: amount, date: date, note: note.isEmpty ? nil : note, debtor: debtor)
        modelContext.insert(payment)

        if debtor.remainingAmount - amount <= 0 {
            debtor.isSettled = true
        }

        dismiss()
    }
}
