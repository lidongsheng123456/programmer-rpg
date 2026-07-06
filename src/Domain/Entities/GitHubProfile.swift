import Foundation

struct GitHubProfile: Codable, Sendable {
    let username: String
    let avatarURL: String
    let followers: Int
    let publicRepos: Int
    let totalStars: Int
    var events: [Event]
    var repos: [Repo]

    struct Event: Codable, Identifiable, Sendable {
        let id: String
        let type: EventType
        let repoName: String
        let createdAt: Date

        enum EventType: String, Codable, Sendable {
            case push = "PushEvent"
            case pullRequest = "PullRequestEvent"
            case issues = "IssuesEvent"
            case issueComment = "IssueCommentEvent"
            case create = "CreateEvent"
            case watch = "WatchEvent"
            case fork = "ForkEvent"
            case other

            init(from decoder: Decoder) throws {
                let value = try decoder.singleValueContainer().decode(String.self)
                self = EventType(rawValue: value) ?? .other
            }
        }
    }

    struct Repo: Codable, Identifiable, Sendable {
        let id: Int
        let name: String
        let fullName: String
        let description: String?
        let language: String?
        let stargazersCount: Int
        let forksCount: Int
        let updatedAt: Date
    }

    var todayCommits: Int {
        events.filter { $0.type == .push && $0.createdAt.isToday }.count
    }

    var weekCommits: Int {
        let weekAgo = Date().daysAgo7
        return events.filter { $0.type == .push && $0.createdAt > weekAgo }.count
    }
}
