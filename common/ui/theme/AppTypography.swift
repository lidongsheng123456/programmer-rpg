import SwiftUI

/// 应用字体排版规范
enum AppTypography {
    static let displayLarge = Font.system(size: 48, weight: .bold, design: .rounded)
    static let displayMedium = Font.system(size: 36, weight: .bold, design: .rounded)
    static let heading1 = Font.system(size: 28, weight: .bold)
    static let heading2 = Font.system(size: 22, weight: .semibold)
    static let heading3 = Font.system(size: 18, weight: .semibold)
    static let bodyLarge = Font.system(size: 17, weight: .regular)
    static let bodyMedium = Font.system(size: 15, weight: .regular)
    static let bodySmall = Font.system(size: 13, weight: .regular)
    static let statLarge = Font.system(size: 32, weight: .bold, design: .monospaced)
    static let statMedium = Font.system(size: 20, weight: .semibold, design: .monospaced)
    static let statSmall = Font.system(size: 14, weight: .medium, design: .monospaced)
    static let caption = Font.system(size: 12, weight: .medium)
    static let captionSmall = Font.system(size: 10, weight: .regular)
    static let label = Font.system(size: 14, weight: .medium)
    static let labelSmall = Font.system(size: 12, weight: .regular)
}