import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: DashboardViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.spacingXL) {
                    characterHeader
                    radarSection
                    statsGrid
                    quickActions
                }
                .padding(.horizontal, AppTheme.spacingLG)
                .padding(.bottom, AppTheme.spacingXXL)
            }
            .background(AppColors.backgroundGradient.ignoresSafeArea())
            .navigationTitle("战力面板")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .refreshable { await viewModel.refresh() }
            .task { await viewModel.refresh() }
            .overlay {
                if viewModel.isLoading && viewModel.powerStats == .zero {
                    loadingOverlay
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Character Header

    private var characterHeader: some View {
        GlassCard {
            VStack(spacing: AppTheme.spacingMD) {
                HStack {
                    VStack(alignment: .leading, spacing: AppTheme.spacingXS) {
                        Text(viewModel.powerStats.level.rawValue)
                            .font(AppTypography.heading2)
                            .foregroundStyle(AppColors.accentGold)
                        Text("综合战力")
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    Spacer()
                    powerBadge
                }

                // XP progress bar
                VStack(alignment: .leading, spacing: AppTheme.spacingXS) {
                    let nextLevel = nextLevelThreshold
                    let current = viewModel.powerStats.totalPower
                    let progress = min(1.0, current / max(nextLevel, 1))

                    HStack {
                        Text("经验进度")
                            .font(AppTypography.captionSmall)
                            .foregroundStyle(AppColors.textTertiary)
                        Spacer()
                        Text("\(Int(current)) / \(Int(nextLevel))")
                            .font(AppTypography.statSmall)
                            .foregroundStyle(AppColors.textSecondary)
                    }

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(AppColors.backgroundTertiary)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(AppColors.primaryGradient)
                                .frame(width: geo.size.width * progress)
                        }
                    }
                    .frame(height: 6)
                }
            }
        }
    }

    private var powerBadge: some View {
        VStack(spacing: 2) {
            Text("\(Int(viewModel.powerStats.totalPower))")
                .font(AppTypography.displayMedium)
                .foregroundStyle(AppColors.primaryGradient)
            Text("POWER")
                .font(AppTypography.captionSmall)
                .foregroundStyle(AppColors.textTertiary)
                .tracking(2)
        }
        .padding(AppTheme.spacingMD)
        .background(
            Circle()
                .fill(AppColors.primary.opacity(0.1))
                .frame(width: 90, height: 90)
        )
    }

    private var nextLevelThreshold: Double {
        switch viewModel.powerStats.level {
        case .bronze:   return 20
        case .silver:   return 40
        case .gold:     return 60
        case .platinum: return 80
        case .diamond:  return 95
        case .master:   return 100
        }
    }

    // MARK: - Radar Chart

    private var radarSection: some View {
        GlassCard {
            VStack(spacing: AppTheme.spacingMD) {
                HStack {
                    Text("六维属性")
                        .font(AppTypography.heading3)
                        .foregroundStyle(AppColors.textPrimary)
                    Spacer()
                    Image(systemName: "hexagon")
                        .foregroundStyle(AppColors.primary)
                }
                RadarChartView(stats: viewModel.powerStats)
                    .frame(height: 280)
            }
        }
    }

    // MARK: - Stats Grid

    private var statsGrid: some View {
        let dims = viewModel.powerStats.dimensions
        return LazyVGrid(columns: [
            GridItem(.flexible(), spacing: AppTheme.spacingMD),
            GridItem(.flexible(), spacing: AppTheme.spacingMD)
        ], spacing: AppTheme.spacingMD) {
            ForEach(Array(dims.enumerated()), id: \.offset) { index, dim in
                miniStatCard(
                    label: dim.label,
                    value: dim.value,
                    color: AppColors.statColors[index],
                    icon: statIcon(for: index)
                )
            }
        }
    }

    private func miniStatCard(label: String, value: Double, color: Color, icon: String) -> some View {
        GlassCard(padding: AppTheme.spacingMD) {
            HStack(spacing: AppTheme.spacingSM) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(color)
                    .frame(width: 32, height: 32)
                    .background(color.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(AppTypography.captionSmall)
                        .foregroundStyle(AppColors.textTertiary)
                    Text("\(Int(value))")
                        .font(AppTypography.statMedium)
                        .foregroundStyle(AppColors.textPrimary)
                }
                Spacer()
            }
        }
    }

    private func statIcon(for index: Int) -> String {
        ["bolt.fill", "shield.fill", "heart.fill", "brain.head.profile", "hare.fill", "star.fill"][index]
    }

    // MARK: - Quick Actions

    private var quickActions: some View {
        GlassCard {
            HStack {
                Label("成就 \(viewModel.achievementCount)/\(Achievement.allAchievements.count)",
                      systemImage: "trophy.fill")
                    .font(AppTypography.label)
                    .foregroundStyle(AppColors.accentGold)
                Spacer()
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(AppTypography.captionSmall)
                        .foregroundStyle(AppColors.error)
                        .lineLimit(1)
                }
            }
        }
    }

    // MARK: - Loading

    private var loadingOverlay: some View {
        VStack(spacing: AppTheme.spacingLG) {
            ProgressView()
                .tint(AppColors.primary)
                .scaleEffect(1.5)
            Text("数据加载中...")
                .font(AppTypography.bodyMedium)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.backgroundPrimary.opacity(0.8))
    }
}
