import SwiftUI
enum AppTheme {
    static let spacingXS: CGFloat = 4; static let spacingSM: CGFloat = 8; static let spacingMD: CGFloat = 12
    static let spacingLG: CGFloat = 16; static let spacingXL: CGFloat = 24; static let spacingXXL: CGFloat = 32
    static let radiusSM: CGFloat = 8; static let radiusMD: CGFloat = 12; static let radiusLG: CGFloat = 16
    static let radiusXL: CGFloat = 20; static let radiusFull: CGFloat = 100
    static let animationFast = Animation.easeInOut(duration: 0.2)
    static let animationMedium = Animation.easeInOut(duration: 0.35)
    static let animationSlow = Animation.easeInOut(duration: 0.6)
    static let animationSpring = Animation.spring(response: 0.5, dampingFraction: 0.7)
    static let glassOpacity: Double = 0.12; static let glassBlur: CGFloat = 20; static let glassBorderOpacity: Double = 0.15
}