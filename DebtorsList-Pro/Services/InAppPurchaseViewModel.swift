

import Foundation
import StoreKit
import Combine

@MainActor
class InAppPurchaseViewModel: ObservableObject {

    @Published var product: Product?
    @Published var isPro = false
    @Published var isLoading = false
    @Published var presentErrorAlert = false
    @Published var errorMessage: String?

    private var transactionListenerTask: Task<Void, Never>?

    init() {
        transactionListenerTask = listenForTransactionUpdates()
    }

    deinit {
        transactionListenerTask?.cancel()
    }

    func fetchProduct() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let products = try await Product.products(for: [AppDefaults.lifetimeProProductId])
            product = products.first
            if let product {
                AppDefaults.lifetimeProPrice = product.displayPrice
            }
        } catch {
            print("Error loading product: \(error)")
            errorMessage = error.localizedDescription
            presentErrorAlert = true
        }
    }

    func purchase() async {
        guard let product else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    print("Purchase successful: \(transaction.productID)")
                    setIsPro(true)
                    await transaction.finish()
                case .unverified(_, let error):
                    print("Unverified purchase: \(error)")
                    errorMessage = error.localizedDescription
                    presentErrorAlert = true
                }
            case .userCancelled:
                print("User cancelled the purchase")
            case .pending:
                print("Purchase is pending approval")
            @unknown default:
                break
            }
        } catch {
            print("Purchase error: \(error)")
            errorMessage = error.localizedDescription
            presentErrorAlert = true
        }
    }

    func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await AppStore.sync()
            await refreshEntitlements()
        } catch {
            print("Restore error: \(error)")
            errorMessage = error.localizedDescription
            presentErrorAlert = true
        }
    }


    func refreshEntitlements() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == AppDefaults.lifetimeProProductId,
               transaction.revocationDate == nil {
                setIsPro(true)
                return
            }
        }
        setIsPro(false)
    }


    private func setIsPro(_ value: Bool) {
        isPro = value
        UserDefaults.standard.set(value, forKey: AppDefaults.cachedIsProKey)
    }

    private func listenForTransactionUpdates() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    if transaction.productID == AppDefaults.lifetimeProProductId {
                        await self?.refreshEntitlements()
                    }
                }
            }
        }
    }
}
