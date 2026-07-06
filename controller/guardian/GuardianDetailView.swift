import SwiftUI

/// 服务器守护者详情视图，展示响应时间趋势和运行状态
struct GuardianDetailView: View {
    let status: ServerStatus; let history: ServerPingHistory?; let onRefresh: () async -> Void
    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.spacingXL) {
                GlassCard {
                    VStack(spacing: AppTheme.spacingMD) {
                        Text(status.config.guardianEmoji).font(.system(size: 64))
                        Text(status.config.name).font(AppTypography.heading2).foregroundStyle(AppColors.textPrimary)
                        StatusBadge(status.isOnline ? .online : .offline, label: status.isOnline ? "守护中" : "离线")
                    }.frame(maxWidth: .infinity)
                }
                HStack(spacing: AppTheme.spacingMD) {
                    StatCard(title: "响应时间", value: "\(status.responseTimeMs)ms", icon: "bolt.fill", iconColor: AppColors.success)
                    StatCard(title: "7日在线率", value: String(format: "%.1f%%", history?.uptimePercentage ?? 0), icon: "chart.line.uptrend.xyaxis", iconColor: AppColors.info)
                }
                if let h = history, !h.recentRecords.isEmpty {
                    GlassCard {
                        VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                            Text("响应时间趋势").font(AppTypography.heading3).foregroundStyle(AppColors.textPrimary)
                            ResponseTimeChartView(records: h.recentRecords).frame(height: 200)
                        }
                    }
                }
                GlassCard {
                    VStack(spacing: AppTheme.spacingMD) {
                        detailRow("地址", status.config.url); Divider().background(AppColors.borderLight)
                        detailRow("状态码", "\(status.statusCode)"); Divider().background(AppColors.borderLight)
                        detailRow("检测时间", status.checkedAt.relativeString)
                    }
                }
            }.padding(.horizontal, AppTheme.spacingLG).padding(.bottom, AppTheme.spacingXXL)
        }
        .background(AppColors.backgroundGradient.ignoresSafeArea())
        .navigationTitle(status.config.name).navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar).refreshable { await onRefresh() }
    }
    private func detailRow(_ l: String, _ v: String) -> some View {
        HStack { Text(l).font(AppTypography.bodyMedium).foregroundStyle(AppColors.textSecondary); Spacer(); Text(v).font(AppTypography.bodyMedium).foregroundStyle(AppColors.textPrimary).lineLimit(1) }
    }
}
