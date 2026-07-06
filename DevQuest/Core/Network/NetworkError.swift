import Foundation

enum NetworkError: LocalizedError {
    case invalidURL(String)
    case httpError(statusCode: Int)
    case decodingFailed(Error)
    case timeout
    case noConnection
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL(let url):       return "Invalid URL: \(url)"
        case .httpError(let code):       return "HTTP error: \(code)"
        case .decodingFailed(let error): return "Decode failed: \(error.localizedDescription)"
        case .timeout:                   return "Request timeout"
        case .noConnection:              return "No connection"
        case .unknown(let error):        return "Unknown: \(error.localizedDescription)"
        }
    }
}