import SwiftUI

struct GuardianDetailView: View {
    let status: ServerStatus
    let history: ServerPingHistory?
    let onRefresh: () async -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.spacingXL) {
                guardianHeader
                statusCards
                if let history = history, !history.recentRecords.isEmpty {
                    responseTimeChart(history)
                }
                detailInfo
            }
            .padding(.horizontal, AppTheme.spacingLG)
            .padding(.bottom, AppTheme.spacingXXL)
        }
        .background(AppColors.backgroundGradient.ignoresSafeArea())
        .navigationTitle(status.config.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .refreshable { await onRefresh() }
    }

    // MARK: - Header

    private var guardianHeader: some View {
        GlassCard {
            VStack(spacing: AppTheme.spacingMD) {
                Text(status.config.guardianEmoji)
                    .font(.system(size: 64))
                Text(status.config.name)
                    .font(AppTypography.heading2)
                    .foregroundStyle(AppColors.textPrimary)
                StatusBadge(
                    status.isOnline ? .online : .offline,
                    label: status.isOnline ? "守护中" : "已离线"
                )
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Status Cards

    private var statusCards: some View {
        HStack(spacing: AppTheme.spacingMD) {
            StatCard(
                title: "响应时间",
                value: "\(status.responseTimeMs)ms",
                icon: "bolt.fill",
                iconColor: responseTimeColor
            )
            StatCard(
                title: "7天在线率",
                value: String(format: "%.1f%%", history?.uptimePercentage ?? 0),
                icon: "chart.line.uptrend.xyaxis",
                iconColor: AppColors.info
            )
        }
    }

    private var responseTimeColor: Color {
        switch status.responseTimeMs {
        case 0..<200:  return AppColors.success
        case 200..<500: return AppColors.warning
        default:        return AppColors.error
        }
    }

    // MARK: - Response Time Chart

    private func responseTimeChart(_ history: ServerPingHistory) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                Text("响应时间趋势")
                    .font(AppTypography.heading3)
                    .foregroundStyle(AppColors.textPrimary)

                ResponseTimeChartView(records: history.recentRecords)
                    .frame(height: 200)
            }
        }
    }

    // MARK: - Detail Info

    private var detailInfo: some View {
        GlassCard {
            VStack(spacing: AppTheme.spacingMD) {
                detailRow("URL", value: status.config.url)
                Divider().background(AppColors.borderLight)
                detailRow("状态码", value: "\(status.statusCode)")
                Divider().background(AppColors.borderLight)
                detailRow("检测时间", value: status.checkedAt.relativeString)
                Divider().background(AppColors.borderLight)
                detailRow("历史记录", value: "\(history?.records.count ?? 0) 条")
            }
        }
    }

    private func detailRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(AppTypography.bodyMedium)
                .foregroundStyle(AppColors.textSecondary)
            Spacer()
            Text(value)
                .font(AppTypography.bodyMedium)
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(1)
        }
    }
}
