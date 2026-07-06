import Foundation

struct GitHubEventDTO: Decodable {
    let id: String
    let type: String
    let repo: RepoRef
    let createdAt: Date

    struct RepoRef: Decodable {
        let name: String
    }

    func toDomain() -> GitHubProfile.Event {
        GitHubProfile.Event(
            id: id,
            type: GitHubProfile.Event.EventType(rawValue: type) ?? .other,
            repoName: repo.name,
            createdAt: createdAt
        )
    }
}
