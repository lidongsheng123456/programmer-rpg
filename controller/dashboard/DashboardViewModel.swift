import SwiftUI

/// \u6218\u529b\u4eea\u8868\u76d8 ViewModel\uff0c\u8d1f\u8d23\u52a0\u8f7d\u6218\u529b\u6570\u636e\u548c\u6210\u5c31\u7edf\u8ba1
@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var powerStats: PowerStats = .zero
    @Published var achievementCount: Int = 0
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let calculatePower: CalculatePowerUseCase
    private let evaluateAchievement: EvaluateAchievementUseCase
    @AppStorage(AppConfig.StorageKey.githubUsername) private var githubUsername = AppConfig.defaultGitHubUsername

    init(calculatePower: CalculatePowerUseCase, evaluateAchievement: EvaluateAchievementUseCase) {
        self.calculatePower = calculatePower; self.evaluateAchievement = evaluateAchievement
    }

    /// \u5237\u65b0\u6218\u529b\u6570\u636e\u548c\u6210\u5c31\u6570\u91cf
    func refresh() async {
        isLoading = true; errorMessage = nil
        do { powerStats = try await calculatePower.execute(username: githubUsername); achievementCount = evaluateAchievement.getUnlockedCount() }
        catch { errorMessage = error.localizedDescription }
        isLoading = false
    }
}
