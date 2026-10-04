
import SwiftUI

struct AvatarView: View {

    let initials: String
    var size: CGFloat = 44

    var body: some View {
        Circle()
            .fill(AppTheme.primary.opacity(0.25))
            .frame(width: size, height: size)
            .overlay(
                Text(initials)
                    .font(.system(size: size * 0.38, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.primary)
            )
    }
}
