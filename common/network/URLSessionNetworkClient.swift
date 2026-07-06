import Foundation

/// \u57fa\u4e8e URLSession \u7684\u7f51\u7edc\u5ba2\u6237\u7aef\u5b9e\u73b0
final class URLSessionNetworkClient: NetworkClientProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    /// \u53d1\u9001 GET \u8bf7\u6c42\u5e76\u89e3\u7801\u54cd\u5e94
    func get<T: Decodable>(url: URL, headers: [String: String] = [:]) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = AppConfig.networkTimeoutSeconds
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else { throw NetworkError.unknown(URLError(.badServerResponse)) }
            guard (200...299).contains(http.statusCode) else { throw NetworkError.httpError(statusCode: http.statusCode) }
            do { return try decoder.decode(T.self, from: data) } catch { throw NetworkError.decodingFailed(error) }
        } catch let e as NetworkError { throw e }
        catch let e as URLError where e.code == .timedOut { throw NetworkError.timeout }
        catch let e as URLError where e.code == .notConnectedToInternet { throw NetworkError.noConnection }
        catch { throw NetworkError.unknown(error) }
    }

    /// \u53d1\u9001 HEAD \u8bf7\u6c42\u68c0\u6d4b\u670d\u52a1\u5668\u54cd\u5e94\u65f6\u95f4
    func head(url: URL) async throws -> HTTPPingResult {
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        request.timeoutInterval = AppConfig.pingTimeoutSeconds
        let start = CFAbsoluteTimeGetCurrent()
        do {
            let (_, response) = try await session.data(for: request)
            let elapsed = Int((CFAbsoluteTimeGetCurrent() - start) * 1000)
            let code = (response as? HTTPURLResponse)?.statusCode ?? 0
            return HTTPPingResult(statusCode: code, responseTimeMs: elapsed, isHealthy: (200...399).contains(code))
        } catch {
            let elapsed = Int((CFAbsoluteTimeGetCurrent() - start) * 1000)
            return HTTPPingResult(statusCode: 0, responseTimeMs: elapsed, isHealthy: false)
        }
    }
}
