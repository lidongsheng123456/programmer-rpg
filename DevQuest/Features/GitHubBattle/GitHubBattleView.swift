import SwiftUI

struct GitHubBattleView: View {
    @ObservedObject var viewModel: GitHubBattleViewModel
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.spacingXL) {
                    if let p = viewModel.profile {
                        GlassCard {
                            HStack(spacing: AppTheme.spacingLG) {
                                AsyncImage(url: URL(string: p.avatarURL)) { img in img.resizable().scaledToFill() } placeholder: { Circle().fill(AppColors.backgroundTertiary) }
                                    .frame(width: 64, height: 64).clipShape(Circle()).overlay(Circle().strokeBorder(AppColors.primary, lineWidth: 2))
                                VStack(alignment: .leading, spacing: AppTheme.spacingXS) {
                                    Text(p.username).font(AppTypography.heading2).foregroundStyle(AppColors.textPrimary)
                                    HStack(spacing: AppTheme.spacingMD) {
                                        Label("\(p.followers)", systemImage: "person.2.fill"); Label("\(p.publicRepos)", systemImage: "folder.fill")
                                    }.font(AppTypography.caption).foregroundStyle(AppColors.textSecondary)
                                }; Spacer()
                            }
                        }
                        HStack(spacing: AppTheme.spacingMD) {
                            StatCard(title: "浠婃棩 Commits", value: "\(p.todayCommits)", icon: "flame.fill", iconColor: AppColors.accent)
                            StatCard(title: "鎬?Stars", value: "\(p.totalStars)", icon: "star.fill", iconColor: AppColors.accentGold)
                        }
                        if let c = viewModel.contributions {
                            GlassCard {
                                VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                                    Text("璐＄尞鐑姏鍥?).font(AppTypography.heading3).foregroundStyle(AppColors.textPrimary)
                                    ContributionGridView(summary: c).frame(height: 120)
                                }
                            }
                        }
                        VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                            Text("鐑棬浠撳簱").font(AppTypography.heading3).foregroundStyle(AppColors.textPrimary)
                            ForEach(p.repos.sorted(by: { $0.stargazersCount > $1.stargazersCount }).prefix(5)) { repo in
                                GlassCard(padding: AppTheme.spacingMD) {
                                    VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
                                        HStack { Text(repo.name).font(AppTypography.heading3).foregroundStyle(AppColors.textPrimary); Spacer()
                                            HStack(spacing: 4) { Image(systemName: "star.fill").foregroundStyle(AppColors.accentGold); Text("\(repo.stargazersCount)").font(AppTypography.statSmall).foregroundStyle(AppColors.textPrimary) } }
                                        if let d = repo.description { Text(d).font(AppTypography.bodySmall).foregroundStyle(AppColors.textSecondary).lineLimit(2) }
                                        if let l = repo.language { HStack(spacing: 4) { Circle().fill(AppColors.info).frame(width: 8, height: 8); Text(l) }.font(AppTypography.captionSmall).foregroundStyle(AppColors.textTertiary) }
                                    }
                                }
                            }
                        }
                    } else if viewModel.isLoading {
                        ProgressView().tint(AppColors.primary).padding(.top, 100)
                    }
                }.padding(.horizontal, AppTheme.spacingLG).padding(.bottom, AppTheme.spacingXXL)
            }
            .background(AppColors.backgroundGradient.ignoresSafeArea())
            .navigationTitle("GitHub 鎴樻姤").navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .refreshable { await viewModel.refresh() }.task { await viewModel.refresh() }
        }.preferredColorScheme(.dark)
    }
}