import SwiftUI

struct GuardianDetailView: View {
    let status: ServerStatus; let history: ServerPingHistory?; let onRefresh: () async -> Void
    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.spacingXL) {
                GlassCard {
                    VStack(spacing: AppTheme.spacingMD) {
                        Text(status.config.guardianEmoji).font(.system(size: 64))
                        Text(status.config.name).font(AppTypography.heading2).foregroundStyle(AppColors.textPrimary)
                        StatusBadge(status.isOnline ? .online : .offline, label: status.isOnline ? "Guarding" : "Offline")
                    }.frame(maxWidth: .infinity)
                }
                HStack(spacing: AppTheme.spacingMD) {
                    StatCard(title: "Response Time", value: "\(status.responseTimeMs)ms", icon: "bolt.fill", iconColor: AppColors.success)
                    StatCard(title: "7-Day Uptime", value: String(format: "%.1f%%", history?.uptimePercentage ?? 0), icon: "chart.line.uptrend.xyaxis", iconColor: AppColors.info)
                }
                if let h = history, !h.recentRecords.isEmpty {
                    GlassCard {
                        VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                            Text("Response Time Trend").font(AppTypography.heading3).foregroundStyle(AppColors.textPrimary)
                            ResponseTimeChartView(records: h.recentRecords).frame(height: 200)
                        }
                    }
                }
                GlassCard {
                    VStack(spacing: AppTheme.spacingMD) {
                        detailRow("URL", status.config.url); Divider().background(AppColors.borderLight)
                        detailRow("Status Code", "\(status.statusCode)"); Divider().background(AppColors.borderLight)
                        detailRow("Checked At", status.checkedAt.relativeString)
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
