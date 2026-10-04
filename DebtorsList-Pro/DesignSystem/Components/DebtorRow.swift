

import SwiftUI

struct DebtorRow: View {

    let debtor: Debtor
    let displayCurrency: String

    @EnvironmentObject private var currencyService: CurrencyService

    private var displayAmount: Double {
        currencyService.convert(
            debtor.remainingAmount,
            from: debtor.currencyCode ?? displayCurrency,
            to: displayCurrency
        )
    }

    var body: some View {
        HStack(spacing: 12) {
            AvatarView(initials: debtor.initials)

            VStack(alignment: .leading, spacing: 4) {
                Text(debtor.name)
                    .font(.cardTitle)
                    .foregroundStyle(AppTheme.textPrimary)
                Text("Last activity: \(debtor.lastActivityDate.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption)
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            if debtor.unitType == .item {
                Text("\(debtor.itemEmoji ?? "") \(Int(debtor.remainingAmount))")
                    .font(.cardTitle)
                    .foregroundStyle(debtor.direction == .owedToMe ? AppTheme.success : AppTheme.danger)
            } else {
                Text(displayAmount, format: .currency(code: displayCurrency))
                    .font(.cardTitle)
                    .foregroundStyle(debtor.direction == .owedToMe ? AppTheme.success : AppTheme.danger)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(AppTheme.textSecondary)
        }
        .padding(16)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
