import SwiftUI
struct ResponseTimeChartView: View {
    let records: [ServerPingHistory.PingRecord]
    @State private var progress: CGFloat = 0
    private var maxMs: Int { max(records.map(\.responseTimeMs).max() ?? 100, 100) }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width; let h = geo.size.height; let step = records.count > 1 ? w / CGFloat(records.count - 1) : w
            ZStack {
                Path { p in
                    guard !records.isEmpty else { return }; p.move(to: CGPoint(x: 0, y: h))
                    for (i, r) in records.enumerated() { p.addLine(to: CGPoint(x: CGFloat(i) * step, y: h - CGFloat(r.responseTimeMs) / CGFloat(maxMs) * h * progress)) }
                    p.addLine(to: CGPoint(x: CGFloat(records.count - 1) * step, y: h)); p.closeSubpath()
                }.fill(LinearGradient(colors: [AppColors.primary.opacity(0.3), AppColors.primary.opacity(0.05)], startPoint: .top, endPoint: .bottom))

                Path { p in
                    for (i, r) in records.enumerated() {
                        let pt = CGPoint(x: CGFloat(i) * step, y: h - CGFloat(r.responseTimeMs) / CGFloat(maxMs) * h * progress)
                        i == 0 ? p.move(to: pt) : p.addLine(to: pt)
                    }
                }.stroke(AppColors.neonGradient, lineWidth: 2)

                ForEach(Array(records.enumerated()), id: \.offset) { i, r in
                    Circle().fill(r.isOnline ? AppColors.success : AppColors.error).frame(width: 6, height: 6)
                        .position(x: CGFloat(i) * step, y: h - CGFloat(r.responseTimeMs) / CGFloat(maxMs) * h * progress)
                }
            }
        }.onAppear { withAnimation(AppTheme.animationSlow) { progress = 1 } }
    }
}