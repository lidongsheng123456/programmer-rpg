import SwiftUI

struct FitnessDungeonView: View {
    @ObservedObject var viewModel: FitnessDungeonViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.spacingXL) {
                    if viewModel.isAuthorized {
                        dungeonHeader
                        todayStats
                        questProgress
                        weeklyChart
                    } else {
                        authorizationPrompt
                    }
                }
                .padding(.horizontal, AppTheme.spacingLG)
                .padding(.bottom, AppTheme.spacingXXL)
            }
            .background(AppColors.backgroundGradient.ignoresSafeArea())
            .navigationTitle("健身副本")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .refreshable { await viewModel.refresh() }
            .task { await viewModel.requestPermission() }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Authorization

    private var authorizationPrompt: some View {
        GlassCard {
            VStack(spacing: AppTheme.spacingLG) {
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(AppColors.accent)
                Text("需要 HealthKit 权限")
                    .font(AppTypography.heading2)
                    .foregroundStyle(AppColors.textPrimary)
                Text("授权后可追踪步数、卡路里和运动时间")
                    .font(AppTypography.bodyMedium)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                Button {
                    Task { await viewModel.requestPermission() }
                } label: {
                    Text("授权 HealthKit")
                        .font(AppTypography.label)
                        .foregroundStyle(.white)
                        .padding(.horizontal, AppTheme.spacingXL)
                        .padding(.vertical, AppTheme.spacingMD)
                        .background(AppColors.primaryGradient)
                        .clipShape(Capsule())
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.spacingXL)
        }
    }

    // MARK: - Dungeon Header

    private var dungeonHeader: some View {
        GlassCard {
            HStack {
                VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
                    Text("今日副本")
                        .font(AppTypography.heading2)
                        .foregroundStyle(AppColors.textPrimary)
                    Text(viewModel.dungeonProgress?.isCompleted == true ? "副本已通关!" : "挑战进行中...")
                        .font(AppTypography.bodyMedium)
                        .foregroundStyle(
                            viewModel.dungeonProgress?.isCompleted == true
                                ? AppColors.accentGold : AppColors.textSecondary
                        )
                }
                Spacer()
                AnimatedProgressRing(
                    progress: viewModel.dungeonProgress?.overallProgress ?? 0,
                    size: 70,
                    gradientColors: [AppColors.neonGreen, AppColors.neonCyan]
                )
                .overlay {
                    Text("\(Int((viewModel.dungeonProgress?.overallProgress ?? 0) * 100))%")
                        .font(AppTypography.statSmall)
                        .foregroundStyle(AppColors.textPrimary)
                }
            }
        }
    }

    // MARK: - Today Stats

    private var todayStats: some View {
        VStack(spacing: AppTheme.spacingMD) {
            HStack(spacing: AppTheme.spacingMD) {
                questCard(
                    icon: "figure.walk",
                    title: "步数",
                    value: viewModel.todayRecord.stepsDisplay,
                    progress: viewModel.dungeonProgress?.stepsProgress ?? 0,
                    goal: "10,000 步",
                    color: AppColors.neonGreen
                )
                questCard(
                    icon: "flame.fill",
                    title: "卡路里",
                    value: viewModel.todayRecord.caloriesDisplay,
                    progress: viewModel.dungeonProgress?.caloriesProgress ?? 0,
                    goal: "500 kcal",
                    color: AppColors.accent
                )
            }
            questCard(
                icon: "timer",
                title: "运动时间",
                value: viewModel.todayRecord.exerciseDisplay,
                progress: viewModel.dungeonProgress?.exerciseProgress ?? 0,
                goal: "30 分钟",
                color: AppColors.info
            )
        }
    }

    private func questCard(
        icon: String, title: String, value: String,
        progress: Double, goal: String, color: Color
    ) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
                HStack {
                    Image(systemName: icon)
                        .foregroundStyle(color)
                    Text(title)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                    Spacer()
                    Text(goal)
                        .font(AppTypography.captionSmall)
                        .foregroundStyle(AppColors.textTertiary)
                }
                Text(value)
                    .font(AppTypography.statMedium)
                    .foregroundStyle(AppColors.textPrimary)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(AppColors.backgroundTertiary)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(
                                LinearGradient(
                                    colors: [color.opacity(0.7), color],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * min(progress, 1.0))
                    }
                }
                .frame(height: 4)
            }
        }
    }

    // MARK: - Quest Progress

    private var questProgress: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                Text("副本任务")
                    .font(AppTypography.heading3)
                    .foregroundStyle(AppColors.textPrimary)

                questRow("完成 10,000 步",
                         completed: (viewModel.dungeonProgress?.stepsProgress ?? 0) >= 1.0)
                questRow("消耗 500 卡路里",
                         completed: (viewModel.dungeonProgress?.caloriesProgress ?? 0) >= 1.0)
                questRow("运动 30 分钟",
                         completed: (viewModel.dungeonProgress?.exerciseProgress ?? 0) >= 1.0)
            }
        }
    }

    private func questRow(_ text: String, completed: Bool) -> some View {
        HStack(spacing: AppTheme.spacingMD) {
            Image(systemName: completed ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(completed ? AppColors.success : AppColors.textTertiary)
            Text(text)
                .font(AppTypography.bodyMedium)
                .foregroundStyle(completed ? AppColors.textPrimary : AppColors.textSecondary)
                .strikethrough(completed, color: AppColors.textTertiary)
            Spacer()
        }
    }

    // MARK: - Weekly Chart

    private var weeklyChart: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                Text("本周步数")
                    .font(AppTypography.heading3)
                    .foregroundStyle(AppColors.textPrimary)

                HStack(alignment: .bottom, spacing: AppTheme.spacingSM) {
                    ForEach(Array(viewModel.weekRecords.enumerated()), id: \.offset) { index, record in
                        let maxSteps = viewModel.weekRecords.map(\.steps).max() ?? 1
                        let height = max(4, CGFloat(record.steps) / CGFloat(max(maxSteps, 1)) * 100)
                        VStack(spacing: 4) {
                            Text("\(record.steps / 1000)k")
                                .font(.system(size: 8))
                                .foregroundStyle(AppColors.textTertiary)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    record.date.isToday
                                        ? AppColors.neonGradient
                                        : LinearGradient(colors: [AppColors.primary.opacity(0.5)],
                                                        startPoint: .top, endPoint: .bottom)
                                )
                                .frame(height: height)
                            Text(record.date.shortDateString)
                                .font(.system(size: 8))
                                .foregroundStyle(AppColors.textTertiary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 130)
            }
        }
    }
}
