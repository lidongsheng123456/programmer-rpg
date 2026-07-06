import Foundation

struct BlogPost: Codable, Identifiable, Sendable {
    let id: String
    let title: String
    let url: String
    let publishedAt: Date?

    var isRecent: Bool {
        guard let date = publishedAt else { return false }
        return date > Date().daysAgo7
    }

    var dateDisplay: String {
        guard let date = publishedAt else { return "未知日期" }
        return date.shortDateString
    }
}
