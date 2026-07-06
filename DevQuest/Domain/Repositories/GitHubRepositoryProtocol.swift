import Foundation
protocol GitHubRepositoryProtocol: Sendable {
    func fetchProfile(username: String) async throws -> GitHubProfile
    func fetchEvents(username: String) async throws -> [GitHubProfile.Event]
    func fetchRepos(username: String) async throws -> [GitHubProfile.Repo]
}