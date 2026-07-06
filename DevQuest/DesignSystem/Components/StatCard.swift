import SwiftUI
struct StatCard: View {
    let title: String; let value: String; let icon: String; var iconColor: Color
    init(title: String, value: String, icon: String, iconColor: Color = AppColors.primary) {
        self.title = title; self.value = value; self.icon = icon; self.iconColor = iconColor
    }
    var body: some View {
        GlassCard {
            HStack(spacing: AppTheme.spacingMD) {
                Image(systemName: icon).font(.system(size: 24)).foregroundStyle(iconColor)
                    .frame(width: 44, height: 44).background(iconColor.opacity(0.15)).clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusSM))
                VStack(alignment: .leading, spacing: AppTheme.spacingXS) {
                    Text(title).font(AppTypography.caption).foregroundStyle(AppColors.textSecondary)
                    Text(value).font(AppTypography.statMedium).foregroundStyle(AppColors.textPrimary)
                }
                Spacer()
            }
        }
    }
}