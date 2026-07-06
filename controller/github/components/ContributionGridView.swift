import SwiftUI

/// GitHub 贡献热力图组件
struct ContributionGridView: View {
    let summary: ContributionSummary
    private let weeks = 13; private let cellSize: CGFloat = 12; private let spacing: CGFloat = 3

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<weeks, id: \.self) { week in
                VStack(spacing: spacing) {
                    ForEach(0..<7, id: \.self) { day in
                        let ds = dateStr(week: week, day: day); let c = summary.count(for: ds)
                        RoundedRectangle(cornerRadius: 2).fill(colorFor(c)).frame(width: cellSize, height: cellSize)
                    }
                }
            }
        }
    }
    private func dateStr(week: Int, day: Int) -> String {
        let total = (weeks - 1 - week) * 7 + (6 - day)
        guard let d = Calendar.current.date(byAdding: .day, value: -total, to: Date()) else { return "" }
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; return f.string(from: d)
    }
    private func colorFor(_ count: Int) -> Color {
        guard count > 0, summary.maxCount > 0 else { return count > 0 ? AppColors.primary.opacity(0.5) : AppColors.backgroundTertiary }
        let r = Double(count) / Double(max(summary.maxCount, 1))
        switch min(4, Int(r * 4)) {
        case 0: return AppColors.primary.opacity(0.25); case 1: return AppColors.primary.opacity(0.5)
        case 2: return AppColors.primary.opacity(0.75); default: return AppColors.primary
        }
    }
}