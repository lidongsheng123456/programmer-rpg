import Foundation

protocol ServerRepositoryProtocol: Sendable {
    func ping(config: ServerConfig) async throws -> ServerStatus
    func pingAll() async throws -> [ServerStatus]
    func getConfigs() -> [ServerConfig]
    func saveConfig(_ config: ServerConfig)
    func removeConfig(id: UUID)
    func getHistory(for configId: UUID) -> ServerPingHistory?
    func saveHistory(_ history: ServerPingHistory)
}
