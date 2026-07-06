import SwiftUI

struct ContributionGridView: View {
    let summary: ContributionSummary

    private let weeks = 13 // ~90 days
    private let daysPerWeek = 7
    private let cellSize: CGFloat = 12
    private let spacing: CGFloat = 3

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
            dayLabels
            gridBody
            legend
        }
    }

    private var dayLabels: some View {
        HStack(spacing: spacing) {
            VStack(spacing: spacing) {
                ForEach(["", "周一", "", "周三", "", "周五", ""], id: \.self) { label in
                    Text(label)
                        .font(.system(size: 8))
                        .foregroundStyle(AppColors.textTertiary)
                        .frame(width: 20, height: cellSize)
                }
            }
        }
    }

    private var gridBody: some View {
        HStack(spacing: spacing) {
            Spacer().frame(width: 20)
            ForEach(0..<weeks, id: \.self) { week in
                VStack(spacing: spacing) {
                    ForEach(0..<daysPerWeek, id: \.self) { day in
                        let dateString = dateStringFor(week: week, day: day)
                        let count = summary.count(for: dateString)
                        RoundedRectangle(cornerRadius: 2)
                            .fill(colorForCount(count))
                            .frame(width: cellSize, height: cellSize)
                    }
                }
            }
        }
    }

    private var legend: some View {
        HStack(spacing: AppTheme.spacingSM) {
            Spacer()
            Text("少")
                .font(.system(size: 9))
                .foregroundStyle(AppColors.textTertiary)
            ForEach(0..<5, id: \.self) { level in
                RoundedRectangle(cornerRadius: 2)
                    .fill(colorForLevel(level))
                    .frame(width: cellSize, height: cellSize)
            }
            Text("多")
                .font(.system(size: 9))
                .foregroundStyle(AppColors.textTertiary)
        }
    }

    // MARK: - Helpers

    private func dateStringFor(week: Int, day: Int) -> String {
        let totalDays = (weeks - 1 - week) * 7 + (6 - day)
        guard let date = Calendar.current.date(byAdding: .day, value: -totalDays, to: Date()) else {
            return ""
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private func colorForCount(_ count: Int) -> Color {
        guard summary.maxCount > 0 else {
            return count > 0 ? AppColors.primary.opacity(0.5) : AppColors.backgroundTertiary
        }
        let ratio = Double(count) / Double(max(summary.maxCount, 1))
        let level = min(4, Int(ratio * 4))
        return colorForLevel(count == 0 ? 0 : level + 1)
    }

    private func colorForLevel(_ level: Int) -> Color {
        switch level {
        case 0:  return AppColors.backgroundTertiary
        case 1:  return AppColors.primary.opacity(0.25)
        case 2:  return AppColors.primary.opacity(0.5)
        case 3:  return AppColors.primary.opacity(0.75)
        default: return AppColors.primary
        }
    }
}
