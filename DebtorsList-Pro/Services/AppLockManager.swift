
import Foundation
import LocalAuthentication
import Combine

@MainActor
final class AppLockManager: ObservableObject {

    @Published var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: AppDefaults.appLockEnabledKey)
        }
    }

    @Published private(set) var isUnlocked: Bool

    init() {
        let enabled = UserDefaults.standard.bool(forKey: AppDefaults.appLockEnabledKey)
        isEnabled = enabled
        isUnlocked = !enabled
    }

    func lock() {
        guard isEnabled else { return }
        isUnlocked = false
    }

    func authenticate() {
        guard isEnabled, !isUnlocked else {
            isUnlocked = true
            return
        }

        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            isUnlocked = true
            return
        }

        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Unlock Debtors List Pro") { [weak self] success, _ in
            Task { @MainActor in
                self?.isUnlocked = success
            }
        }
    }
}
