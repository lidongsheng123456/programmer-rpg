import SwiftUI

/// \u6218\u529b\u4eea\u8868\u76d8\u89c6\u56fe\uff0c\u5c55\u793a\u516d\u7ef4\u96f7\u8fbe\u56fe\u548c\u6218\u529b\u7edf\u8ba1
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
            .navigationTitle("\u6218\u529b\u4eea\u8868\u76d8").navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .refreshable { await viewModel.refresh() }
            .task { await viewModel.refresh() }
        }.preferredColorScheme(.dark)
    }

    /// \u89d2\u8272\u7b49\u7ea7\u548c\u7efc\u5408\u6218\u529b\u5934\u90e8\u5361\u7247
    private var characterHeader: some View {
        GlassCard {
            HStack {
                VStack(alignment: .leading, spacing: AppTheme.spacingXS) {
                    Text(viewModel.powerStats.level.rawValue).font(AppTypography.heading2).foregroundStyle(AppColors.accentGold)
                    Text("\u7efc\u5408\u6218\u529b").font(AppTypography.caption).foregroundStyle(AppColors.textSecondary)
                }
                Spacer()
                VStack(spacing: 2) {
                    Text("\(Int(viewModel.powerStats.totalPower))").font(AppTypography.displayMedium).foregroundStyle(AppColors.primaryGradient)
                    Text("\u6218\u529b\u503c").font(AppTypography.captionSmall).foregroundStyle(AppColors.textTertiary).tracking(2)
                }
            }
        }
    }

    /// \u516d\u7ef4\u96f7\u8fbe\u56fe\u533a\u57df
    private var radarSection: some View {
        GlassCard {
            VStack(spacing: AppTheme.spacingMD) {
                HStack { Text("\u516d\u7ef4\u6218\u529b\u56fe").font(AppTypography.heading3).foregroundStyle(AppColors.textPrimary); Spacer() }
                RadarChartView(stats: viewModel.powerStats).frame(height: 280)
            }
        }
    }

    /// \u6218\u529b\u7ef4\u5ea6\u7f51\u683c\u5217\u8868
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
