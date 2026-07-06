import Foundation

final class GitHubRemoteDataSource: @unchecked Sendable {
    private let network: NetworkClientProtocol
    private let baseURL: String

    init(network: NetworkClientProtocol, baseURL: String = AppConfig.githubAPIBase) {
        self.network = network
        self.baseURL = baseURL
    }

    func fetchUser(username: String) async throws -> GitHubUserDTO {
        guard let url = URL(string: "\(baseURL)/users/\(username)") else {
            throw NetworkError.invalidURL(username)
        }
        return try await network.get(url: url, headers: githubHeaders)
    }

    func fetchEvents(username: String) async throws -> [GitHubEventDTO] {
        guard let url = URL(string: "\(baseURL)/users/\(username)/events?per_page=100") else {
            throw NetworkError.invalidURL(username)
        }
        return try await network.get(url: url, headers: githubHeaders)
    }

    func fetchRepos(username: String) async throws -> [GitHubRepoDTO] {
        guard let url = URL(string: "\(baseURL)/users/\(username)/repos?sort=updated&per_page=100") else {
            throw NetworkError.invalidURL(username)
        }
        return try await network.get(url: url, headers: githubHeaders)
    }

    private var githubHeaders: [String: String] {
        [
            "Accept": "application/vnd.github.v3+json",
            "User-Agent": "DevQuest-iOS"
        ]
    }
}
