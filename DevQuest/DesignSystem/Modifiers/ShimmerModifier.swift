import SwiftUI
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1
    var duration: Double
    init(duration: Double = 1.5) { self.duration = duration }
    func body(content: Content) -> some View {
        content.overlay(GeometryReader { geo in
            LinearGradient(colors: [.clear, Color.white.opacity(0.15), .clear], startPoint: .leading, endPoint: .trailing)
                .frame(width: geo.size.width * 0.6).offset(x: phase * geo.size.width * 1.6 - geo.size.width * 0.3)
        }).clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusMD))
        .onAppear { withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) { phase = 1 } }
    }
}
extension View { func shimmer(duration: Double = 1.5) -> some View { modifier(ShimmerModifier(duration: duration)) } }