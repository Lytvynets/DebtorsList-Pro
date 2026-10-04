

import Foundation
import WidgetKit

struct DebtorsSummary: Codable {
    let totalOwedToMe: Double
    let totalIOwe: Double
    let currencyCode: String
    let isPro: Bool
    let lastUpdated: Date
}

enum WidgetDataBridge {

    static let appGroupID = "group.com.example.debtorslistpro"

    private static let storageKey = "debtorsSummary"

    static func updateSnapshot(owedToMe: Double, iOwe: Double, currencyCode: String, isPro: Bool) {
        guard let defaults = UserDefaults(suiteName: appGroupID) else {
            print("WidgetDataBridge: couldn't open App Group \"\(appGroupID)\" — check it's set up in both targets.")
            return
        }

        let summary = DebtorsSummary(
            totalOwedToMe: owedToMe,
            totalIOwe: iOwe,
            currencyCode: currencyCode,
            isPro: isPro,
            lastUpdated: .now
        )

        if let data = try? JSONEncoder().encode(summary) {
            defaults.set(data, forKey: storageKey)
        }

        WidgetCenter.shared.reloadAllTimelines()
    }


    static func forceReloadWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
    }


    static func diagnosticReport() -> String {
        guard let defaults = UserDefaults(suiteName: appGroupID) else {
            return """
            ❌ App Group NOT reachable.
            ID being used: "\(appGroupID)"

            This means either the App Groups capability isn't enabled on \
            BOTH targets in Xcode with this exact ID, or the ID string here \
            doesn't match the one in DebtorsListProWidget.swift.
            """
        }

        guard let data = defaults.data(forKey: storageKey) else {
            return """
            ✅ App Group "\(appGroupID)" is reachable.
            ⚠️ But no snapshot has ever been written yet.

            Open the Home tab once — it writes a snapshot automatically. If \
            you already did and this still says that, the write itself is \
            silently failing; check the Xcode console for a \
            "WidgetDataBridge: couldn't open App Group" message.
            """
        }

        guard let summary = try? JSONDecoder().decode(DebtorsSummary.self, from: data) else {
            return """
            ✅ App Group "\(appGroupID)" is reachable.
            ⚠️ A snapshot exists but failed to decode.

            This shouldn't normally happen — it suggests the stored data was \
            written by a different, incompatible version of DebtorsSummary.
            """
        }

        return """
        ✅ App Group "\(appGroupID)" is reachable.
        ✅ Snapshot found, last written \(summary.lastUpdated.formatted(date: .abbreviated, time: .standard)).

        isPro: \(summary.isPro)
        They owe you: \(summary.totalOwedToMe) \(summary.currencyCode)
        You owe: \(summary.totalIOwe) \(summary.currencyCode)

        If the Home Screen widget still doesn't show this, remove it from \
        the Home Screen and re-add it — widgets sometimes hold onto a stale \
        timeline from before the App Group was working correctly.
        """
    }
}
