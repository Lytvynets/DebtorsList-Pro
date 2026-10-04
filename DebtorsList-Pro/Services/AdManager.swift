

import Foundation
import UIKit
import GoogleMobileAds
import Combine

@MainActor
final class AdManager: NSObject, ObservableObject {


    @Published private(set) var isInterstitialReady = false

    private var interstitialAd: InterstitialAd?
    private var pendingCompletion: (() -> Void)?
    private var isInterstitialPending = false

    override init() {
        super.init()
        MobileAds.shared.start(completionHandler: nil)
        Task { await preloadInterstitial() }
    }


    func preloadInterstitial() async {
        do {
            let ad = try await InterstitialAd.load(
                with: AppDefaults.adMobInterstitialAdUnitID,
                request: Request()
            )
            ad.fullScreenContentDelegate = self
            interstitialAd = ad
            isInterstitialReady = true
        } catch {
            print("AdManager: interstitial failed to load — \(error.localizedDescription)")
            interstitialAd = nil
            isInterstitialReady = false
        }
    }


    func showInterstitial(completion: @escaping () -> Void) {
        guard let interstitialAd, let rootViewController = Self.topViewController() else {
            completion()
            return
        }
        pendingCompletion = completion
        interstitialAd.present(from: rootViewController)
    }


    func requestInterstitialAfterDismiss() {
        isInterstitialPending = true
    }


    func showInterstitialIfRequested() {
        guard isInterstitialPending else { return }
        isInterstitialPending = false
        showInterstitial {}
    }


    private static func topViewController() -> UIViewController? {
        guard let root = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?
            .rootViewController else {
            return nil
        }
        return frontmost(from: root)
    }

    private static func frontmost(from viewController: UIViewController) -> UIViewController {
        if let presented = viewController.presentedViewController {
            return frontmost(from: presented)
        }
        if let nav = viewController as? UINavigationController, let visible = nav.visibleViewController {
            return frontmost(from: visible)
        }
        if let tab = viewController as? UITabBarController, let selected = tab.selectedViewController {
            return frontmost(from: selected)
        }
        return viewController
    }
}

extension AdManager: FullScreenContentDelegate {

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        finishPresenting()
    }

    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("AdManager: interstitial failed to present — \(error.localizedDescription)")
        finishPresenting()
    }

    private func finishPresenting() {
        interstitialAd = nil
        isInterstitialReady = false
        let completion = pendingCompletion
        pendingCompletion = nil
        completion?()
        Task { await preloadInterstitial() } 
    }
}
