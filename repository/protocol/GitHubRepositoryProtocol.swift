import Foundation

/// GitHub 仓库协议
protocol GitHubRepositoryProtocol: Sendable {
    func fetchProfile(username: String) async throws -> GitHubProfile
    func fetchEvents(username: String) async throws -> [GitHubProfile.Event]
    func fetchRepos(username: String) async throws -> [GitHubProfile.Repo]
}