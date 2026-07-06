import Foundation

protocol BlogRepositoryProtocol: Sendable {
    func fetchPosts() async throws -> [BlogPost]
    func getCachedPosts() -> [BlogPost]
}
