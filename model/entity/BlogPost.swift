import Foundation

/// \u535a\u5ba2\u6587\u7ae0\u5b9e\u4f53
struct BlogPost: Codable, Identifiable, Sendable {
    let id: String; let title: String; let url: String; let publishedAt: Date?
    var isRecent: Bool { guard let d = publishedAt else { return false }; return d > Date().daysAgo7 }
    var dateDisplay: String { guard let d = publishedAt else { return "\u672a\u77e5" }; return d.shortDateString }
}
