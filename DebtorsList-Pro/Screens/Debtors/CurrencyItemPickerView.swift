
import SwiftUI

struct CurrencyItemPickerView: View {

    @Binding var unitType: DebtUnitType
    @Binding var currencyCode: String
    @Binding var itemName: String?
    @Binding var itemEmoji: String?

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var purchaseManager: InAppPurchaseViewModel

    @State private var segment: DebtUnitType
    @State private var searchText = ""
    @State private var customItemText = ""
    @State private var isShowingPaywall = false

    init(unitType: Binding<DebtUnitType>, currencyCode: Binding<String>, itemName: Binding<String?>, itemEmoji: Binding<String?>) {
        self._unitType = unitType
        self._currencyCode = currencyCode
        self._itemName = itemName
        self._itemEmoji = itemEmoji
        self._segment = State(initialValue: unitType.wrappedValue)
    }

    private var filteredCurrencies: [CurrencyOption] {
        guard !searchText.isEmpty else { return CurrencyCatalog.all }
        return CurrencyCatalog.all.filter {
            $0.id.localizedCaseInsensitiveContains(searchText) || $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("", selection: $segment) {
                    Text("Currency").tag(DebtUnitType.currency)
                    Text(purchaseManager.isPro ? "Item" : "Item 🔒").tag(DebtUnitType.item)
                }
                .pickerStyle(.segmented)
                .padding()
                .onChange(of: segment) { _, newValue in
                    if newValue == .item && !purchaseManager.isPro {
                        segment = .currency
                        isShowingPaywall = true
                    }
                }

                if segment == .currency {
                    currencyList
                } else {
                    itemGrid
                }

                PrimaryButton(title: "Save") {
                    unitType = segment
                    dismiss()
                }
                .padding()
            }
            .background(AppTheme.background.ignoresSafeArea())
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Choose Currency / Item")
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(isPresented: $isShowingPaywall) {
                PaywallView(onClose: { isShowingPaywall = false })
            }
        }
    }

    private var currencyList: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(AppTheme.textSecondary)
                TextField("Search currency", text: $searchText)
                    .foregroundStyle(AppTheme.textPrimary)
            }
            .padding(10)
            .background(AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .padding(.horizontal)

            List(filteredCurrencies) { option in
                Button {
                    currencyCode = option.id
                } label: {
                    HStack {
                        Text(option.flag)
                        VStack(alignment: .leading) {
                            Text(option.id).foregroundStyle(AppTheme.textPrimary)
                            Text(option.name).font(.caption).foregroundStyle(AppTheme.textSecondary)
                        }
                        Spacer()
                        if currencyCode == option.id {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(AppTheme.primary)
                        }
                    }
                }
                .listRowBackground(AppTheme.background)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
    }

    private var itemGrid: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(ItemCatalog.presets) { preset in
                    Button {
                        itemName = preset.name
                        itemEmoji = preset.emoji
                        customItemText = ""
                    } label: {
                        VStack(spacing: 8) {
                            Text(preset.emoji).font(.system(size: 32))
                            Text(preset.name).font(.caption).foregroundStyle(AppTheme.textPrimary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(itemName == preset.name ? AppTheme.primary.opacity(0.25) : AppTheme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                }
            }
            .padding()

            VStack(alignment: .leading, spacing: 8) {
                Text("Custom item")
                    .font(.caption)
                    .foregroundStyle(AppTheme.textSecondary)
                TextField("Enter item name", text: $customItemText)
                    .foregroundStyle(AppTheme.textPrimary)
                    .padding(10)
                    .background(AppTheme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .onChange(of: customItemText) { _, newValue in
                        guard !newValue.isEmpty else { return }
                        itemName = newValue
                        itemEmoji = "📝"
                    }
            }
            .padding(.horizontal)
        }
    }
}
