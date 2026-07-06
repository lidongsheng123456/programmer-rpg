import Foundation
final class GitHubRepositoryImpl: GitHubRepositoryProtocol, @unchecked Sendable {
    private let remote: GitHubRemoteDataSource; private let local: UserDefaultsDataSource
    init(remote: GitHubRemoteDataSource, local: UserDefaultsDataSource) { self.remote = remote; self.local = local }

    func fetchProfile(username: String) async throws -> GitHubProfile {
        async let u = remote.fetchUser(username: username)
        async let e = remote.fetchEvents(username: username)
        async let r = remote.fetchRepos(username: username)
        let user = try await u; let events = (try await e).map { $0.toDomain() }; let repos = (try await r).map { $0.toDomain() }
        return user.toDomain(stars: repos.reduce(0) { $0 + $1.stargazersCount }, events: events, repos: repos)
    }
    func fetchEvents(username: String) async throws -> [GitHubProfile.Event] { (try await remote.fetchEvents(username: username)).map { $0.toDomain() } }
    func fetchRepos(username: String) async throws -> [GitHubProfile.Repo] { (try await remote.fetchRepos(username: username)).map { $0.toDomain() } }
}