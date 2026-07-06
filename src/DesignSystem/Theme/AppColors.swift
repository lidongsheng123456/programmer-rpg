import SwiftUI

/// Gaming RPG color palette: Deep dark background + neon accents
/// Based on ui-ux-pro-max: Gaming #7C3AED/#F43F5E + Cyberpunk neon
enum AppColors {
    // MARK: - Primary Palette
    static let primary = Color(hex: 0x7C3AED)        // Vivid purple
    static let primaryLight = Color(hex: 0xA78BFA)    // Soft purple
    static let primaryDark = Color(hex: 0x4C1D95)     // Deep purple

    // MARK: - Accent / CTA
    static let accent = Color(hex: 0xF43F5E)          // Rose red (CTA)
    static let accentGold = Color(hex: 0xFBBF24)      // Gold (achievements)
    static let neonCyan = Color(hex: 0x00FFFF)         // Cyberpunk cyan
    static let neonGreen = Color(hex: 0x10B981)        // Status green

    // MARK: - Background
    static let backgroundPrimary = Color(hex: 0x0F0F23)   // Deep dark blue
    static let backgroundSecondary = Color(hex: 0x1A1A2E) // Card background
    static let backgroundTertiary = Color(hex: 0x16213E)  // Elevated surface

    // MARK: - Text
    static let textPrimary = Color(hex: 0xE2E8F0)     // Light gray text
    static let textSecondary = Color(hex: 0x94A3B8)    // Muted gray
    static let textTertiary = Color(hex: 0x64748B)     // Subtle gray

    // MARK: - Semantic
    static let success = Color(hex: 0x10B981)          // Online / healthy
    static let warning = Color(hex: 0xF59E0B)          // Caution
    static let error = Color(hex: 0xEF4444)            // Offline / error
    static let info = Color(hex: 0x3B82F6)             // Info blue

    // MARK: - Border
    static let border = Color(hex: 0x4C1D95).opacity(0.3)
    static let borderLight = Color.white.opacity(0.08)

    // MARK: - Gradients
    static let primaryGradient = LinearGradient(
        colors: [primary, Color(hex: 0xA855F7)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    static let accentGradient = LinearGradient(
        colors: [accent, Color(hex: 0xEC4899)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    static let backgroundGradient = LinearGradient(
        colors: [backgroundPrimary, Color(hex: 0x0A0A1A)],
        startPoint: .top, endPoint: .bottom
    )

    static let neonGradient = LinearGradient(
        colors: [neonCyan, primary],
        startPoint: .leading, endPoint: .trailing
    )

    // MARK: - Stat Colors (for radar chart dimensions)
    static let statColors: [Color] = [
        Color(hex: 0xEF4444), // 攻击 - Red
        Color(hex: 0x3B82F6), // 防御 - Blue
        Color(hex: 0x10B981), // 生命 - Green
        Color(hex: 0xF59E0B), // 智力 - Amber
        Color(hex: 0x8B5CF6), // 敏捷 - Violet
        Color(hex: 0xEC4899), // 声望 - Pink
    ]
}

// MARK: - Color Hex Initializer

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }
}
