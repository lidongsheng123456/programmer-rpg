import Foundation
final class ServerRepositoryImpl: ServerRepositoryProtocol, @unchecked Sendable {
    private let remote: ServerRemoteDataSource; private let local: UserDefaultsDataSource
    init(remote: ServerRemoteDataSource, local: UserDefaultsDataSource) { self.remote = remote; self.local = local }

    func ping(config: ServerConfig) async throws -> ServerStatus { (try await remote.ping(url: config.url)).toDomain(config: config) }
    func pingAll() async throws -> [ServerStatus] {
        try await withThrowingTaskGroup(of: ServerStatus.self) { group in
            for c in getConfigs() { group.addTask { try await self.ping(config: c) } }
            var r: [ServerStatus] = []; for try await s in group { r.append(s) }; return r
        }
    }
    func getConfigs() -> [ServerConfig] { local.getServerConfigs() }
    func saveConfig(_ config: ServerConfig) {
        var cs = local.getServerConfigs()
        if let i = cs.firstIndex(where: { $0.id == config.id }) { cs[i] = config } else { cs.append(config) }
        local.saveServerConfigs(cs)
    }
    func removeConfig(id: UUID) { var cs = local.getServerConfigs(); cs.removeAll { $0.id == id }; local.saveServerConfigs(cs) }
    func getHistory(for configId: UUID) -> ServerPingHistory? { local.getPingHistory(for: configId) }
    func saveHistory(_ history: ServerPingHistory) { local.savePingHistory(history) }
}