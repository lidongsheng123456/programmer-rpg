import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    var iconColor: Color
    var trend: TrendDirection?

    init(
        title: String,
        value: String,
        icon: String,
        iconColor: Color = AppColors.primary,
        trend: TrendDirection? = nil
    ) {
        self.title = title
        self.value = value
        self.icon = icon
        self.iconColor = iconColor
        self.trend = trend
    }

    var body: some View {
        GlassCard {
            HStack(spacing: AppTheme.spacingMD) {
                iconView
                VStack(alignment: .leading, spacing: AppTheme.spacingXS) {
                    Text(title)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                    HStack(spacing: AppTheme.spacingXS) {
                        Text(value)
                            .font(AppTypography.statMedium)
                            .foregroundStyle(AppColors.textPrimary)
                        if let trend = trend {
                            trendIndicator(trend)
                        }
                    }
                }
                Spacer()
            }
        }
    }

    private var iconView: some View {
        Image(systemName: icon)
            .font(.system(size: 24))
            .foregroundStyle(iconColor)
            .frame(width: 44, height: 44)
            .background(iconColor.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusSM))
    }

    @ViewBuilder
    private func trendIndicator(_ trend: TrendDirection) -> some View {
        HStack(spacing: 2) {
            Image(systemName: trend.icon)
            Text(trend.label)
        }
        .font(AppTypography.captionSmall)
        .foregroundStyle(trend.color)
    }
}

enum TrendDirection {
    case up(String)
    case down(String)
    case stable

    var icon: String {
        switch self {
        case .up:    return "arrow.up.right"
        case .down:  return "arrow.down.right"
        case .stable: return "arrow.right"
        }
    }

    var label: String {
        switch self {
        case .up(let v):   return v
        case .down(let v): return v
        case .stable:      return "—"
        }
    }

    var color: Color {
        switch self {
        case .up:    return AppColors.success
        case .down:  return AppColors.error
        case .stable: return AppColors.textTertiary
        }
    }
}
