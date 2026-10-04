

import Foundation
import Combine

@MainActor
final class CurrencyService: ObservableObject {


    private let anchorCurrency = "USD"

    @Published private(set) var rates: [String: Double] = [:]
    @Published private(set) var lastUpdated: Date?

    private let ratesCacheKey = "cachedExchangeRates"
    private let dateCacheKey = "cachedExchangeRatesDate"

    init() {
        loadCachedRates()
    }

    func refreshRatesIfNeeded() async {
        let isStale = lastUpdated == nil || !Calendar.current.isDateInToday(lastUpdated!)
        guard isStale else { return }
        await fetchRates()
    }

    func fetchRates() async {
        guard let url = URL(string: "https://api.frankfurter.dev/v2/rates?base=\(anchorCurrency)") else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let rows = try JSONDecoder().decode([FrankfurterV2Row].self, from: data)
            var newRates = Dictionary(uniqueKeysWithValues: rows.map { ($0.quote, $0.rate) })
            newRates[anchorCurrency] = 1.0
            rates = newRates
            lastUpdated = Date()
            cacheRates()
        } catch {
            print("Currency rate refresh failed: \(error.localizedDescription)")
        }
    }


    func convert(_ amount: Double, from: String, to: String) -> Double {
        guard from != to else { return amount }
        guard let rateFrom = rates[from], let rateTo = rates[to], rateFrom > 0 else {
            return amount
        }

        let amountDecimal = Decimal(amount)
        let rateFromDecimal = Decimal(rateFrom)
        let rateToDecimal = Decimal(rateTo)

        let amountInAnchorCurrency = amountDecimal / rateFromDecimal
        let converted = amountInAnchorCurrency * rateToDecimal

        return NSDecimalNumber(decimal: converted).doubleValue
    }


    func hasRate(for code: String) -> Bool {
        rates[code] != nil
    }

    
    private func cacheRates() {
        let defaults = UserDefaults.standard
        if let data = try? JSONEncoder().encode(rates) {
            defaults.set(data, forKey: ratesCacheKey)
        }
        defaults.set(lastUpdated, forKey: dateCacheKey)
    }

    
    private func loadCachedRates() {
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: ratesCacheKey),
           let decoded = try? JSONDecoder().decode([String: Double].self, from: data) {
            rates = decoded
        }
        lastUpdated = defaults.object(forKey: dateCacheKey) as? Date
    }
}

private struct FrankfurterV2Row: Decodable {
    let quote: String
    let rate: Double
}
