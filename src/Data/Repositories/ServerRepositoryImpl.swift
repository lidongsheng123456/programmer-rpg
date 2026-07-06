import Foundation

final class ServerRepositoryImpl: ServerRepositoryProtocol, @unchecked Sendable {
    private let remote: ServerRemoteDataSource
    private let local: UserDefaultsDataSource

    init(remote: ServerRemoteDataSource, local: UserDefaultsDataSource) {
        self.remote = remote
        self.local = local
    }

    func ping(config: ServerConfig) async throws -> ServerStatus {
        let result = try await remote.ping(url: config.url)
        return result.toDomain(config: config)
    }

    func pingAll() async throws -> [ServerStatus] {
        let configs = getConfigs()
        return try await withThrowingTaskGroup(of: ServerStatus.self) { group in
            for config in configs {
                group.addTask {
                    try await self.ping(config: config)
                }
            }
            var results: [ServerStatus] = []
            for try await status in group {
                results.append(status)
            }
            return results
        }
    }

    func getConfigs() -> [ServerConfig] {
        local.getServerConfigs()
    }

    func saveConfig(_ config: ServerConfig) {
        var configs = local.getServerConfigs()
        if let index = configs.firstIndex(where: { $0.id == config.id }) {
            configs[index] = config
        } else {
            configs.append(config)
        }
        local.saveServerConfigs(configs)
    }

    func removeConfig(id: UUID) {
        var configs = local.getServerConfigs()
        configs.removeAll { $0.id == id }
        local.saveServerConfigs(configs)
    }

    func getHistory(for configId: UUID) -> ServerPingHistory? {
        local.getPingHistory(for: configId)
    }

    func saveHistory(_ history: ServerPingHistory) {
        local.savePingHistory(history)
    }
}
