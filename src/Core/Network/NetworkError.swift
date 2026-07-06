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
        case .invalidURL(let url):
            return "无效的 URL: \(url)"
        case .httpError(let code):
            return "HTTP 错误: \(code)"
        case .decodingFailed(let error):
            return "数据解析失败: \(error.localizedDescription)"
        case .timeout:
            return "请求超时"
        case .noConnection:
            return "网络未连接"
        case .unknown(let error):
            return "未知错误: \(error.localizedDescription)"
        }
    }
}
