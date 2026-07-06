import Foundation

/// 博客仓库协议
protocol BlogRepositoryProtocol: Sendable {
    func fetchPosts() async throws -> [BlogPost]
    func getCachedPosts() -> [BlogPost]
}