import SwiftUI

struct GlassCard<Content: View>: View {
    let content: Content
    var padding: CGFloat
    var cornerRadius: CGFloat

    init(
        padding: CGFloat = AppTheme.spacingLG,
        cornerRadius: CGFloat = AppTheme.radiusLG,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.padding = padding
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        content
            .padding(padding)
            .glassCard(cornerRadius: cornerRadius)
    }
}
