import Foundation

struct BlogPost: Codable, Identifiable, Sendable {
    let id: String; let title: String; let url: String; let publishedAt: Date?
    var isRecent: Bool { guard let d = publishedAt else { return false }; return d > Date().daysAgo7 }
    var dateDisplay: String { guard let d = publishedAt else { return "鏈煡" }; return d.shortDateString }
}