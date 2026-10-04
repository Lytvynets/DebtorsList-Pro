
import SwiftUI

struct EmptyStateView: View {

    let systemImage: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 44))
                .foregroundStyle(AppTheme.textSecondary)

            Text(title)
                .font(.cardTitle)
                .foregroundStyle(AppTheme.textPrimary)

            Text(message)
                .font(.bodyText)
                .foregroundStyle(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .frame(maxWidth: .infinity)
    }
}
