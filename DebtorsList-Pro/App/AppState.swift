

import Foundation
import Combine

@MainActor
final class AppState: ObservableObject {

    @Published var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: AppDefaults.hasCompletedOnboardingKey)
        }
    }

    init() {
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: AppDefaults.hasCompletedOnboardingKey)
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
    }
}
