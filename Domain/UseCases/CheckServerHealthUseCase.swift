import Foundation

final class CheckServerHealthUseCase: @unchecked Sendable {
    private let serverRepo: ServerRepositoryProtocol
    init(serverRepo: ServerRepositoryProtocol) { self.serverRepo = serverRepo }

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

    func executeForConfig(_ config: ServerConfig) async throws -> ServerStatus {
        try await serverRepo.ping(config: config)
    }

    func getHistory(for configId: UUID) -> ServerPingHistory? {
        serverRepo.getHistory(for: configId)
    }
}