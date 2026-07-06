import Foundation

final class GitHubRepositoryImpl: GitHubRepositoryProtocol, @unchecked Sendable {
    private let remote: GitHubRemoteDataSource
    private let local: UserDefaultsDataSource

    init(remote: GitHubRemoteDataSource, local: UserDefaultsDataSource) {
        self.remote = remote
        self.local = local
    }

    func fetchProfile(username: String) async throws -> GitHubProfile {
        async let userTask = remote.fetchUser(username: username)
        async let eventsTask = remote.fetchEvents(username: username)
        async let reposTask = remote.fetchRepos(username: username)

        let user = try await userTask
        let eventDTOs = try await eventsTask
        let repoDTOs = try await reposTask

        let events = eventDTOs.map { $0.toDomain() }
        let repos = repoDTOs.map { $0.toDomain() }
        let totalStars = repos.reduce(0) { $0 + $1.stargazersCount }

        return user.toDomain(stars: totalStars, events: events, repos: repos)
    }

    func fetchEvents(username: String) async throws -> [GitHubProfile.Event] {
        let dtos = try await remote.fetchEvents(username: username)
        return dtos.map { $0.toDomain() }
    }

    func fetchRepos(username: String) async throws -> [GitHubProfile.Repo] {
        let dtos = try await remote.fetchRepos(username: username)
        return dtos.map { $0.toDomain() }
    }
}
