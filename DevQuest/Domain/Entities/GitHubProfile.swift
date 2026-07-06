import Foundation

struct GitHubProfile: Codable, Sendable {
    let username: String; let avatarURL: String; let followers: Int; let publicRepos: Int; let totalStars: Int
    var events: [Event]; var repos: [Repo]

    struct Event: Codable, Identifiable, Sendable {
        let id: String; let type: EventType; let repoName: String; let createdAt: Date
        enum EventType: String, Codable, Sendable {
            case push = "PushEvent", pullRequest = "PullRequestEvent", issues = "IssuesEvent"
            case issueComment = "IssueCommentEvent", create = "CreateEvent", watch = "WatchEvent", fork = "ForkEvent", other
            init(from decoder: Decoder) throws { let v = try decoder.singleValueContainer().decode(String.self); self = EventType(rawValue: v) ?? .other }
        }
    }
    struct Repo: Codable, Identifiable, Sendable {
        let id: Int; let name: String; let fullName: String; let description: String?; let language: String?
        let stargazersCount: Int; let forksCount: Int; let updatedAt: Date
    }
    var todayCommits: Int { events.filter { $0.type == .push && $0.createdAt.isToday }.count }
    var weekCommits: Int { let w = Date().daysAgo7; return events.filter { $0.type == .push && $0.createdAt > w }.count }
}