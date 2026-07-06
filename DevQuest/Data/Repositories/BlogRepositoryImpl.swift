import Foundation
final class BlogRepositoryImpl: BlogRepositoryProtocol, @unchecked Sendable {
    private let remote: BlogRemoteDataSource; private let local: UserDefaultsDataSource
    init(remote: BlogRemoteDataSource, local: UserDefaultsDataSource) { self.remote = remote; self.local = local }
    func fetchPosts() async throws -> [BlogPost] { let p = try await remote.fetchPosts(); local.cacheBlogPosts(p); return p }
    func getCachedPosts() -> [BlogPost] { local.getCachedBlogPosts() }
}