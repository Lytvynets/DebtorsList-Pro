

import SwiftUI

struct LockScreenView: View {

    @EnvironmentObject private var appLock: AppLockManager

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "checklist")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)
                    .foregroundStyle(AppTheme.primary)

                Image(systemName: "faceid")
                    .font(.system(size: 40))
                    .foregroundStyle(AppTheme.textSecondary)

                Text("Tap to unlock")
                    .font(.bodyText)
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { appLock.authenticate() }
    }
}
