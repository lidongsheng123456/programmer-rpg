import SwiftUI

/// GitHub 战场视图，展示提交统计、贡献热力图和热门仓库
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
                            StatCard(title: "\u4eca\u65e5\u63d0\u4ea4", value: "\(p.todayCommits)", icon: "flame.fill", iconColor: AppColors.accent)
                            StatCard(title: "\u603b Star \u6570", value: "\(p.totalStars)", icon: "star.fill", iconColor: AppColors.accentGold)
                        }
                        if let c = viewModel.contributions {
                            GlassCard {
                                VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                                    Text("\u8d21\u732e\u70ed\u529b\u56fe").font(AppTypography.heading3).foregroundStyle(AppColors.textPrimary)
                                    ContributionGridView(summary: c).frame(height: 120)
                                }
                            }
                        }
                        VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                            Text("\u70ed\u95e8\u4ed3\u5e93").font(AppTypography.heading3).foregroundStyle(AppColors.textPrimary)
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
            .navigationTitle("GitHub \u6218\u573a").navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .refreshable { await viewModel.refresh() }.task { await viewModel.refresh() }
        }.preferredColorScheme(.dark)
    }
}
