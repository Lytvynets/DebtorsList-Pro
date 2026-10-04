

import SwiftUI
import SwiftData

@main
struct DebtorsListProApp: App {

    @StateObject private var purchaseManager = InAppPurchaseViewModel()
    @StateObject private var currencyService = CurrencyService()
    @StateObject private var appState = AppState()
    @StateObject private var appLock = AppLockManager()
    @StateObject private var cloudKitSyncMonitor = CloudKitSyncMonitor()
    @StateObject private var adManager = AdManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(purchaseManager)
                .environmentObject(currencyService)
                .environmentObject(appState)
                .environmentObject(appLock)
                .environmentObject(cloudKitSyncMonitor)
                .environmentObject(adManager)
                .preferredColorScheme(.dark)
        }
        .modelContainer(AppModelContainer.shared)
    }
}


enum AppModelContainer {

    static let shared: ModelContainer = {
        let schema = Schema([Debtor.self, Payment.self])

        let configuration = ModelConfiguration(
            schema: schema,
            cloudKitDatabase: CloudKitAvailability.isEnabledThisSession ? .automatic : .none
        )

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
}


enum CloudKitAvailability {
    static let isEnabledThisSession: Bool = UserDefaults.standard.bool(forKey: AppDefaults.cachedIsProKey)
}
