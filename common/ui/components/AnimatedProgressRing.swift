import SwiftUI

/// 动画进度环组件
struct AnimatedProgressRing: View {
    let progress: Double; var lineWidth: CGFloat; var size: CGFloat; var gradientColors: [Color]
    @State private var animatedProgress: Double = 0
    init(progress: Double, lineWidth: CGFloat = 8, size: CGFloat = 80, gradientColors: [Color] = [AppColors.primary, AppColors.neonCyan]) {
        self.progress = progress; self.lineWidth = lineWidth; self.size = size; self.gradientColors = gradientColors
    }
    var body: some View {
        ZStack {
            Circle().stroke(AppColors.backgroundTertiary, lineWidth: lineWidth)
            Circle().trim(from: 0, to: animatedProgress)
                .stroke(AngularGradient(colors: gradientColors, center: .center, startAngle: .degrees(-90), endAngle: .degrees(270)),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)).rotationEffect(.degrees(-90))
        }.frame(width: size, height: size)
        .onAppear { withAnimation(AppTheme.animationSlow) { animatedProgress = progress } }
        .onChange(of: progress) { _, v in withAnimation(AppTheme.animationMedium) { animatedProgress = v } }
    }
}