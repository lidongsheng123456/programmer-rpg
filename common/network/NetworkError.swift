import Foundation

/// \u7f51\u7edc\u9519\u8bef\u679a\u4e3e\uff0c\u7edf\u4e00\u5f02\u5e38\u5904\u7406
enum NetworkError: LocalizedError {
    case invalidURL(String)
    case httpError(statusCode: Int)
    case decodingFailed(Error)
    case timeout
    case noConnection
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL(let url):       return "\u65e0\u6548URL: \(url)"
        case .httpError(let code):       return "HTTP\u9519\u8bef: \(code)"
        case .decodingFailed(let error): return "\u89e3\u7801\u5931\u8d25: \(error.localizedDescription)"
        case .timeout:                   return "\u8bf7\u6c42\u8d85\u65f6"
        case .noConnection:              return "\u7f51\u7edc\u672a\u8fde\u63a5"
        case .unknown(let error):        return "\u672a\u77e5\u9519\u8bef: \(error.localizedDescription)"
        }
    }
}
