import Foundation

final class FetchGitHubDataUseCase: @unchecked Sendable {
    private let githubRepo: GitHubRepositoryProtocol

    init(githubRepo: GitHubRepositoryProtocol) {
        self.githubRepo = githubRepo
    }

    func execute(username: String) async throws -> GitHubProfile {
        try await githubRepo.fetchProfile(username: username)
    }

    func fetchContributions(username: String) async throws -> ContributionSummary {
        let events = try await githubRepo.fetchEvents(username: username)
        let pushEvents = events.filter { $0.type == .push }

        var dailyCounts: [String: Int] = [:]
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        for event in pushEvents {
            let key = formatter.string(from: event.createdAt)
            dailyCounts[key, default: 0] += 1
        }

        return ContributionSummary(dailyCounts: dailyCounts)
    }
}

struct ContributionSummary: Sendable {
    let dailyCounts: [String: Int]

    var maxCount: Int {
        dailyCounts.values.max() ?? 0
    }

    func count(for dateString: String) -> Int {
        dailyCounts[dateString] ?? 0
    }
}
