

import SwiftUI

enum AppTheme {

 
    static let primary = Color(hex: "6C67FF")
    static let primaryDeep = Color(hex: "4B45D6")

    static let gold = Color(hex: "FBBF24")
    static let goldLight = Color(hex: "FDE68A")
    static let goldDeep = Color(hex: "F59E0B")

    static let success = Color(hex: "22C55E")
    static let successDeep = Color(hex: "16A34A")
    static let danger = Color(hex: "FB7185")
    static let dangerDeep = Color(hex: "F43F5E")

    static let background = Color(hex: "0E0F14")
    static let surface = Color(hex: "1B1D26")

    static let textPrimary = Color(hex: "F5F6FA")
    static let textSecondary = Color(hex: "9298A8")

    static let divider = Color(hex: "2A2D3A")

    static let iconNeutral = Color(hex: "353845")
    static let splashDeep = Color(hex: "1B1140")
    static let splashVivid = Color(hex: "7C3AED")


    static let successGradient = LinearGradient(
        colors: [success, successDeep],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let dangerGradient = LinearGradient(
        colors: [danger, dangerDeep],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let primaryGradient = LinearGradient(
        colors: [primary, primaryDeep],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let goldGradient = LinearGradient(
        colors: [goldLight, gold, goldDeep],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let splashGradient = LinearGradient(
        colors: [splashVivid, splashDeep],
        startPoint: .top,
        endPoint: .bottom
    )

    static let chartPalette: [Color] = [success, primary, danger, goldDeep, Color(hex: "60A5FA")]
}
