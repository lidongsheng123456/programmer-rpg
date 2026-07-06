import Foundation

final class FetchGitHubDataUseCase: @unchecked Sendable {
    private let githubRepo: GitHubRepositoryProtocol
    init(githubRepo: GitHubRepositoryProtocol) { self.githubRepo = githubRepo }

    func execute(username: String) async throws -> GitHubProfile { try await githubRepo.fetchProfile(username: username) }

    func fetchContributions(username: String) async throws -> ContributionSummary {
        let events = try await githubRepo.fetchEvents(username: username)
        var daily: [String: Int] = [:]
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
        for e in events.filter({ $0.type == .push }) { daily[f.string(from: e.createdAt), default: 0] += 1 }
        return ContributionSummary(dailyCounts: daily)
    }
}

struct ContributionSummary: Sendable {
    let dailyCounts: [String: Int]
    var maxCount: Int { dailyCounts.values.max() ?? 0 }
    func count(for dateString: String) -> Int { dailyCounts[dateString] ?? 0 }
}