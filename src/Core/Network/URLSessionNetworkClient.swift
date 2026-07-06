import Foundation

final class URLSessionNetworkClient: NetworkClientProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    func get<T: Decodable>(url: URL, headers: [String: String] = [:]) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = AppConfig.networkTimeoutSeconds
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }

        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknown(URLError(.badServerResponse))
            }
            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.httpError(statusCode: httpResponse.statusCode)
            }
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw NetworkError.decodingFailed(error)
            }
        } catch let error as NetworkError {
            throw error
        } catch let error as URLError where error.code == .timedOut {
            throw NetworkError.timeout
        } catch let error as URLError where error.code == .notConnectedToInternet {
            throw NetworkError.noConnection
        } catch {
            throw NetworkError.unknown(error)
        }
    }

    func head(url: URL) async throws -> HTTPPingResult {
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        request.timeoutInterval = AppConfig.pingTimeoutSeconds

        let start = CFAbsoluteTimeGetCurrent()
        do {
            let (_, response) = try await session.data(for: request)
            let elapsed = Int((CFAbsoluteTimeGetCurrent() - start) * 1000)
            let code = (response as? HTTPURLResponse)?.statusCode ?? 0
            return HTTPPingResult(
                statusCode: code,
                responseTimeMs: elapsed,
                isHealthy: (200...399).contains(code)
            )
        } catch {
            let elapsed = Int((CFAbsoluteTimeGetCurrent() - start) * 1000)
            return HTTPPingResult(statusCode: 0, responseTimeMs: elapsed, isHealthy: false)
        }
    }
}
