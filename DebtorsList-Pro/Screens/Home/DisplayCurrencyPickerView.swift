

import SwiftUI

struct DisplayCurrencyPickerView: View {

    @Binding var selectedCurrency: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(CurrencyCatalog.all) { option in
                Button {
                    selectedCurrency = option.id
                    dismiss()
                } label: {
                    HStack {
                        Text(option.flag)
                        Text("\(option.id) — \(option.name)")
                            .foregroundStyle(AppTheme.textPrimary)
                        Spacer()
                        if selectedCurrency == option.id {
                            Image(systemName: "checkmark")
                                .foregroundStyle(AppTheme.primary)
                        }
                    }
                }
                .listRowBackground(AppTheme.surface)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("Display Currency")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
