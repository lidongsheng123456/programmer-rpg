import SwiftUI

enum AppTheme {
    // MARK: - Spacing
    static let spacingXS: CGFloat = 4
    static let spacingSM: CGFloat = 8
    static let spacingMD: CGFloat = 12
    static let spacingLG: CGFloat = 16
    static let spacingXL: CGFloat = 24
    static let spacingXXL: CGFloat = 32

    // MARK: - Corner Radius
    static let radiusSM: CGFloat = 8
    static let radiusMD: CGFloat = 12
    static let radiusLG: CGFloat = 16
    static let radiusXL: CGFloat = 20
    static let radiusFull: CGFloat = 100

    // MARK: - Shadow
    static let shadowSM = ShadowConfig(color: .black.opacity(0.15), radius: 4, y: 2)
    static let shadowMD = ShadowConfig(color: .black.opacity(0.2), radius: 8, y: 4)
    static let shadowLG = ShadowConfig(color: .black.opacity(0.25), radius: 16, y: 8)
    static let shadowNeon = ShadowConfig(color: AppColors.primary.opacity(0.4), radius: 12, y: 0)

    // MARK: - Animation
    static let animationFast = Animation.easeInOut(duration: 0.2)
    static let animationMedium = Animation.easeInOut(duration: 0.35)
    static let animationSlow = Animation.easeInOut(duration: 0.6)
    static let animationSpring = Animation.spring(response: 0.5, dampingFraction: 0.7)

    // MARK: - Glass Effect Parameters
    static let glassOpacity: Double = 0.12
    static let glassBlur: CGFloat = 20
    static let glassBorderOpacity: Double = 0.15
}

struct ShadowConfig {
    let color: Color
    let radius: CGFloat
    let y: CGFloat

    func apply(to view: some View) -> some View {
        view.shadow(color: color, radius: radius, x: 0, y: y)
    }
}
