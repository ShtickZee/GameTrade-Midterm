import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct Theme {
    // MARK: - Dark Gaming Surfaces (Steam & Cyberpunk Inspired)
    static let background = Color(hex: "0B0E17")       // Deep Obsidian Black
    static let surface = Color(hex: "141824")          // Dark Matter Card Background
    static let surfaceElevated = Color(hex: "1E2337")  // Midnight Slate (Search, Headers)
    static let border = Color(hex: "282F48")           // 1px Cyber Border Hairline

    // MARK: - Core Accent Colors (Purple, Indigo, Blue, White)
    static let primary = Color(hex: "7C3AED")          // Electric Royal Purple
    static let primaryLight = Color(hex: "7C3AED").opacity(0.15)
    static let indigo = Color(hex: "4338CA")           // Deep Royal Indigo
    static let cyberBlue = Color(hex: "38BDF8")        // Steam / Cyber Action Blue
    static let neonGreen = Color(hex: "10B981")        // Steam Discount Badge Green

    // MARK: - High Contrast Typography
    static let textPrimary = Color(hex: "F8FAFC")      // Crisp White
    static let textSecondary = Color(hex: "94A3B8")    // Muted Silver / Slate
    static let textMuted = Color(hex: "64748B")        // Dark Slate Inactive

    // MARK: - Platform Identity Colors
    static let playstation = Color(hex: "00439C")
    static let xbox = Color(hex: "107C10")
    static let nintendo = Color(hex: "E60012")

    // MARK: - Premium Gaming Gradients
    static let heroGradient = LinearGradient(
        colors: [Color(hex: "7C3AED"), Color(hex: "4338CA"), Color(hex: "0284C7")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let buttonGradient = LinearGradient(
        colors: [Color(hex: "7C3AED"), Color(hex: "4F46E5")],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let cyberGradient = LinearGradient(
        colors: [Color(hex: "38BDF8"), Color(hex: "6366F1")],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let cardGradient = LinearGradient(
        colors: [Color(hex: "161A28"), Color(hex: "121522")],
        startPoint: .top,
        endPoint: .bottom
    )
}
