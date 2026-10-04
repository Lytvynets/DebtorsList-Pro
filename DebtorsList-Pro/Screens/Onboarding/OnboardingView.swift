

import SwiftUI

private struct OnboardingPage {
    let systemImage: String
    let title: String
    let subtitle: String
}

private let onboardingPages: [OnboardingPage] = [
    OnboardingPage(
        systemImage: "onb1",
        title: "Who owes you,\nand who you owe",
        subtitle: "Keep all your debts in one\nconvenient list. Money you've\nlent or borrowed."
    ),
    OnboardingPage(
        systemImage: "onb2",
        title: "Any currency.\nAny debt",
        subtitle: "Hryvnia, dollar, euro — choose\nyour currency. You can even\ntrack a debt in beer 🍺"
    ),
    OnboardingPage(
        systemImage: "onb3",
        title: "We'll remind you\nso you don't forget",
        subtitle: "Set a reminder for the right day —\nand send a polite nudge to your\ndebtor in one tap."
    ),
    OnboardingPage(
        systemImage: "onb4",
        title: "Your data —\nyours only",
        subtitle: "Face ID protection and iCloud\nsync across all your\ndevices."
    )
]

struct OnboardingView: View {

    let onFinish: () -> Void

    @State private var currentPage = 0

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            TabView(selection: $currentPage) {
                ForEach(Array(onboardingPages.enumerated()), id: \.offset) { index, page in
                    OnboardingPageView(page: page)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            VStack {
                HStack {
                    Spacer()
                    if currentPage < onboardingPages.count - 1 {
                        Button("Skip", action: onFinish)
                            .font(.bodyText)
                            .foregroundStyle(AppTheme.primary)
                            .padding()
                    }
                }
                Spacer()
            }

            VStack {
                Spacer()
                PageIndicator(numberOfPages: onboardingPages.count, currentPage: currentPage)
                    .padding(.bottom, 16)

                PrimaryButton(
                    title: currentPage == onboardingPages.count - 1 ? "Get Started" : "Next"
                ) {
                    advance()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
    }

    private func advance() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        if currentPage < onboardingPages.count - 1 {
            withAnimation { currentPage += 1 }
        } else {
            onFinish()
        }
    }
}

private struct OnboardingPageView: View {

    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(page.systemImage)
                .resizable()
                .scaledToFit()

            Text(page.title)
                .font(.screenTitle)
                .foregroundStyle(AppTheme.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(height: 76)
                .padding(.horizontal, 32)

            Text(page.subtitle)
                .font(.bodyText)
                .foregroundStyle(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .frame(height: 72)
                .padding(.horizontal, 32)

            Spacer()
            Spacer()
        }
    }
}

private struct PageIndicator: View {

    let numberOfPages: Int
    let currentPage: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<numberOfPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? AppTheme.primary : AppTheme.divider)
                    .frame(width: 8, height: 8)
            }
        }
    }
}


#Preview {
    OnboardingView {
        print("")
    }
}
