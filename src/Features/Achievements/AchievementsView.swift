import SwiftUI

struct AchievementsView: View {
    @ObservedObject var viewModel: AchievementsViewModel
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.spacingXL) {
                    progressHeader
                    categoryFilter
                    achievementGrid
                }
                .padding(.horizontal, AppTheme.spacingLG)
                .padding(.bottom, AppTheme.spacingXXL)
            }
            .background(AppColors.backgroundGradient.ignoresSafeArea())
            .navigationTitle("成就殿堂")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(viewModel: SettingsViewModel())
            }
            .refreshable { await viewModel.refresh() }
            .task { await viewModel.refresh() }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Progress Header

    private var progressHeader: some View {
        GlassCard {
            HStack {
                VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
                    Text("成就进度")
                        .font(AppTypography.heading2)
                        .foregroundStyle(AppColors.textPrimary)
                    Text("\(viewModel.unlockedCount) / \(viewModel.totalCount) 已解锁")
                        .font(AppTypography.bodyMedium)
                        .foregroundStyle(AppColors.accentGold)
                }
                Spacer()
                AnimatedProgressRing(
                    progress: viewModel.totalCount > 0
                        ? Double(viewModel.unlockedCount) / Double(viewModel.totalCount)
                        : 0,
                    size: 70,
                    gradientColors: [AppColors.accentGold, AppColors.accent]
                )
                .overlay {
                    Image(systemName: "trophy.fill")
                        .foregroundStyle(AppColors.accentGold)
                }
            }
        }
    }

    // MARK: - Category Filter

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.spacingSM) {
                categoryChip(nil, label: "全部")
                ForEach(Achievement.Category.allCases, id: \.self) { category in
                    categoryChip(category, label: category.rawValue)
                }
            }
        }
    }

    private func categoryChip(_ category: Achievement.Category?, label: String) -> some View {
        let isSelected = viewModel.selectedCategory == category
        return Button {
            withAnimation(AppTheme.animationFast) {
                viewModel.selectedCategory = category
            }
        } label: {
            Text(label)
                .font(AppTypography.label)
                .foregroundStyle(isSelected ? .white : AppColors.textSecondary)
                .padding(.horizontal, AppTheme.spacingMD)
                .padding(.vertical, AppTheme.spacingSM)
                .background(
                    isSelected
                        ? AnyShapeStyle(AppColors.primaryGradient)
                        : AnyShapeStyle(AppColors.backgroundTertiary)
                )
                .clipShape(Capsule())
        }
    }

    // MARK: - Achievement Grid

    private var achievementGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: AppTheme.spacingMD),
            GridItem(.flexible(), spacing: AppTheme.spacingMD)
        ], spacing: AppTheme.spacingMD) {
            ForEach(viewModel.filteredStatuses) { status in
                achievementCard(status)
            }
        }
    }

    private func achievementCard(_ status: AchievementStatus) -> some View {
        GlassCard(padding: AppTheme.spacingMD) {
            VStack(spacing: AppTheme.spacingSM) {
                ZStack {
                    Circle()
                        .fill(status.isUnlocked
                              ? AppColors.accentGold.opacity(0.15)
                              : AppColors.backgroundTertiary)
                        .frame(width: 52, height: 52)
                    Image(systemName: status.achievement.icon)
                        .font(.system(size: 24))
                        .foregroundStyle(
                            status.isUnlocked ? AppColors.accentGold : AppColors.textTertiary
                        )
                }

                Text(status.achievement.title)
                    .font(AppTypography.label)
                    .foregroundStyle(
                        status.isUnlocked ? AppColors.textPrimary : AppColors.textTertiary
                    )
                    .lineLimit(1)

                Text(status.achievement.description)
                    .font(AppTypography.captionSmall)
                    .foregroundStyle(AppColors.textTertiary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)

                if !status.isUnlocked {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(AppColors.backgroundTertiary)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(AppColors.primary.opacity(0.6))
                                .frame(width: geo.size.width * status.progress)
                        }
                    }
                    .frame(height: 3)
                }
            }
        }
        .opacity(status.isUnlocked ? 1.0 : 0.6)
    }
}
