import Foundation

/// 服务器 Ping 结果 DTO
struct ServerPingResultDTO: Sendable {
    let statusCode: Int; let responseTimeMs: Int; let isHealthy: Bool; let timestamp: Date
    func toDomain(config: ServerConfig) -> ServerStatus {
        ServerStatus(id: config.id, config: config, isOnline: isHealthy, statusCode: statusCode, responseTimeMs: responseTimeMs, checkedAt: timestamp)
    }
}