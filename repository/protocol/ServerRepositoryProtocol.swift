import Foundation

/// 服务器仓库协议，类比 Spring Boot 的 @Repository 接口
protocol ServerRepositoryProtocol: Sendable {
    func ping(config: ServerConfig) async throws -> ServerStatus
    func pingAll() async throws -> [ServerStatus]
    func getConfigs() -> [ServerConfig]
    func saveConfig(_ config: ServerConfig)
    func removeConfig(id: UUID)
    func getHistory(for configId: UUID) -> ServerPingHistory?
    func saveHistory(_ history: ServerPingHistory)
}