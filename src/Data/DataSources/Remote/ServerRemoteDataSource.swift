import Foundation

final class ServerRemoteDataSource: @unchecked Sendable {
    private let network: NetworkClientProtocol

    init(network: NetworkClientProtocol) {
        self.network = network
    }

    func ping(url: String) async throws -> ServerPingResultDTO {
        guard let pingURL = URL(string: url) else {
            throw NetworkError.invalidURL(url)
        }
        let result = try await network.head(url: pingURL)
        return ServerPingResultDTO(
            statusCode: result.statusCode,
            responseTimeMs: result.responseTimeMs,
            isHealthy: result.isHealthy,
            timestamp: Date()
        )
    }
}
