

import SwiftUI

struct SettingsRow<Trailing: View>: View {

    let icon: String
    let iconColor: Color
    let title: String
    var subtitle: String? = nil
    @ViewBuilder var trailing: () -> Trailing

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 34, height: 34)
                .background(iconColor)
                .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.bodyText)
                    .foregroundStyle(AppTheme.textPrimary)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(AppTheme.textSecondary)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 8)

            trailing()
        }
        .padding(.vertical, 8)
    }
}


struct SettingsCard<Content: View>: View {

    var header: String? = nil
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let header {
                Text(header.uppercased())
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(AppTheme.textSecondary)
                    .padding(.leading, 4)
                    .padding(.bottom, 2)
            }

            VStack(spacing: 0) {
                content()
            }
            .padding(.horizontal, 14)
            .background(AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}

struct SettingsRowDivider: View {
    var body: some View {
        Divider()
            .background(AppTheme.divider)
            .padding(.leading, 48)
    }
}
