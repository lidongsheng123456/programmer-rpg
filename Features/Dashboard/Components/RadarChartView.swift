import SwiftUI

struct RadarChartView: View {
    let stats: PowerStats; var size: CGFloat; var lineWidth: CGFloat
    @State private var animatedValues: [Double] = Array(repeating: 0, count: 6)
    private let gridLevels = 5
    private var dims: [(label: String, value: Double)] { stats.dimensions }
    private var n: Int { dims.count }

    init(stats: PowerStats, size: CGFloat = 260, lineWidth: CGFloat = 2) { self.stats = stats; self.size = size; self.lineWidth = lineWidth }

    var body: some View {
        ZStack { gridLines; axisLines; dataArea; labels }
            .frame(width: size, height: size)
            .onAppear { withAnimation(AppTheme.animationSlow) { animatedValues = dims.map(\.value) } }
            .onChange(of: stats) { _, _ in withAnimation(AppTheme.animationSlow) { animatedValues = dims.map(\.value) } }
    }

    private var gridLines: some View {
        ForEach(1...gridLevels, id: \.self) { lvl in polygon(scale: CGFloat(lvl) / CGFloat(gridLevels)).stroke(AppColors.borderLight, lineWidth: 0.5) }
    }
    private var axisLines: some View {
        ForEach(0..<n, id: \.self) { i in
            Path { p in p.move(to: center); p.addLine(to: pt(at: angle(i), scale: 1)) }.stroke(AppColors.borderLight, lineWidth: 0.5)
        }
    }
    private var dataArea: some View {
        let path = Path { p in
            for (i, v) in animatedValues.enumerated() {
                let pt = pt(at: angle(i), scale: CGFloat(v / 100))
                i == 0 ? p.move(to: pt) : p.addLine(to: pt)
            }; p.closeSubpath()
        }
        return ZStack {
            path.fill(LinearGradient(colors: [AppColors.primary.opacity(0.3), AppColors.neonCyan.opacity(0.15)], startPoint: .top, endPoint: .bottom))
            path.stroke(LinearGradient(colors: [AppColors.primary, AppColors.neonCyan], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: lineWidth)
            ForEach(0..<n, id: \.self) { i in
                Circle().fill(AppColors.statColors[i]).frame(width: 8, height: 8)
                    .shadow(color: AppColors.statColors[i].opacity(0.6), radius: 4)
                    .position(pt(at: angle(i), scale: CGFloat(animatedValues[i] / 100)))
            }
        }
    }
    private var labels: some View {
        ForEach(0..<n, id: \.self) { i in
            VStack(spacing: 2) {
                Text(dims[i].label).font(AppTypography.caption).foregroundStyle(AppColors.textSecondary)
                Text("\(Int(animatedValues[i]))").font(AppTypography.statSmall).foregroundStyle(AppColors.statColors[i])
            }.position(pt(at: angle(i), scale: 1.2))
        }
    }

    private var center: CGPoint { CGPoint(x: size / 2, y: size / 2) }
    private var radius: CGFloat { size / 2 * 0.7 }
    private func angle(_ i: Int) -> Double { 2 * .pi / Double(n) * Double(i) - .pi / 2 }
    private func pt(at a: Double, scale: CGFloat) -> CGPoint { CGPoint(x: center.x + cos(a) * radius * scale, y: center.y + sin(a) * radius * scale) }
    private func polygon(scale: CGFloat) -> Path {
        Path { p in for i in 0..<n { let pt = pt(at: angle(i), scale: scale); i == 0 ? p.move(to: pt) : p.addLine(to: pt) }; p.closeSubpath() }
    }
}