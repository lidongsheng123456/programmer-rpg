import SwiftUI

@MainActor
final class AchievementsViewModel: ObservableObject {
    @Published var achievementStatuses: [AchievementStatus] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedCategory: Achievement.Category?

    @AppStorage(AppConfig.StorageKey.githubUsername)
    private var githubUsername = AppConfig.defaultGitHubUsername

    private let evaluateAchievement: EvaluateAchievementUseCase

    init(evaluateAchievement: EvaluateAchievementUseCase) {
        self.evaluateAchievement = evaluateAchievement
    }

    var filteredStatuses: [AchievementStatus] {
        guard let category = selectedCategory else { return achievementStatuses }
        return achievementStatuses.filter { $0.achievement.category == category }
    }

    var unlockedCount: Int {
        achievementStatuses.filter(\.isUnlocked).count
    }

    var totalCount: Int {
        achievementStatuses.count
    }

    func refresh() async {
        isLoading = true
        errorMessage = nil

        do {
            achievementStatuses = try await evaluateAchievement.evaluate(username: githubUsername)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
