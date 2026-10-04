

import SwiftUI

enum RootFlowStep {
    case splash
    case onboarding
    case paywall
    case main
}

struct RootView: View {

    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var purchaseManager: InAppPurchaseViewModel
    @EnvironmentObject private var appLock: AppLockManager
    @Environment(\.scenePhase) private var scenePhase

    @State private var step: RootFlowStep = .splash

    var body: some View {
        Group {
            switch step {
            case .splash:
                SplashView(onFinish: advanceFromSplash)
            case .onboarding:
                OnboardingView(onFinish: advanceFromOnboarding)
            case .paywall:
                PaywallView(onClose: advanceFromPaywall)
            case .main:
                MainTabView()
            }
        }
        .overlay {
            if !appLock.isUnlocked {
                LockScreenView()
            }
        }
        .task {
            await purchaseManager.fetchProduct()
            await purchaseManager.refreshEntitlements()
            if appLock.isEnabled {
                appLock.authenticate()
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .background:
                appLock.lock()
            case .active:
                if appLock.isEnabled, !appLock.isUnlocked {
                    appLock.authenticate()
                }
            default:
                break
            }
        }
    }

    private func advanceFromSplash() {
        step = appState.hasCompletedOnboarding ? nextStepAfterOnboarding() : .onboarding
    }

    private func advanceFromOnboarding() {
        appState.completeOnboarding()
        step = nextStepAfterOnboarding()
    }

    private func nextStepAfterOnboarding() -> RootFlowStep {
        purchaseManager.isPro ? .main : .paywall
    }

    private func advanceFromPaywall() {
        step = .main
    }
}
