import Foundation

/// 服务器健康检查服务，执行 Ping 并记录历史
final class CheckServerHealthUseCase: @unchecked Sendable {
    private let serverRepo: ServerRepositoryProtocol
    init(serverRepo: ServerRepositoryProtocol) { self.serverRepo = serverRepo }

    /// 批量 Ping 所有服务器并保存历史记录
    func execute() async throws -> [ServerStatus] {
        let statuses = try await serverRepo.pingAll()
        for status in statuses {
            var history = serverRepo.getHistory(for: status.config.id) ?? ServerPingHistory(configId: status.config.id, records: [])
            history.records.append(ServerPingHistory.PingRecord(timestamp: status.checkedAt, responseTimeMs: status.responseTimeMs, isOnline: status.isOnline))
            history.records = history.records.filter { $0.timestamp > Date().daysAgo7 }
            serverRepo.saveHistory(history)
        }
        return statuses
    }

    /// Ping 单个服务器
    func executeForConfig(_ config: ServerConfig) async throws -> ServerStatus {
        try await serverRepo.ping(config: config)
    }

    func getHistory(for configId: UUID) -> ServerPingHistory? {
        serverRepo.getHistory(for: configId)
    }
}
