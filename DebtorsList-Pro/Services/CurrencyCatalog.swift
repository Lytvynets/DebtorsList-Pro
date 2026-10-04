
import Foundation

struct CurrencyOption: Identifiable, Hashable {
    let id: String
    let name: String
    let flag: String
}

enum CurrencyCatalog {

    static let all: [CurrencyOption] = [
        CurrencyOption(id: "USD", name: "US Dollar", flag: "🇺🇸"),
        CurrencyOption(id: "EUR", name: "Euro", flag: "🇪🇺"),
        CurrencyOption(id: "GBP", name: "British Pound", flag: "🇬🇧"),
        CurrencyOption(id: "UAH", name: "Ukrainian Hryvnia", flag: "🇺🇦"),
        CurrencyOption(id: "PLN", name: "Polish Zloty", flag: "🇵🇱"),
        CurrencyOption(id: "CZK", name: "Czech Koruna", flag: "🇨🇿"),
        CurrencyOption(id: "CAD", name: "Canadian Dollar", flag: "🇨🇦"),
        CurrencyOption(id: "AUD", name: "Australian Dollar", flag: "🇦🇺"),
        CurrencyOption(id: "CHF", name: "Swiss Franc", flag: "🇨🇭"),
        CurrencyOption(id: "JPY", name: "Japanese Yen", flag: "🇯🇵"),
        CurrencyOption(id: "CNY", name: "Chinese Yuan", flag: "🇨🇳"),
        CurrencyOption(id: "INR", name: "Indian Rupee", flag: "🇮🇳"),
        CurrencyOption(id: "BRL", name: "Brazilian Real", flag: "🇧🇷"),
        CurrencyOption(id: "MXN", name: "Mexican Peso", flag: "🇲🇽"),
        CurrencyOption(id: "ZAR", name: "South African Rand", flag: "🇿🇦"),
        CurrencyOption(id: "TRY", name: "Turkish Lira", flag: "🇹🇷"),
        CurrencyOption(id: "SEK", name: "Swedish Krona", flag: "🇸🇪"),
        CurrencyOption(id: "NOK", name: "Norwegian Krone", flag: "🇳🇴"),
        CurrencyOption(id: "DKK", name: "Danish Krone", flag: "🇩🇰"),
        CurrencyOption(id: "HUF", name: "Hungarian Forint", flag: "🇭🇺"),
        CurrencyOption(id: "RON", name: "Romanian Leu", flag: "🇷🇴"),
        CurrencyOption(id: "ILS", name: "Israeli Shekel", flag: "🇮🇱"),
        CurrencyOption(id: "AED", name: "UAE Dirham", flag: "🇦🇪"),
        CurrencyOption(id: "SAR", name: "Saudi Riyal", flag: "🇸🇦"),
        CurrencyOption(id: "SGD", name: "Singapore Dollar", flag: "🇸🇬"),
        CurrencyOption(id: "HKD", name: "Hong Kong Dollar", flag: "🇭🇰"),
        CurrencyOption(id: "KRW", name: "South Korean Won", flag: "🇰🇷"),
        CurrencyOption(id: "NZD", name: "New Zealand Dollar", flag: "🇳🇿"),
        CurrencyOption(id: "THB", name: "Thai Baht", flag: "🇹🇭"),
        CurrencyOption(id: "IDR", name: "Indonesian Rupiah", flag: "🇮🇩"),
        CurrencyOption(id: "MYR", name: "Malaysian Ringgit", flag: "🇲🇾"),
        CurrencyOption(id: "PHP", name: "Philippine Peso", flag: "🇵🇭"),
        CurrencyOption(id: "VND", name: "Vietnamese Dong", flag: "🇻🇳"),
        CurrencyOption(id: "EGP", name: "Egyptian Pound", flag: "🇪🇬"),
        CurrencyOption(id: "NGN", name: "Nigerian Naira", flag: "🇳🇬"),
        CurrencyOption(id: "KES", name: "Kenyan Shilling", flag: "🇰🇪"),
        CurrencyOption(id: "ARS", name: "Argentine Peso", flag: "🇦🇷"),
        CurrencyOption(id: "CLP", name: "Chilean Peso", flag: "🇨🇱"),
        CurrencyOption(id: "COP", name: "Colombian Peso", flag: "🇨🇴"),
        CurrencyOption(id: "GEL", name: "Georgian Lari", flag: "🇬🇪"),
        CurrencyOption(id: "MDL", name: "Moldovan Leu", flag: "🇲🇩")
    ]

    static func name(for code: String) -> String {
        all.first(where: { $0.id == code })?.name ?? code
    }
}
