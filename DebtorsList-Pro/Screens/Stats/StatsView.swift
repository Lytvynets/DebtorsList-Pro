

import SwiftUI
import SwiftData

struct PersonBalance: Identifiable {
    let id = UUID()
    let name: String
    let amount: Double
}

struct StatsView: View {
    
    @Query private var allDebtors: [Debtor]
    
    @EnvironmentObject private var purchaseManager: InAppPurchaseViewModel
    @EnvironmentObject private var currencyService: CurrencyService
    @AppStorage(AppDefaults.displayCurrencyKey) private var displayCurrency: String = "USD"
    
    @State private var isShowingPaywall = false
    
    private var activeMonetaryDebtors: [Debtor] {
        allDebtors.filter { $0.unitType == .currency && !$0.isSettled }
    }
    
    private var byPerson: [PersonBalance] {
        activeMonetaryDebtors
            .map { debtor -> PersonBalance in
                let converted = currencyService.convert(debtor.remainingAmount, from: debtor.currencyCode ?? displayCurrency, to: displayCurrency)
                return PersonBalance(name: debtor.name, amount: converted)
            }
            .sorted { $0.amount > $1.amount }
    }
    
    
    private var chartEntries: [PersonBalance] {
        guard byPerson.count > 4 else { return byPerson }
        let topFour = Array(byPerson.prefix(4))
        let otherTotal = byPerson.dropFirst(4).reduce(0) { $0 + $1.amount }
        return topFour + [PersonBalance(name: "Other", amount: otherTotal)]
    }
    
    private var totalAcrossPeople: Double {
        byPerson.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Stats")
                        .font(.screenTitle)
                        .foregroundStyle(AppTheme.textPrimary)
                    
                    if activeMonetaryDebtors.isEmpty {
                        EmptyStateView(
                            systemImage: "chart.pie",
                            title: "Nothing to show yet",
                            message: "Add a few debtors to see your stats here."
                        )
                    } else if purchaseManager.isPro {
                        proContent
                    } else {
                        lockedContent
                    }
                }
                .padding()
            }
            .background(AppTheme.background.ignoresSafeArea())
        }
        .fullScreenCover(isPresented: $isShowingPaywall) {
            PaywallView(onClose: { isShowingPaywall = false })
        }
    }
    
    private var proContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            donutCard
            topDebtorsCard
        }
    }
    
    private var lockedContent: some View {
        ZStack {
            donutCard
                .blur(radius: 8)
                .allowsHitTesting(false)
            
            VStack(spacing: 16) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(AppTheme.textPrimary)
                Text("Powerful insights await you")
                    .font(.cardTitle)
                    .foregroundStyle(AppTheme.textPrimary)
                Text("Unlock Pro to see statistics, charts and key insights.")
                    .font(.bodyText)
                    .foregroundStyle(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                PrimaryButton(title: "Unlock Pro") {
                    isShowingPaywall = true
                }
                .padding(.horizontal, 40)
            }
        }
    }
    
    private var donutCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Debts by people")
                    .font(.cardTitle)
                    .foregroundStyle(AppTheme.textPrimary)
                Spacer()
                HStack(spacing: 4) {
                    Text("Total:")
                    Text(totalAcrossPeople, format: .currency(code: displayCurrency))
                }
                .font(.caption)
                .foregroundStyle(AppTheme.textSecondary)
            }
            
            HStack(alignment: .center, spacing: 20) {
                ZStack {
                    DonutChartView(
                        values: chartEntries.map(\.amount),
                        colors: (0..<chartEntries.count).map { color(at: $0) }
                    )
                    .frame(width: 150, height: 150)
                    
                    VStack(spacing: 2) {
                        Text(totalAcrossPeople, format: .currency(code: displayCurrency))
                            .font(.system(.callout, design: .rounded, weight: .bold))
                            .foregroundStyle(AppTheme.textPrimary)
                            .minimumScaleFactor(0.6)
                            .lineLimit(1)
                        Text("Total")
                            .font(.caption2)
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    .frame(width: 90)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(Array(chartEntries.enumerated()), id: \.element.id) { index, entry in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(color(at: index))
                                .frame(width: 8, height: 8)
                            Text(entry.name)
                                .font(.caption)
                                .foregroundStyle(AppTheme.textPrimary)
                                .lineLimit(1)
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 0) {
                                Text(entry.amount, format: .currency(code: displayCurrency))
                                    .font(.system(size: 9, weight: .regular, design: .rounded))
                                    .foregroundStyle(AppTheme.textPrimary)
                                Text(percentText(for: entry.amount))
                                    .font(.system(size: 8, weight: .regular, design: .rounded))
                                    .foregroundStyle(AppTheme.textSecondary)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
    
    private var topDebtorsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Top debtors")
                .font(.cardTitle)
                .foregroundStyle(AppTheme.textPrimary)
            
            ForEach(Array(byPerson.prefix(5).enumerated()), id: \.offset) { index, entry in
                HStack {
                    Text("\(index + 1)")
                        .font(.caption)
                        .foregroundStyle(AppTheme.textSecondary)
                        .frame(width: 20)
                    Text(entry.name)
                        .foregroundStyle(AppTheme.textPrimary)
                    Spacer()
                    Text(entry.amount, format: .currency(code: displayCurrency))
                        .foregroundStyle(AppTheme.textPrimary)
                }
            }
        }
        .padding()
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
    
    private func color(at index: Int) -> Color {
        AppTheme.chartPalette[index % AppTheme.chartPalette.count]
    }
    
    private func percentText(for amount: Double) -> String {
        guard totalAcrossPeople > 0 else { return "0%" }
        let percent = (amount / totalAcrossPeople) * 100
        return "\(Int(percent.rounded()))%"
    }
}
