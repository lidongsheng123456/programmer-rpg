import SwiftUI

struct GuardianListView: View {
    @ObservedObject var viewModel: GuardianViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.spacingLG) {
                    overviewCard
                    serverList
                }
                .padding(.horizontal, AppTheme.spacingLG)
                .padding(.bottom, AppTheme.spacingXXL)
            }
            .background(AppColors.backgroundGradient.ignoresSafeArea())
            .navigationTitle("服务器守护兽")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .refreshable { await viewModel.refresh() }
            .task { await viewModel.refresh() }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Overview

    private var overviewCard: some View {
        GlassCard {
            HStack(spacing: AppTheme.spacingLG) {
                VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
                    Text("守护兽总览")
                        .font(AppTypography.heading3)
                        .foregroundStyle(AppColors.textPrimary)
                    Text("\(onlineCount)/\(viewModel.serverStatuses.count) 在线")
                        .font(AppTypography.bodyMedium)
                        .foregroundStyle(allOnline ? AppColors.success : AppColors.warning)
                }
                Spacer()
                AnimatedProgressRing(
                    progress: viewModel.serverStatuses.isEmpty ? 0 :
                        Double(onlineCount) / Double(viewModel.serverStatuses.count),
                    size: 60,
                    gradientColors: allOnline
                        ? [AppColors.success, AppColors.neonGreen]
                        : [AppColors.warning, AppColors.error]
                )
                .overlay {
                    Text("\(Int(uptimePercent))%")
                        .font(AppTypography.statSmall)
                        .foregroundStyle(AppColors.textPrimary)
                }
            }
        }
    }

    private var onlineCount: Int {
        viewModel.serverStatuses.filter(\.isOnline).count
    }

    private var allOnline: Bool {
        viewModel.serverStatuses.allSatisfy(\.isOnline)
    }

    private var uptimePercent: Double {
        guard !viewModel.serverStatuses.isEmpty else { return 0 }
        return Double(onlineCount) / Double(viewModel.serverStatuses.count) * 100
    }

    // MARK: - Server List

    private var serverList: some View {
        VStack(spacing: AppTheme.spacingMD) {
            ForEach(viewModel.serverStatuses) { status in
                NavigationLink {
                    GuardianDetailView(
                        status: status,
                        history: viewModel.getHistory(for: status.config.id),
                        onRefresh: { await viewModel.refreshSingle(status.config) }
                    )
                } label: {
                    serverRow(status)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func serverRow(_ status: ServerStatus) -> some View {
        GlassCard {
            HStack(spacing: AppTheme.spacingMD) {
                Text(status.config.guardianEmoji)
                    .font(.system(size: 36))

                VStack(alignment: .leading, spacing: AppTheme.spacingXS) {
                    Text(status.config.name)
                        .font(AppTypography.heading3)
                        .foregroundStyle(AppColors.textPrimary)
                    Text(status.config.url)
                        .font(AppTypography.captionSmall)
                        .foregroundStyle(AppColors.textTertiary)
                        .lineLimit(1)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: AppTheme.spacingXS) {
                    StatusBadge(
                        status.isOnline ? .online : .offline,
                        label: status.isOnline ? "在线" : "离线"
                    )
                    if status.isOnline {
                        Text(status.uptimeDisplay)
                            .font(AppTypography.statSmall)
                            .foregroundStyle(responseTimeColor(status.responseTimeMs))
                    }
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppColors.textTertiary)
            }
        }
    }

    private func responseTimeColor(_ ms: Int) -> Color {
        switch ms {
        case 0..<200:  return AppColors.success
        case 200..<500: return AppColors.warning
        default:        return AppColors.error
        }
    }
}
