

import SwiftUI
import StoreKit

struct PaywallView: View {

    let onClose: () -> Void

    @EnvironmentObject private var purchaseManager: InAppPurchaseViewModel

    private let features: [(systemImage: String, text: String)] = [
        ("person.2.fill", "Unlimited number of debtors"),
        ("nosign", "No ads"),
        ("calendar.badge.clock", "Deadlines & personalized reminders"),
        ("paperplane.fill", "Remind a debtor in one tap"),
        ("icloud.fill", "iCloud synchronization"),
        ("doc.text.fill", "Export your debts to CSV (opens in Excel)"),
        ("square.grid.2x2.fill", "Home screen widget"),
        ("mug.fill", "Item debts (beer, pizza & custom items)")
    ]

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    Image("crown-glow")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 130, height: 40)
                        .foregroundStyle(AppTheme.goldGradient)
                        .padding(.top)

                    VStack(spacing: 8) {
                        (Text("Debtors List ") + Text("Pro").foregroundColor(AppTheme.gold))
                            .font(.screenTitle)
                            .foregroundStyle(AppTheme.textPrimary)

                        Text("Unlock all features and take full control\nof your debts.")
                            .font(.system(size: 13))
                            .font(.bodyText)
                            .foregroundStyle(AppTheme.textSecondary)
                            .multilineTextAlignment(.center)
                    }

                    VStack(spacing: 0) {
                        ForEach(Array(features.enumerated()), id: \.offset) { index, feature in
                            FeatureRow(systemImage: feature.systemImage, text: feature.text)
                            if index < features.count - 1 {
                                Divider().background(AppTheme.divider)
                            }
                        }
                    }
                    .padding(.horizontal, 16)

                    PriceCard(priceText: purchaseManager.product?.displayPrice ?? AppDefaults.lifetimeProPrice)
                        .padding(.horizontal, 16)

                    GoldButton(title: "Unlock Pro", isLoading: purchaseManager.isLoading) {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        Task { await purchaseManager.purchase() }
                    }
                    .padding(.horizontal, 24)

                    
                    HStack(spacing: 25) {
                        if let termsOfUseURL = URL(string: AppDefaults.termsOfUseURL) {
                            Link("Terms of Use", destination: termsOfUseURL)
                        }
                        
                        if let privacyPolicyURL = URL(string: AppDefaults.privacyPolicyURL) {
                            Link("Privacy Policy", destination: privacyPolicyURL)
                        }
                        
                        Button("Restore") {
                            Task { await purchaseManager.restorePurchases() }
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(AppTheme.primary)
                    .padding(.bottom, 24)
                }
            }
            .scrollIndicators(.hidden)

            VStack {
                HStack {
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .foregroundStyle(AppTheme.textPrimary)
                            .padding(10)
                            .background(AppTheme.surface)
                            .clipShape(Circle())
                    }
                    .padding()
                    Spacer()
                }
                Spacer()
            }
        }
        .alert("Something went wrong", isPresented: $purchaseManager.presentErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(purchaseManager.errorMessage ?? "Please try again.")
        }
        .onChange(of: purchaseManager.isPro) { _, isPro in
            if isPro { onClose() }
        }
    }
}

private struct FeatureRow: View {

    let systemImage: String
    let text: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: systemImage)
                .foregroundStyle(AppTheme.gold)
                .frame(width: 24)
            Text(text)
                .font(.system(size: 14))
                .font(.bodyText)
                .foregroundStyle(AppTheme.textPrimary)
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(AppTheme.gold)
        }
        .padding(.vertical, 12)
    }
}

private struct PriceCard: View {

    let priceText: String

    var body: some View {
        HStack(spacing: 16) {
            Image("badge")
                .resizable()
                .scaledToFit()
                .frame(width: 65, height: 65)
                .foregroundStyle(AppTheme.goldGradient)

            VStack(alignment: .leading, spacing: 4) {
                Text(priceText)
                    .font(.screenTitle)
                    .foregroundStyle(AppTheme.textPrimary)
                Text("One-time payment")
                    .font(.cardTitle)
                    .foregroundStyle(AppTheme.textPrimary)
                Text("Yours forever, no subscription")
                    .font(.caption)
                    .foregroundStyle(AppTheme.textSecondary)
            }
            Spacer()
        }
        .padding(16)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(AppTheme.goldGradient, lineWidth: 1.5)
                .opacity(0.6)
        )
    }
}


private struct GoldButton: View {

    let title: String
    var isLoading: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Text(title)
                    .font(.buttonLabel)
                    .foregroundStyle(AppTheme.background)
                    .opacity(isLoading ? 0 : 1)

                if isLoading {
                    ProgressView()
                        .tint(AppTheme.background)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
        }
        .background(AppTheme.goldGradient)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .disabled(isLoading)
    }
}


#Preview {
    PaywallView(onClose: {})
        .environmentObject(InAppPurchaseViewModel())
}
