import SwiftUI

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
                                    Text("Today's Dungeon").font(AppTypography.heading2).foregroundStyle(AppColors.textPrimary)
                                    Text(viewModel.dungeonProgress?.isCompleted == true ? "Dungeon Cleared!" : "Challenge in progress...")
                                        .font(AppTypography.bodyMedium).foregroundStyle(viewModel.dungeonProgress?.isCompleted == true ? AppColors.accentGold : AppColors.textSecondary)
                                }; Spacer()
                                AnimatedProgressRing(progress: viewModel.dungeonProgress?.overallProgress ?? 0, size: 70, gradientColors: [AppColors.neonGreen, AppColors.neonCyan])
                                    .overlay { Text("\(Int((viewModel.dungeonProgress?.overallProgress ?? 0) * 100))%").font(AppTypography.statSmall).foregroundStyle(AppColors.textPrimary) }
                            }
                        }
                        HStack(spacing: AppTheme.spacingMD) {
                            questCard("figure.walk", "Steps", viewModel.todayRecord.stepsDisplay, viewModel.dungeonProgress?.stepsProgress ?? 0, AppColors.neonGreen)
                            questCard("flame.fill", "Calories", viewModel.todayRecord.caloriesDisplay, viewModel.dungeonProgress?.caloriesProgress ?? 0, AppColors.accent)
                        }
                        questCard("timer", "Exercise Time", viewModel.todayRecord.exerciseDisplay, viewModel.dungeonProgress?.exerciseProgress ?? 0, AppColors.info)
                        weeklyChart
                    } else {
                        GlassCard {
                            VStack(spacing: AppTheme.spacingLG) {
                                Image(systemName: "heart.text.square.fill").font(.system(size: 48)).foregroundStyle(AppColors.accent)
                                Text("HealthKit Permission Required").font(AppTypography.heading2).foregroundStyle(AppColors.textPrimary)
                                Button { Task { await viewModel.requestPermission() } } label: {
                                    Text("Authorize HealthKit").font(AppTypography.label).foregroundStyle(.white)
                                        .padding(.horizontal, AppTheme.spacingXL).padding(.vertical, AppTheme.spacingMD)
                                        .background(AppColors.primaryGradient).clipShape(Capsule())
                                }
                            }.frame(maxWidth: .infinity).padding(.vertical, AppTheme.spacingXL)
                        }
                    }
                }.padding(.horizontal, AppTheme.spacingLG).padding(.bottom, AppTheme.spacingXXL)
            }
            .background(AppColors.backgroundGradient.ignoresSafeArea())
            .navigationTitle("Fitness Dungeon").navigationBarTitleDisplayMode(.large)
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

    private var weeklyChart: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                Text("Weekly Steps").font(AppTypography.heading3).foregroundStyle(AppColors.textPrimary)
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
