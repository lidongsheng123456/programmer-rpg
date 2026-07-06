import SwiftUI

/// \u4f53\u80fd\u526f\u672c\u89c6\u56fe\uff0c\u5c55\u793a HealthKit \u6570\u636e\u548c\u6bcf\u65e5\u526f\u672c\u8fdb\u5ea6
struct FitnessDungeonView: View {
    @ObservedObject var viewModel: FitnessDungeonViewModel
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.spacingXL) {
                    if viewModel.isAuthorized {
                        GlassCard {
                            HStack {
                                VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
                                    Text("\u4eca\u65e5\u526f\u672c").font(AppTypography.heading2).foregroundStyle(AppColors.textPrimary)
                                    Text(viewModel.dungeonProgress?.isCompleted == true ? "\u526f\u672c\u5df2\u901a\u5173\uff01" : "\u6311\u6218\u8fdb\u884c\u4e2d...")
                                        .font(AppTypography.bodyMedium).foregroundStyle(viewModel.dungeonProgress?.isCompleted == true ? AppColors.accentGold : AppColors.textSecondary)
                                }; Spacer()
                                AnimatedProgressRing(progress: viewModel.dungeonProgress?.overallProgress ?? 0, size: 70, gradientColors: [AppColors.neonGreen, AppColors.neonCyan])
                                    .overlay { Text("\(Int((viewModel.dungeonProgress?.overallProgress ?? 0) * 100))%").font(AppTypography.statSmall).foregroundStyle(AppColors.textPrimary) }
                            }
                        }
                        HStack(spacing: AppTheme.spacingMD) {
                            questCard("figure.walk", "\u6b65\u6570", viewModel.todayRecord.stepsDisplay, viewModel.dungeonProgress?.stepsProgress ?? 0, AppColors.neonGreen)
                            questCard("flame.fill", "\u5361\u8def\u91cc", viewModel.todayRecord.caloriesDisplay, viewModel.dungeonProgress?.caloriesProgress ?? 0, AppColors.accent)
                        }
                        questCard("timer", "\u8fd0\u52a8\u65f6\u957f", viewModel.todayRecord.exerciseDisplay, viewModel.dungeonProgress?.exerciseProgress ?? 0, AppColors.info)
                        weeklyChart
                    } else {
                        GlassCard {
                            VStack(spacing: AppTheme.spacingLG) {
                                Image(systemName: "heart.text.square.fill").font(.system(size: 48)).foregroundStyle(AppColors.accent)
                                Text("\u9700\u8981 HealthKit \u6388\u6743").font(AppTypography.heading2).foregroundStyle(AppColors.textPrimary)
                                Button { Task { await viewModel.requestPermission() } } label: {
                                    Text("\u6388\u6743 HealthKit").font(AppTypography.label).foregroundStyle(.white)
                                        .padding(.horizontal, AppTheme.spacingXL).padding(.vertical, AppTheme.spacingMD)
                                        .background(AppColors.primaryGradient).clipShape(Capsule())
                                }
                            }.frame(maxWidth: .infinity).padding(.vertical, AppTheme.spacingXL)
                        }
                    }
                }.padding(.horizontal, AppTheme.spacingLG).padding(.bottom, AppTheme.spacingXXL)
            }
            .background(AppColors.backgroundGradient.ignoresSafeArea())
            .navigationTitle("\u4f53\u80fd\u526f\u672c").navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .refreshable { await viewModel.refresh() }.task { await viewModel.requestPermission() }
        }.preferredColorScheme(.dark)
    }

    private func questCard(_ icon: String, _ title: String, _ value: String, _ progress: Double, _ color: Color) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
                HStack { Image(systemName: icon).foregroundStyle(color); Text(title).font(AppTypography.caption).foregroundStyle(AppColors.textSecondary); Spacer() }
                Text(value).font(AppTypography.statMedium).foregroundStyle(AppColors.textPrimary)
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3).fill(AppColors.backgroundTertiary)
                        RoundedRectangle(cornerRadius: 3).fill(color).frame(width: geo.size.width * min(progress, 1))
                    }
                }.frame(height: 4)
            }
        }
    }

    /// \u5468\u6b65\u6570\u67f1\u72b6\u56fe
    private var weeklyChart: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                Text("\u672c\u5468\u6b65\u6570").font(AppTypography.heading3).foregroundStyle(AppColors.textPrimary)
                HStack(alignment: .bottom, spacing: AppTheme.spacingSM) {
                    ForEach(Array(viewModel.weekRecords.enumerated()), id: \.offset) { _, r in
                        let maxS = viewModel.weekRecords.map(\.steps).max() ?? 1
                        VStack(spacing: 4) {
                            Text("\(r.steps / 1000)k").font(.system(size: 8)).foregroundStyle(AppColors.textTertiary)
                            RoundedRectangle(cornerRadius: 4).fill(r.date.isToday ? AppColors.neonGradient : LinearGradient(colors: [AppColors.primary.opacity(0.5)], startPoint: .top, endPoint: .bottom))
                                .frame(height: max(4, CGFloat(r.steps) / CGFloat(max(maxS, 1)) * 100))
                            Text(r.date.shortDateString).font(.system(size: 8)).foregroundStyle(AppColors.textTertiary)
                        }.frame(maxWidth: .infinity)
                    }
                }.frame(height: 130)
            }
        }
    }
}
