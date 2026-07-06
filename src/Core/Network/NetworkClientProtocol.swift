import Foundation

protocol NetworkClientProtocol: Sendable {
    func get<T: Decodable>(url: URL, headers: [String: String]) async throws -> T
    func head(url: URL) async throws -> HTTPPingResult
}

struct HTTPPingResult: Sendable {
    let statusCode: Int
    let responseTimeMs: Int
    let isHealthy: Bool
}
