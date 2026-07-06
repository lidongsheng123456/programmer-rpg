import SwiftUI

/// GitHub \u6218\u573a ViewModel\uff0c\u52a0\u8f7d\u7528\u6237 GitHub \u8d44\u6599\u548c\u8d21\u732e\u6570\u636e
@MainActor
final class GitHubBattleViewModel: ObservableObject {
    @Published var profile: GitHubProfile?; @Published var contributions: ContributionSummary?
    @Published var isLoading = false; @Published var errorMessage: String?
    @AppStorage(AppConfig.StorageKey.githubUsername) var githubUsername = AppConfig.defaultGitHubUsername
    private let fetchGitHubData: FetchGitHubDataUseCase
    init(fetchGitHubData: FetchGitHubDataUseCase) { self.fetchGitHubData = fetchGitHubData }

    /// \u5e76\u53d1\u52a0\u8f7d\u7528\u6237\u8d44\u6599\u548c\u8d21\u732e\u6570\u636e
    func refresh() async {
        isLoading = true; errorMessage = nil
        do {
            async let p = fetchGitHubData.execute(username: githubUsername)
            async let c = fetchGitHubData.fetchContributions(username: githubUsername)
            profile = try await p; contributions = try await c
        } catch { errorMessage = error.localizedDescription }
        isLoading = false
    }
}
