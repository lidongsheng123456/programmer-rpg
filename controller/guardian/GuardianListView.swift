import SwiftUI

/// 服务器守护者列表视图，展示所有服务器状态
struct GuardianListView: View {
    @ObservedObject var viewModel: GuardianViewModel
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.spacingLG) {
                    GlassCard {
                        HStack {
                            VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
                                Text("守护概览").font(AppTypography.heading3).foregroundStyle(AppColors.textPrimary)
                                let online = viewModel.serverStatuses.filter(\.isOnline).count
                                Text("\(online)/\(viewModel.serverStatuses.count) 在线").font(AppTypography.bodyMedium)
                                    .foregroundStyle(online == viewModel.serverStatuses.count ? AppColors.success : AppColors.warning)
                            }; Spacer()
                            AnimatedProgressRing(progress: viewModel.serverStatuses.isEmpty ? 0 : Double(viewModel.serverStatuses.filter(\.isOnline).count) / Double(viewModel.serverStatuses.count), size: 60,
                                gradientColors: viewModel.serverStatuses.allSatisfy(\.isOnline) ? [AppColors.success, AppColors.neonGreen] : [AppColors.warning, AppColors.error])
                        }
                    }
                    ForEach(viewModel.serverStatuses) { status in
                        NavigationLink {
                            GuardianDetailView(status: status, history: viewModel.getHistory(for: status.config.id), onRefresh: { await viewModel.refreshSingle(status.config) })
                        } label: {
                            GlassCard {
                                HStack(spacing: AppTheme.spacingMD) {
                                    Text(status.config.guardianEmoji).font(.system(size: 36))
                                    VStack(alignment: .leading, spacing: AppTheme.spacingXS) {
                                        Text(status.config.name).font(AppTypography.heading3).foregroundStyle(AppColors.textPrimary)
                                        Text(status.config.url).font(AppTypography.captionSmall).foregroundStyle(AppColors.textTertiary).lineLimit(1)
                                    }; Spacer()
                                    VStack(alignment: .trailing, spacing: AppTheme.spacingXS) {
                                        StatusBadge(status.isOnline ? .online : .offline, label: status.isOnline ? "在线" : "离线")
                                        if status.isOnline { Text(status.uptimeDisplay).font(AppTypography.statSmall).foregroundStyle(AppColors.success) }
                                    }
                                    Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold)).foregroundStyle(AppColors.textTertiary)
                                }
                            }
                        }.buttonStyle(.plain)
                    }
                }.padding(.horizontal, AppTheme.spacingLG).padding(.bottom, AppTheme.spacingXXL)
            }
            .background(AppColors.backgroundGradient.ignoresSafeArea())
            .navigationTitle("服务器守护").navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .refreshable { await viewModel.refresh() }.task { await viewModel.refresh() }
        }.preferredColorScheme(.dark)
    }
}
