import SwiftUI

struct ResponseTimeChartView: View {
    let records: [ServerPingHistory.PingRecord]

    @State private var animatedProgress: CGFloat = 0

    private var maxResponseTime: Int {
        max(records.map(\.responseTimeMs).max() ?? 100, 100)
    }

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            let stepX = records.count > 1 ? width / CGFloat(records.count - 1) : width

            ZStack {
                gridLines(height: height)

                // Area fill
                Path { path in
                    guard !records.isEmpty else { return }
                    path.move(to: CGPoint(x: 0, y: height))

                    for (index, record) in records.enumerated() {
                        let x = CGFloat(index) * stepX
                        let y = height - (CGFloat(record.responseTimeMs) / CGFloat(maxResponseTime) * height * animatedProgress)
                        path.addLine(to: CGPoint(x: x, y: y))
                    }

                    path.addLine(to: CGPoint(x: CGFloat(records.count - 1) * stepX, y: height))
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        colors: [AppColors.primary.opacity(0.3), AppColors.primary.opacity(0.05)],
                        startPoint: .top, endPoint: .bottom
                    )
                )

                // Line
                Path { path in
                    guard !records.isEmpty else { return }
                    for (index, record) in records.enumerated() {
                        let x = CGFloat(index) * stepX
                        let y = height - (CGFloat(record.responseTimeMs) / CGFloat(maxResponseTime) * height * animatedProgress)
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(AppColors.neonGradient, lineWidth: 2)

                // Data points
                ForEach(Array(records.enumerated()), id: \.offset) { index, record in
                    let x = CGFloat(index) * stepX
                    let y = height - (CGFloat(record.responseTimeMs) / CGFloat(maxResponseTime) * height * animatedProgress)
                    Circle()
                        .fill(record.isOnline ? AppColors.success : AppColors.error)
                        .frame(width: 6, height: 6)
                        .position(x: x, y: y)
                }
            }
        }
        .onAppear {
            withAnimation(AppTheme.animationSlow) {
                animatedProgress = 1
            }
        }
    }

    private func gridLines(height: CGFloat) -> some View {
        VStack {
            ForEach(0..<4, id: \.self) { i in
                Spacer()
                if i < 3 {
                    Rectangle()
                        .fill(AppColors.borderLight)
                        .frame(height: 0.5)
                }
            }
        }
    }
}
