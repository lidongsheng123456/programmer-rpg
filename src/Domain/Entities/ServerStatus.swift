import Foundation

struct ServerConfig: Codable, Identifiable, Sendable {
    let id: UUID
    var name: String
    var url: String
    var guardianEmoji: String

    init(id: UUID = UUID(), name: String, url: String, guardianEmoji: String = "🐉") {
        self.id = id
        self.name = name
        self.url = url
        self.guardianEmoji = guardianEmoji
    }

    static let `default` = ServerConfig(
        name: "主服务器",
        url: "http://47.104.236.251",
        guardianEmoji: "🐉"
    )
}

struct ServerStatus: Codable, Identifiable, Sendable {
    let id: UUID
    let config: ServerConfig
    let isOnline: Bool
    let statusCode: Int
    let responseTimeMs: Int
    let checkedAt: Date

    var uptimeDisplay: String {
        isOnline ? "\(responseTimeMs)ms" : "离线"
    }
}

struct ServerPingHistory: Codable, Sendable {
    let configId: UUID
    var records: [PingRecord]

    struct PingRecord: Codable, Sendable {
        let timestamp: Date
        let responseTimeMs: Int
        let isOnline: Bool
    }

    var uptimePercentage: Double {
        guard !records.isEmpty else { return 0 }
        let onlineCount = records.filter(\.isOnline).count
        return Double(onlineCount) / Double(records.count) * 100.0
    }

    var recentRecords: [PingRecord] {
        let cutoff = Date().daysAgo7
        return records.filter { $0.timestamp > cutoff }
    }
}
