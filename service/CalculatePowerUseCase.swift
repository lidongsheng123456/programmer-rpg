import Foundation

/// 战力计算服务，聚合多个数据源计算六维战力值
final class CalculatePowerUseCase: @unchecked Sendable {
    private let serverRepo: ServerRepositoryProtocol
    private let githubRepo: GitHubRepositoryProtocol
    private let healthRepo: HealthRepositoryProtocol
    private let blogRepo: BlogRepositoryProtocol

    init(serverRepo: ServerRepositoryProtocol, githubRepo: GitHubRepositoryProtocol, healthRepo: HealthRepositoryProtocol, blogRepo: BlogRepositoryProtocol) {
        self.serverRepo = serverRepo; self.githubRepo = githubRepo; self.healthRepo = healthRepo; self.blogRepo = blogRepo
    }

    /// 并发拉取各维度数据，计算综合战力
    func execute(username: String) async throws -> PowerStats {
        async let g = githubRepo.fetchProfile(username: username)
        async let f = healthRepo.fetchTodayRecord()
        async let b = blogRepo.fetchPosts()
        async let u = fetchUptime()
        let github = try await g; let fitness = try await f; let blogs = try await b; let uptime = try await u
        return PowerStats(
            attack: min(100, Double(github.todayCommits * 10 + github.weekCommits * 2)),
            defense: min(100, uptime),
            health: min(100, Double(fitness.steps) / 100.0 + Double(fitness.exerciseMinutes) * 2.0),
            intelligence: min(100, Double(blogs.count * 5 + blogs.filter(\.isRecent).count * 10)),
            agility: github.events.filter({ $0.type == .issues }).isEmpty ? 40 : 80,
            reputation: min(100, Double(github.totalStars * 5 + github.followers * 3))
        )
    }

    /// 获取服务器在线率作为防御值
    private func fetchUptime() async throws -> Double {
        let configs = serverRepo.getConfigs()
        guard let first = configs.first else { return 0 }
        if let h = serverRepo.getHistory(for: first.id) { return h.uptimePercentage }
        let s = try await serverRepo.ping(config: first)
        return s.isOnline ? 100 : 0
    }
}
