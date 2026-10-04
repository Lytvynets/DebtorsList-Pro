

import Foundation

enum AppDefaults {

    static let lifetimeProProductId = "pro.lifetime.debtorslistpro"
    static var lifetimeProPrice = "-"

    static let termsOfUseURL = "https://docs.google.com/document/d/1-1KNCHQs4KXWKKvhXI69N75Jiak7_jE_/edit?usp=share_link&ouid=114599015370342281433&rtpof=true&sd=true"
    static let privacyPolicyURL = "https://docs.google.com/document/d/188-ImDh_URZLPkiwS27OnzWxrd_HEZQ8/edit?usp=share_link&ouid=114599015370342281433&rtpof=true&sd=true"
    static let supportURL = "https://docs.google.com/document/d/1DOZmv3JglsQbA0HhtmkNXMULMFg2TkN-/edit?usp=share_link&ouid=114599015370342281433&rtpof=true&sd=true"
    static let appStoreURL = "https://apps.apple.com/app/id0000000000"
    static let email = "vladlytvynets7@gmail.com"
    static let otherAppsURL = "https://apps.apple.com/developer/id6809227046"
    static var writeReviewURL: String { "\(appStoreURL)?action=write-review" }

    static let freeDebtorLimit = 5
   
    static let adMobAppID = "ca-app-pub-4749079164629106~9324707660"
    static let adMobBannerAdUnitID = "ca-app-pub-4749079164629106/5019113649"
    static let adMobInterstitialAdUnitID = "ca-app-pub-4749079164629106/4827541955"

    static let hasCompletedOnboardingKey = "hasCompletedOnboarding"
    static let displayCurrencyKey = "displayCurrency"
    static let reminderMessageTemplateKey = "reminderMessageTemplate"
    static let reminderHourKey = "reminderHour"
    static let reminderWeekdayKey = "reminderWeekday"
    static let appLockEnabledKey = "appLockEnabled"
    static let cachedIsProKey = "cachedIsPro"
}
