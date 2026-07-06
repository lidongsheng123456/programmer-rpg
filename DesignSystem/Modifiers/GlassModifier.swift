import SwiftUI
struct GlassModifier: ViewModifier {
    var cornerRadius: CGFloat; var opacity: Double; var borderOpacity: Double
    init(cornerRadius: CGFloat = AppTheme.radiusLG, opacity: Double = AppTheme.glassOpacity, borderOpacity: Double = AppTheme.glassBorderOpacity) {
        self.cornerRadius = cornerRadius; self.opacity = opacity; self.borderOpacity = borderOpacity
    }
    func body(content: Content) -> some View {
        content.background(
            RoundedRectangle(cornerRadius: cornerRadius).fill(.ultraThinMaterial)
                .overlay(RoundedRectangle(cornerRadius: cornerRadius).fill(Color.white.opacity(opacity)))
                .overlay(RoundedRectangle(cornerRadius: cornerRadius).strokeBorder(
                    LinearGradient(colors: [Color.white.opacity(borderOpacity), Color.white.opacity(borderOpacity * 0.3)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1))
        ).clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}
extension View {
    func glassCard(cornerRadius: CGFloat = AppTheme.radiusLG, opacity: Double = AppTheme.glassOpacity) -> some View {
        modifier(GlassModifier(cornerRadius: cornerRadius, opacity: opacity))
    }
}