import SwiftUI

/// 在线/离线状态徽章组件
struct StatusBadge: View {
    let status: Status; let label: String?
    init(_ status: Status, label: String? = nil) { self.status = status; self.label = label }
    var body: some View {
        HStack(spacing: AppTheme.spacingXS) {
            Circle().fill(status.color).frame(width: 8, height: 8)
            if let label = label { Text(label).font(AppTypography.captionSmall).foregroundStyle(status.color) }
        }.padding(.horizontal, AppTheme.spacingSM).padding(.vertical, AppTheme.spacingXS)
        .background(status.color.opacity(0.1)).clipShape(Capsule())
    }
    enum Status {
        case online, offline, warning, unknown
        var color: Color { switch self { case .online: return AppColors.success; case .offline: return AppColors.error; case .warning: return AppColors.warning; case .unknown: return AppColors.textTertiary } }
    }
}