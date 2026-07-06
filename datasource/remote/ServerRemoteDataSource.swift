import Foundation

/// 服务器远程数据源，负责 HTTP Ping 检测
final class ServerRemoteDataSource: @unchecked Sendable {
    private let network: NetworkClientProtocol
    init(network: NetworkClientProtocol) { self.network = network }
    func ping(url: String) async throws -> ServerPingResultDTO {
        guard let u = URL(string: url) else { throw NetworkError.invalidURL(url) }
        let r = try await network.head(url: u)
        return ServerPingResultDTO(statusCode: r.statusCode, responseTimeMs: r.responseTimeMs, isHealthy: r.isHealthy, timestamp: Date())
    }
}