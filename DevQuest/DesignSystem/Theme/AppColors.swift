import SwiftUI

enum AppColors {
    static let primary = Color(hex: 0x7C3AED)
    static let primaryLight = Color(hex: 0xA78BFA)
    static let primaryDark = Color(hex: 0x4C1D95)
    static let accent = Color(hex: 0xF43F5E)
    static let accentGold = Color(hex: 0xFBBF24)
    static let neonCyan = Color(hex: 0x00FFFF)
    static let neonGreen = Color(hex: 0x10B981)
    static let backgroundPrimary = Color(hex: 0x0F0F23)
    static let backgroundSecondary = Color(hex: 0x1A1A2E)
    static let backgroundTertiary = Color(hex: 0x16213E)
    static let textPrimary = Color(hex: 0xE2E8F0)
    static let textSecondary = Color(hex: 0x94A3B8)
    static let textTertiary = Color(hex: 0x64748B)
    static let success = Color(hex: 0x10B981)
    static let warning = Color(hex: 0xF59E0B)
    static let error = Color(hex: 0xEF4444)
    static let info = Color(hex: 0x3B82F6)
    static let border = Color(hex: 0x4C1D95).opacity(0.3)
    static let borderLight = Color.white.opacity(0.08)

    static let primaryGradient = LinearGradient(colors: [primary, Color(hex: 0xA855F7)], startPoint: .topLeading, endPoint: .bottomTrailing)
    static let accentGradient = LinearGradient(colors: [accent, Color(hex: 0xEC4899)], startPoint: .topLeading, endPoint: .bottomTrailing)
    static let backgroundGradient = LinearGradient(colors: [backgroundPrimary, Color(hex: 0x0A0A1A)], startPoint: .top, endPoint: .bottom)
    static let neonGradient = LinearGradient(colors: [neonCyan, primary], startPoint: .leading, endPoint: .trailing)

    static let statColors: [Color] = [
        Color(hex: 0xEF4444), Color(hex: 0x3B82F6), Color(hex: 0x10B981),
        Color(hex: 0xF59E0B), Color(hex: 0x8B5CF6), Color(hex: 0xEC4899)
    ]
}

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(.sRGB, red: Double((hex >> 16) & 0xFF) / 255.0, green: Double((hex >> 8) & 0xFF) / 255.0, blue: Double(hex & 0xFF) / 255.0, opacity: alpha)
    }
}