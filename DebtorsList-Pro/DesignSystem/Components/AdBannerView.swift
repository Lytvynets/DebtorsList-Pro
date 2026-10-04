
import SwiftUI
import GoogleMobileAds

struct AdBannerView: View {
    var body: some View {
        AdMobBannerRepresentable()
            .frame(width: 320, height: 50)
            .frame(maxWidth: .infinity)
            .background(AppTheme.surface)
    }
}

private struct AdMobBannerRepresentable: UIViewRepresentable {

    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(adSize: AdSizeBanner)
        banner.adUnitID = AppDefaults.adMobBannerAdUnitID
        banner.rootViewController = Self.topViewController()
        banner.load(Request())
        return banner
    }

    func updateUIView(_ uiView: BannerView, context: Context) {}

    private static func topViewController() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: { $0.isKeyWindow })?
            .rootViewController
    }
}
