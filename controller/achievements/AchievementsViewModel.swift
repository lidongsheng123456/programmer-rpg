import SwiftUI

/// 成就系统 ViewModel，管理成就评估和分类筛选
@MainActor
final class AchievementsViewModel: ObservableObject {
    @Published var achievementStatuses: [AchievementStatus] = []; @Published var isLoading = false
    @Published var errorMessage: String?; @Published var selectedCategory: Achievement.Category?
    @AppStorage(AppConfig.StorageKey.githubUsername) private var githubUsername = AppConfig.defaultGitHubUsername
    private let evaluateAchievement: EvaluateAchievementUseCase
    init(evaluateAchievement: EvaluateAchievementUseCase) { self.evaluateAchievement = evaluateAchievement }

    /// 按分类筛选后的成就列表
    var filteredStatuses: [AchievementStatus] { guard let c = selectedCategory else { return achievementStatuses }; return achievementStatuses.filter { $0.achievement.category == c } }
    var unlockedCount: Int { achievementStatuses.filter(\.isUnlocked).count }
    var totalCount: Int { achievementStatuses.count }

    /// 刷新成就评估结果
    func refresh() async {
        isLoading = true; errorMessage = nil
        do { achievementStatuses = try await evaluateAchievement.evaluate(username: githubUsername) } catch { errorMessage = error.localizedDescription }
        isLoading = false
    }
}
