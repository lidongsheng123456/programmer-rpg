import SwiftUI

struct RadarChartView: View {
    let stats: PowerStats
    var size: CGFloat
    var lineWidth: CGFloat

    @State private var animatedValues: [Double] = Array(repeating: 0, count: 6)

    private let gridLevels = 5
    private var dimensions: [(label: String, value: Double)] { stats.dimensions }
    private var vertexCount: Int { dimensions.count }

    init(stats: PowerStats, size: CGFloat = 260, lineWidth: CGFloat = 2) {
        self.stats = stats
        self.size = size
        self.lineWidth = lineWidth
    }

    var body: some View {
        ZStack {
            gridLines
            axisLines
            dataArea
            labels
        }
        .frame(width: size, height: size)
        .onAppear { animateIn() }
        .onChange(of: stats) { _, _ in animateIn() }
    }

    // MARK: - Grid

    private var gridLines: some View {
        ForEach(1...gridLevels, id: \.self) { level in
            let scale = CGFloat(level) / CGFloat(gridLevels)
            polygonPath(scale: scale)
                .stroke(AppColors.borderLight, lineWidth: 0.5)
        }
    }

    // MARK: - Axes

    private var axisLines: some View {
        ForEach(0..<vertexCount, id: \.self) { index in
            let angle = angleFor(index: index)
            let end = point(at: angle, scale: 1.0)
            Path { path in
                path.move(to: center)
                path.addLine(to: end)
            }
            .stroke(AppColors.borderLight, lineWidth: 0.5)
        }
    }

    // MARK: - Data polygon with gradient fill

    private var dataArea: some View {
        let path = dataPath
        return ZStack {
            path
                .fill(
                    LinearGradient(
                        colors: [
                            AppColors.primary.opacity(0.3),
                            AppColors.neonCyan.opacity(0.15)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            path
                .stroke(
                    LinearGradient(
                        colors: [AppColors.primary, AppColors.neonCyan],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: lineWidth
                )
            dataPoints
        }
    }

    private var dataPath: Path {
        Path { path in
            for (index, value) in animatedValues.enumerated() {
                let scale = CGFloat(value / 100.0)
                let angle = angleFor(index: index)
                let pt = point(at: angle, scale: scale)
                if index == 0 {
                    path.move(to: pt)
                } else {
                    path.addLine(to: pt)
                }
            }
            path.closeSubpath()
        }
    }

    private var dataPoints: some View {
        ForEach(0..<vertexCount, id: \.self) { index in
            let scale = CGFloat(animatedValues[index] / 100.0)
            let angle = angleFor(index: index)
            let pt = point(at: angle, scale: scale)
            Circle()
                .fill(AppColors.statColors[index])
                .frame(width: 8, height: 8)
                .shadow(color: AppColors.statColors[index].opacity(0.6), radius: 4)
                .position(pt)
        }
    }

    // MARK: - Labels

    private var labels: some View {
        ForEach(0..<vertexCount, id: \.self) { index in
            let angle = angleFor(index: index)
            let labelPoint = point(at: angle, scale: 1.2)
            VStack(spacing: 2) {
                Text(dimensions[index].label)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
                Text("\(Int(animatedValues[index]))")
                    .font(AppTypography.statSmall)
                    .foregroundStyle(AppColors.statColors[index])
            }
            .position(labelPoint)
        }
    }

    // MARK: - Geometry Helpers

    private var center: CGPoint {
        CGPoint(x: size / 2, y: size / 2)
    }

    private var radius: CGFloat {
        size / 2 * 0.7
    }

    private func angleFor(index: Int) -> Double {
        let slice = 2 * .pi / Double(vertexCount)
        return slice * Double(index) - .pi / 2
    }

    private func point(at angle: Double, scale: CGFloat) -> CGPoint {
        CGPoint(
            x: center.x + cos(angle) * radius * scale,
            y: center.y + sin(angle) * radius * scale
        )
    }

    private func polygonPath(scale: CGFloat) -> Path {
        Path { path in
            for index in 0..<vertexCount {
                let angle = angleFor(index: index)
                let pt = point(at: angle, scale: scale)
                if index == 0 {
                    path.move(to: pt)
                } else {
                    path.addLine(to: pt)
                }
            }
            path.closeSubpath()
        }
    }

    // MARK: - Animation

    private func animateIn() {
        let values = dimensions.map(\.value)
        withAnimation(AppTheme.animationSlow) {
            animatedValues = values
        }
    }
}
