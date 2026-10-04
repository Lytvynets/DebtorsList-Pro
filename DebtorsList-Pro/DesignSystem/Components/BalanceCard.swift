

import SwiftUI

struct BalanceCard: View {

    let title: String
    let amount: Double
    let currencyCode: String
    let gradient: LinearGradient
    let isPositiveDirection: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.85))
                Spacer()
                Image(systemName: isPositiveDirection ? "arrow.up" : "arrow.down")
                    .foregroundStyle(.white.opacity(0.85))
            }

            Text(amount, format: .currency(code: currencyCode))
                .font(.balanceDisplay)
                .foregroundStyle(.white)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(gradient)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
