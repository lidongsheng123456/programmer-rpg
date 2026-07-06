import SwiftUI

@MainActor
final class GitHubBattleViewModel: ObservableObject {
    @Published var profile: GitHubProfile?
    @Published var contributions: ContributionSummary?
    @Published var isLoading = false
    @Published var errorMessage: String?

    @AppStorage(AppConfig.StorageKey.githubUsername)
    var githubUsername = AppConfig.defaultGitHubUsername

    private let fetchGitHubData: FetchGitHubDataUseCase

    init(fetchGitHubData: FetchGitHubDataUseCase) {
        self.fetchGitHubData = fetchGitHubData
    }

    func refresh() async {
        isLoading = true
        errorMessage = nil

        do {
            async let profileTask = fetchGitHubData.execute(username: githubUsername)
            async let contribTask = fetchGitHubData.fetchContributions(username: githubUsername)

            profile = try await profileTask
            contributions = try await contribTask
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
