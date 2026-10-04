

import SwiftUI
import SwiftData

struct HomeView: View {

    @Query(sort: \Debtor.createdAt, order: .reverse) private var debtors: [Debtor]

    @EnvironmentObject private var purchaseManager: InAppPurchaseViewModel
    @EnvironmentObject private var currencyService: CurrencyService

    @AppStorage(AppDefaults.displayCurrencyKey) private var displayCurrency: String = "USD"
    @State private var isShowingCurrencyPicker = false
    @State private var isShowingPaywall = false
    @State private var isNonMonetaryExpanded = false

    private var activeMonetaryDebtors: [Debtor] {
        debtors.filter { $0.unitType == .currency && !$0.isSettled }
    }

    private var activeItemDebtors: [Debtor] {
        debtors.filter { $0.unitType == .item && !$0.isSettled }
    }

    private var totalOwedToMe: Double {
        activeMonetaryDebtors
            .filter { $0.direction == .owedToMe }
            .reduce(0) { $0 + currencyService.convert($1.remainingAmount, from: $1.currencyCode ?? displayCurrency, to: displayCurrency) }
    }

    private var totalIOwe: Double {
        activeMonetaryDebtors
            .filter { $0.direction == .iOwe }
            .reduce(0) { $0 + currencyService.convert($1.remainingAmount, from: $1.currencyCode ?? displayCurrency, to: displayCurrency) }
    }

    private var recentDebtors: [Debtor] {
        Array(debtors.prefix(4))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header

                    HStack(spacing: 12) {
                        BalanceCard(title: "They owe you", amount: totalOwedToMe, currencyCode: displayCurrency, gradient: AppTheme.successGradient, isPositiveDirection: true)
                        BalanceCard(title: "You owe", amount: totalIOwe, currencyCode: displayCurrency, gradient: AppTheme.dangerGradient, isPositiveDirection: false)
                    }

                    HStack(spacing: 6) {
                        Text("Net balance:")
                            .foregroundStyle(AppTheme.textSecondary)
                        Text(totalOwedToMe - totalIOwe, format: .currency(code: displayCurrency))
                            .fontWeight(.semibold)
                            .foregroundStyle((totalOwedToMe - totalIOwe) >= 0 ? AppTheme.success : AppTheme.danger)
                    }
                    .font(.bodyText)

                    if !activeItemDebtors.isEmpty {
                        nonMonetarySection
                    }

                    HStack {
                        Text("Recent")
                            .font(.cardTitle)
                            .foregroundStyle(AppTheme.textPrimary)
                        Spacer()
                    }

                    if recentDebtors.isEmpty {
                        EmptyStateView(
                            systemImage: "tray",
                            title: "Nothing here yet",
                            message: "Add your first debtor to get started."
                        )
                    } else {
                        VStack(spacing: 10) {
                            ForEach(recentDebtors, id: \.id) { debtor in
                                NavigationLink {
                                    DebtorDetailView(debtor: debtor)
                                } label: {
                                    DebtorRow(debtor: debtor, displayCurrency: displayCurrency)
                                }
                            }
                        }
                    }
                }
                .padding()
                .padding(.bottom, 60) 
                }
                .scrollIndicators(.hidden)

                if !purchaseManager.isPro {
                    AdBannerView()
                }
            }
            .background(AppTheme.background.ignoresSafeArea())
            .task {
                await currencyService.refreshRatesIfNeeded()
                syncDerivedData()
            }
            .onChange(of: totalOwedToMe) { _, _ in syncDerivedData() }
            .onChange(of: totalIOwe) { _, _ in syncDerivedData() }
            .onChange(of: purchaseManager.isPro) { _, _ in syncDerivedData() }
            .sheet(isPresented: $isShowingCurrencyPicker) {
                DisplayCurrencyPickerView(selectedCurrency: $displayCurrency)
            }
            .fullScreenCover(isPresented: $isShowingPaywall) {
                PaywallView(onClose: { isShowingPaywall = false })
            }
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Good \(greeting()) 👋")
                    .font(.screenTitle)
                    .foregroundStyle(AppTheme.textPrimary)
                Text(Date.now.formatted(date: .complete, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(AppTheme.textSecondary)
            }
            Spacer()
            Button {
                if purchaseManager.isPro {
                    isShowingCurrencyPicker = true
                } else {
                    isShowingPaywall = true
                }
            } label: {
                HStack(spacing: 6) {
                    Text(displayCurrency)
                    Image(systemName: purchaseManager.isPro ? "chevron.down" : "lock.fill")
                }
                .font(.caption)
                .foregroundStyle(AppTheme.textPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(AppTheme.surface)
                .clipShape(Capsule())
            }
        }
    }

    private var nonMonetarySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                withAnimation { isNonMonetaryExpanded.toggle() }
            } label: {
                HStack {
                    Text("🍺")
                    Text("Non-monetary debts")
                        .foregroundStyle(AppTheme.textPrimary)
                    Spacer()
                    Text("\(activeItemDebtors.count)")
                        .font(.caption)
                        .foregroundStyle(AppTheme.textSecondary)
                    Image(systemName: isNonMonetaryExpanded ? "chevron.up" : "chevron.down")
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }

            if isNonMonetaryExpanded {
                ForEach(activeItemDebtors, id: \.id) { debtor in
                    NavigationLink {
                        DebtorDetailView(debtor: debtor)
                    } label: {
                        HStack {
                            Text(debtor.itemEmoji ?? "")
                            Text(debtor.name)
                                .foregroundStyle(AppTheme.textPrimary)
                            Spacer()
                            Text("\(Int(debtor.remainingAmount)) \(debtor.itemName ?? "")")
                                .foregroundStyle(debtor.direction == .owedToMe ? AppTheme.success : AppTheme.danger)
                        }
                    }
                }
            }
        }
        .padding()
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func greeting() -> String {
        switch Calendar.current.component(.hour, from: .now) {
        case 5..<12: return "morning"
        case 12..<17: return "afternoon"
        default: return "evening"
        }
    }


    private func syncDerivedData() {
        WidgetDataBridge.updateSnapshot(
            owedToMe: totalOwedToMe,
            iOwe: totalIOwe,
            currencyCode: displayCurrency,
            isPro: purchaseManager.isPro
        )
    }
}
