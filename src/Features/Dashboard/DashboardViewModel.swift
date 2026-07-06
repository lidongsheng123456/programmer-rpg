import SwiftUI

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var powerStats: PowerStats = .zero
    @Published var achievementCount: Int = 0
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let calculatePower: CalculatePowerUseCase
    private let evaluateAchievement: EvaluateAchievementUseCase

    @AppStorage(AppConfig.StorageKey.githubUsername)
    private var githubUsername = AppConfig.defaultGitHubUsername

    init(
        calculatePower: CalculatePowerUseCase,
        evaluateAchievement: EvaluateAchievementUseCase
    ) {
        self.calculatePower = calculatePower
        self.evaluateAchievement = evaluateAchievement
    }

    func refresh() async {
        isLoading = true
        errorMessage = nil

        do {
            powerStats = try await calculatePower.execute(username: githubUsername)
            achievementCount = evaluateAchievement.getUnlockedCount()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
