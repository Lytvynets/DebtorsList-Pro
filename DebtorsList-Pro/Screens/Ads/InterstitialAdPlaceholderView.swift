

import SwiftUI

struct InterstitialAdPlaceholderView: View {

    let onDismiss: () -> Void

    @State private var secondsRemaining = 3

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 18) {
                Image(systemName: "megaphone.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.white)

                Text("Ad")
                    .font(.title2.bold())
                    .foregroundStyle(.white)

                Text("PLACEHOLDER — a real interstitial ad will appear here once an ad SDK is wired in.")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                if secondsRemaining > 0 {
                    Text("\(secondsRemaining)")
                        .font(.title.bold())
                        .foregroundStyle(.white)
                        .padding(.top, 8)
                } else {
                    Button("Close", action: onDismiss)
                        .font(.buttonLabel)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 12)
                        .background(AppTheme.primary)
                        .clipShape(Capsule())
                        .padding(.top, 8)
                }
            }
        }
        .task {
            for remaining in stride(from: 3, through: 0, by: -1) {
                secondsRemaining = remaining
                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }
        }
    }
}
