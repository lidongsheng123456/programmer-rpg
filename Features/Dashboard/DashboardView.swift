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
                }
                .padding(.horizontal, AppTheme.spacingLG).padding(.bottom, AppTheme.spacingXXL)
            }
            .background(AppColors.backgroundGradient.ignoresSafeArea())
            .navigationTitle("鎴樺姏闈㈡澘").navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .refreshable { await viewModel.refresh() }
            .task { await viewModel.refresh() }
        }.preferredColorScheme(.dark)
    }

    private var characterHeader: some View {
        GlassCard {
            HStack {
                VStack(alignment: .leading, spacing: AppTheme.spacingXS) {
                    Text(viewModel.powerStats.level.rawValue).font(AppTypography.heading2).foregroundStyle(AppColors.accentGold)
                    Text("缁煎悎鎴樺姏").font(AppTypography.caption).foregroundStyle(AppColors.textSecondary)
                }
                Spacer()
                VStack(spacing: 2) {
                    Text("\(Int(viewModel.powerStats.totalPower))").font(AppTypography.displayMedium).foregroundStyle(AppColors.primaryGradient)
                    Text("POWER").font(AppTypography.captionSmall).foregroundStyle(AppColors.textTertiary).tracking(2)
                }
            }
        }
    }

    private var radarSection: some View {
        GlassCard {
            VStack(spacing: AppTheme.spacingMD) {
                HStack { Text("鍏淮灞炴€?).font(AppTypography.heading3).foregroundStyle(AppColors.textPrimary); Spacer() }
                RadarChartView(stats: viewModel.powerStats).frame(height: 280)
            }
        }
    }

    private var statsGrid: some View {
        let dims = viewModel.powerStats.dimensions
        let icons = ["bolt.fill", "shield.fill", "heart.fill", "brain.head.profile", "hare.fill", "star.fill"]
        return LazyVGrid(columns: [GridItem(.flexible(), spacing: AppTheme.spacingMD), GridItem(.flexible(), spacing: AppTheme.spacingMD)], spacing: AppTheme.spacingMD) {
            ForEach(Array(dims.enumerated()), id: \.offset) { i, dim in
                GlassCard(padding: AppTheme.spacingMD) {
                    HStack(spacing: AppTheme.spacingSM) {
                        Image(systemName: icons[i]).font(.system(size: 18)).foregroundStyle(AppColors.statColors[i])
                            .frame(width: 32, height: 32).background(AppColors.statColors[i].opacity(0.15)).clipShape(RoundedRectangle(cornerRadius: 6))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(dim.label).font(AppTypography.captionSmall).foregroundStyle(AppColors.textTertiary)
                            Text("\(Int(dim.value))").font(AppTypography.statMedium).foregroundStyle(AppColors.textPrimary)
                        }; Spacer()
                    }
                }
            }
        }
    }
}