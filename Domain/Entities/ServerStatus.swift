import Foundation

struct ServerConfig: Codable, Identifiable, Sendable {
    let id: UUID; var name: String; var url: String; var guardianEmoji: String
    init(id: UUID = UUID(), name: String, url: String, guardianEmoji: String = "\u{1F43B}") {
        self.id = id; self.name = name; self.url = url; self.guardianEmoji = guardianEmoji
    }
    static let `default` = ServerConfig(name: "Main Server", url: "http://47.104.236.251", guardianEmoji: "\u{1F43B}")
}

struct ServerStatus: Codable, Identifiable, Sendable {
    let id: UUID; let config: ServerConfig; let isOnline: Bool; let statusCode: Int; let responseTimeMs: Int; let checkedAt: Date
    var uptimeDisplay: String { isOnline ? "\(responseTimeMs)ms" : "Offline" }
}

struct ServerPingHistory: Codable, Sendable {
    let configId: UUID; var records: [PingRecord]
    struct PingRecord: Codable, Sendable { let timestamp: Date; let responseTimeMs: Int; let isOnline: Bool }
    var uptimePercentage: Double {
        guard !records.isEmpty else { return 0 }
        return Double(records.filter(\.isOnline).count) / Double(records.count) * 100.0
    }
    var recentRecords: [PingRecord] { records.filter { $0.timestamp > Date().daysAgo7 } }
}
