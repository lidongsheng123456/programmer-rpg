import SwiftUI

struct AchievementsView: View {
    @ObservedObject var viewModel: AchievementsViewModel
    @State private var showSettings = false
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.spacingXL) {
                    GlassCard {
                        HStack {
                            VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
                                Text("Achievement Progress").font(AppTypography.heading2).foregroundStyle(AppColors.textPrimary)
                                Text("\(viewModel.unlockedCount) / \(viewModel.totalCount) Unlocked").font(AppTypography.bodyMedium).foregroundStyle(AppColors.accentGold)
                            }; Spacer()
                            AnimatedProgressRing(progress: viewModel.totalCount > 0 ? Double(viewModel.unlockedCount) / Double(viewModel.totalCount) : 0, size: 70, gradientColors: [AppColors.accentGold, AppColors.accent])
                                .overlay { Image(systemName: "trophy.fill").foregroundStyle(AppColors.accentGold) }
                        }
                    }
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: AppTheme.spacingSM) {
                            catChip(nil, "All")
                            ForEach(Achievement.Category.allCases, id: \.self) { c in catChip(c, c.rawValue) }
                        }
                    }
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: AppTheme.spacingMD), GridItem(.flexible(), spacing: AppTheme.spacingMD)], spacing: AppTheme.spacingMD) {
                        ForEach(viewModel.filteredStatuses) { s in
                            GlassCard(padding: AppTheme.spacingMD) {
                                VStack(spacing: AppTheme.spacingSM) {
                                    ZStack {
                                        Circle().fill(s.isUnlocked ? AppColors.accentGold.opacity(0.15) : AppColors.backgroundTertiary).frame(width: 52, height: 52)
                                        Image(systemName: s.achievement.icon).font(.system(size: 24)).foregroundStyle(s.isUnlocked ? AppColors.accentGold : AppColors.textTertiary)
                                    }
                                    Text(s.achievement.title).font(AppTypography.label).foregroundStyle(s.isUnlocked ? AppColors.textPrimary : AppColors.textTertiary).lineLimit(1)
                                    Text(s.achievement.description).font(AppTypography.captionSmall).foregroundStyle(AppColors.textTertiary).multilineTextAlignment(.center).lineLimit(2)
                                    if !s.isUnlocked {
                                        GeometryReader { geo in ZStack(alignment: .leading) { RoundedRectangle(cornerRadius: 2).fill(AppColors.backgroundTertiary); RoundedRectangle(cornerRadius: 2).fill(AppColors.primary.opacity(0.6)).frame(width: geo.size.width * s.progress) } }.frame(height: 3)
                                    }
                                }
                            }.opacity(s.isUnlocked ? 1 : 0.6)
                        }
                    }
                }.padding(.horizontal, AppTheme.spacingLG).padding(.bottom, AppTheme.spacingXXL)
            }
            .background(AppColors.backgroundGradient.ignoresSafeArea())
            .navigationTitle("Achievements").navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button { showSettings = true } label: { Image(systemName: "gearshape.fill").foregroundStyle(AppColors.textSecondary) } } }
            .sheet(isPresented: $showSettings) { SettingsView(viewModel: SettingsViewModel()) }
            .refreshable { await viewModel.refresh() }.task { await viewModel.refresh() }
        }.preferredColorScheme(.dark)
    }

    private func catChip(_ cat: Achievement.Category?, _ label: String) -> some View {
        let sel = viewModel.selectedCategory == cat
        return Button { withAnimation(AppTheme.animationFast) { viewModel.selectedCategory = cat } } label: {
            Text(label).font(AppTypography.label).foregroundStyle(sel ? .white : AppColors.textSecondary)
                .padding(.horizontal, AppTheme.spacingMD).padding(.vertical, AppTheme.spacingSM)
                .background(sel ? AnyShapeStyle(AppColors.primaryGradient) : AnyShapeStyle(AppColors.backgroundTertiary)).clipShape(Capsule())
        }
    }
}
