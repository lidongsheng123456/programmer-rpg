import Foundation

/// \u7f51\u7edc\u5ba2\u6237\u7aef\u534f\u8bae\uff0c\u7c7b\u6bd4 Spring Boot \u7684 RestTemplate \u63a5\u53e3
protocol NetworkClientProtocol: Sendable {
    func get<T: Decodable>(url: URL, headers: [String: String]) async throws -> T
    func head(url: URL) async throws -> HTTPPingResult
}

/// HTTP Ping \u7ed3\u679c
struct HTTPPingResult: Sendable {
    let statusCode: Int
    let responseTimeMs: Int
    let isHealthy: Bool
}
