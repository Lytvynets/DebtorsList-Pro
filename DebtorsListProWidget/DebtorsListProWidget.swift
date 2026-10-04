

import WidgetKit
import SwiftUI


private let appGroupID = "group.com.vlad.debtorslistpro"
private let summaryStorageKey = "debtorsSummary"

private struct DebtorsSummary: Codable {
    let totalOwedToMe: Double
    let totalIOwe: Double
    let currencyCode: String
    let isPro: Bool
    let lastUpdated: Date
}

private func loadSummary() -> DebtorsSummary? {
    guard let defaults = UserDefaults(suiteName: appGroupID),
          let data = defaults.data(forKey: summaryStorageKey),
          let summary = try? JSONDecoder().decode(DebtorsSummary.self, from: data) else {
        return nil
    }
    return summary
}


private extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var rgbValue: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&rgbValue)
        let red = Double((rgbValue & 0xFF0000) >> 16) / 255
        let green = Double((rgbValue & 0x00FF00) >> 8) / 255
        let blue = Double(rgbValue & 0x0000FF) / 255
        self.init(red: red, green: green, blue: blue)
    }
}

private enum WidgetTheme {
    static let primary = Color(hex: "6C67FF")
    static let gold = Color(hex: "FBBF24")
    static let success = Color(hex: "22C55E")
    static let danger = Color(hex: "FB7185")
    static let background = Color(hex: "0E0F14")
    static let textPrimary = Color(hex: "F5F6FA")
    static let textSecondary = Color(hex: "9298A8")
}


private struct DebtorsWidgetEntry: TimelineEntry {
    let date: Date
    let summary: DebtorsSummary?
}

private struct DebtorsWidgetProvider: TimelineProvider {
    
    func placeholder(in context: Context) -> DebtorsWidgetEntry {
        DebtorsWidgetEntry(
            date: .now,
            summary: DebtorsSummary(totalOwedToMe: 1240, totalIOwe: 320, currencyCode: "USD", isPro: true, lastUpdated: .now)
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (DebtorsWidgetEntry) -> Void) {
        completion(DebtorsWidgetEntry(date: .now, summary: loadSummary()))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<DebtorsWidgetEntry>) -> Void) {
        let entry = DebtorsWidgetEntry(date: .now, summary: loadSummary())
        let nextRefresh = Calendar.current.date(byAdding: .hour, value: 4, to: .now) ?? .now
        completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
    }
}


private struct DebtorsWidgetEntryView: View {
    
    @Environment(\.widgetFamily) private var family
    let entry: DebtorsWidgetEntry
    
    var body: some View {
        if let summary = entry.summary {
            if summary.isPro {
                switch family {
                case .systemMedium:
                    mediumView(summary)
                default:
                    smallView(summary)
                }
            } else {
                lockedView
            }
        } else {
            noDataView
        }
    }
    
    private func smallView(_ summary: DebtorsSummary) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            titleRow
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Owes you").font(.caption2).foregroundStyle(WidgetTheme.textSecondary)
                HStack(spacing: 4) {
                    Text(summary.totalOwedToMe, format: .currency(code: summary.currencyCode))
                        .font(.system(.title3, design: .rounded, weight: .bold))
                        .foregroundStyle(WidgetTheme.success)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                    Image(systemName: "arrow.up.circle.fill")
                        .foregroundStyle(WidgetTheme.success)
                }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("You owe").font(.caption2).foregroundStyle(WidgetTheme.textSecondary)
                HStack(spacing: 4) {
                    Text(summary.totalIOwe, format: .currency(code: summary.currencyCode))
                        .font(.system(.title3, design: .rounded, weight: .bold))
                        .foregroundStyle(WidgetTheme.danger)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                    Image(systemName: "arrow.down.circle.fill")
                        .foregroundStyle(WidgetTheme.danger)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .containerBackground(WidgetTheme.background, for: .widget)
    }
    
    private func mediumView(_ summary: DebtorsSummary) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            titleRow
            
            HStack(spacing: 28) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Owes you").font(.caption2).foregroundStyle(WidgetTheme.textSecondary)
                    Text(summary.totalOwedToMe, format: .currency(code: summary.currencyCode))
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .foregroundStyle(WidgetTheme.success)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("You owe").font(.caption2).foregroundStyle(WidgetTheme.textSecondary)
                    Text(summary.totalIOwe, format: .currency(code: summary.currencyCode))
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .foregroundStyle(WidgetTheme.danger)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                }
                Spacer()
            }
            
            Divider()
            
            HStack {
                Text("Net balance")
                    .font(.caption)
                    .foregroundStyle(WidgetTheme.textSecondary)
                Spacer()
                let net = summary.totalOwedToMe - summary.totalIOwe
                Text(net, format: .currency(code: summary.currencyCode))
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundStyle(net >= 0 ? WidgetTheme.success : WidgetTheme.danger)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .containerBackground(WidgetTheme.background, for: .widget)
    }
    
    private var titleRow: some View {
        HStack(spacing: 4) {
            Text("Debtors List")
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .foregroundStyle(WidgetTheme.textPrimary)
                .lineLimit(1)
            Text("Pro")
                .font(.system(.caption2, weight: .bold))
                .foregroundStyle(WidgetTheme.gold)
        }
    }
    
    private var lockedView: some View {
        VStack(spacing: 8) {
            Image(systemName: "lock.fill")
                .foregroundStyle(WidgetTheme.gold)
            Text("Unlock Pro for the widget")
                .font(.caption2)
                .multilineTextAlignment(.center)
                .foregroundStyle(WidgetTheme.textSecondary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(WidgetTheme.background, for: .widget)
    }
    
    
    private var noDataView: some View {
        VStack(spacing: 8) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .foregroundStyle(WidgetTheme.textSecondary)
            Text("Open Debtors List Pro to sync")
                .font(.caption2)
                .multilineTextAlignment(.center)
                .foregroundStyle(WidgetTheme.textSecondary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(WidgetTheme.background, for: .widget)
    }
}


struct DebtorsListProWidget: Widget {
    let kind = "DebtorsListProWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DebtorsWidgetProvider()) { entry in
            DebtorsWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Debtors List")
        .description("See who owes you and who you owe at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct DebtorsListProWidgetBundle: WidgetBundle {
    var body: some Widget {
        DebtorsListProWidget()
    }
}
