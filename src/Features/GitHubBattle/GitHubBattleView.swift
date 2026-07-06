import SwiftUI

struct GitHubBattleView: View {
    @ObservedObject var viewModel: GitHubBattleViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.spacingXL) {
                    if let profile = viewModel.profile {
                        profileHeader(profile)
                        battleStats(profile)
                        contributionSection
                        repoList(profile)
                    } else if viewModel.isLoading {
                        loadingPlaceholder
                    }

                    if let error = viewModel.errorMessage {
                        errorBanner(error)
                    }
                }
                .padding(.horizontal, AppTheme.spacingLG)
                .padding(.bottom, AppTheme.spacingXXL)
            }
            .background(AppColors.backgroundGradient.ignoresSafeArea())
            .navigationTitle("GitHub 战报")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .refreshable { await viewModel.refresh() }
            .task { await viewModel.refresh() }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Profile Header

    private func profileHeader(_ profile: GitHubProfile) -> some View {
        GlassCard {
            HStack(spacing: AppTheme.spacingLG) {
                AsyncImage(url: URL(string: profile.avatarURL)) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Circle().fill(AppColors.backgroundTertiary)
                }
                .frame(width: 64, height: 64)
                .clipShape(Circle())
                .overlay(Circle().strokeBorder(AppColors.primary, lineWidth: 2))

                VStack(alignment: .leading, spacing: AppTheme.spacingXS) {
                    Text(profile.username)
                        .font(AppTypography.heading2)
                        .foregroundStyle(AppColors.textPrimary)
                    HStack(spacing: AppTheme.spacingMD) {
                        Label("\(profile.followers)", systemImage: "person.2.fill")
                        Label("\(profile.publicRepos)", systemImage: "folder.fill")
                    }
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
                }
                Spacer()
            }
        }
    }

    // MARK: - Battle Stats

    private func battleStats(_ profile: GitHubProfile) -> some View {
        HStack(spacing: AppTheme.spacingMD) {
            StatCard(
                title: "今日 Commits",
                value: "\(profile.todayCommits)",
                icon: "flame.fill",
                iconColor: AppColors.accent
            )
            StatCard(
                title: "总 Stars",
                value: "\(profile.totalStars)",
                icon: "star.fill",
                iconColor: AppColors.accentGold
            )
        }
    }

    // MARK: - Contributions

    private var contributionSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                HStack {
                    Text("贡献热力图")
                        .font(AppTypography.heading3)
                        .foregroundStyle(AppColors.textPrimary)
                    Spacer()
                    Text("近 90 天")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textTertiary)
                }

                if let contributions = viewModel.contributions {
                    ContributionGridView(summary: contributions)
                        .frame(height: 120)
                }
            }
        }
    }

    // MARK: - Repo List

    private func repoList(_ profile: GitHubProfile) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
            Text("热门仓库")
                .font(AppTypography.heading3)
                .foregroundStyle(AppColors.textPrimary)

            ForEach(profile.repos.sorted(by: { $0.stargazersCount > $1.stargazersCount }).prefix(5)) { repo in
                repoRow(repo)
            }
        }
    }

    private func repoRow(_ repo: GitHubProfile.Repo) -> some View {
        GlassCard(padding: AppTheme.spacingMD) {
            VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
                HStack {
                    Text(repo.name)
                        .font(AppTypography.heading3)
                        .foregroundStyle(AppColors.textPrimary)
                    Spacer()
                    HStack(spacing: AppTheme.spacingXS) {
                        Image(systemName: "star.fill")
                            .foregroundStyle(AppColors.accentGold)
                        Text("\(repo.stargazersCount)")
                            .font(AppTypography.statSmall)
                            .foregroundStyle(AppColors.textPrimary)
                    }
                }

                if let desc = repo.description {
                    Text(desc)
                        .font(AppTypography.bodySmall)
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(2)
                }

                HStack(spacing: AppTheme.spacingMD) {
                    if let lang = repo.language {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(languageColor(lang))
                                .frame(width: 8, height: 8)
                            Text(lang)
                        }
                    }
                    HStack(spacing: 4) {
                        Image(systemName: "tuningfork")
                        Text("\(repo.forksCount)")
                    }
                }
                .font(AppTypography.captionSmall)
                .foregroundStyle(AppColors.textTertiary)
            }
        }
    }

    private func languageColor(_ lang: String) -> Color {
        switch lang.lowercased() {
        case "swift":      return Color(hex: 0xF05138)
        case "python":     return Color(hex: 0x3776AB)
        case "javascript": return Color(hex: 0xF7DF1E)
        case "typescript":  return Color(hex: 0x3178C6)
        case "java":       return Color(hex: 0xB07219)
        case "go":         return Color(hex: 0x00ADD8)
        case "rust":       return Color(hex: 0xDEA584)
        default:           return AppColors.textTertiary
        }
    }

    // MARK: - Loading & Error

    private var loadingPlaceholder: some View {
        VStack(spacing: AppTheme.spacingLG) {
            ProgressView().tint(AppColors.primary)
            Text("正在获取 GitHub 数据...")
                .font(AppTypography.bodyMedium)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 100)
    }

    private func errorBanner(_ message: String) -> some View {
        GlassCard {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(AppColors.warning)
                Text(message)
                    .font(AppTypography.bodySmall)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
    }
}
