import Foundation

final class CalculatePowerUseCase: @unchecked Sendable {
    private let serverRepo: ServerRepositoryProtocol
    private let githubRepo: GitHubRepositoryProtocol
    private let healthRepo: HealthRepositoryProtocol
    private let blogRepo: BlogRepositoryProtocol

    init(
        serverRepo: ServerRepositoryProtocol,
        githubRepo: GitHubRepositoryProtocol,
        healthRepo: HealthRepositoryProtocol,
        blogRepo: BlogRepositoryProtocol
    ) {
        self.serverRepo = serverRepo
        self.githubRepo = githubRepo
        self.healthRepo = healthRepo
        self.blogRepo = blogRepo
    }

    func execute(username: String) async throws -> PowerStats {
        async let githubTask = githubRepo.fetchProfile(username: username)
        async let fitnessTask = healthRepo.fetchTodayRecord()
        async let blogTask = blogRepo.fetchPosts()
        async let serverTask = fetchUptimePercentage()

        let github = try await githubTask
        let fitness = try await fitnessTask
        let blogs = try await blogTask
        let uptimePercent = try await serverTask

        let attack = calculateAttack(github: github)
        let defense = calculateDefense(uptimePercent: uptimePercent)
        let health = calculateHealth(fitness: fitness)
        let intelligence = calculateIntelligence(posts: blogs)
        let agility = calculateAgility(github: github)
        let reputation = calculateReputation(github: github)

        return PowerStats(
            attack: attack,
            defense: defense,
            health: health,
            intelligence: intelligence,
            agility: agility,
            reputation: reputation
        )
    }

    // attack = min(100, todayCommits * 10 + weekCommits * 2)
    private func calculateAttack(github: GitHubProfile) -> Double {
        min(100, Double(github.todayCommits * 10 + github.weekCommits * 2))
    }

    // defense = uptimePercent (7-day server uptime, max 100)
    private func calculateDefense(uptimePercent: Double) -> Double {
        min(100, uptimePercent)
    }

    // health = min(100, todaySteps / 100 + workoutMinutes * 2)
    private func calculateHealth(fitness: FitnessRecord) -> Double {
        min(100, Double(fitness.steps) / 100.0 + Double(fitness.exerciseMinutes) * 2.0)
    }

    // intelligence = min(100, totalBlogPosts * 5 + recentPostBonus)
    private func calculateIntelligence(posts: [BlogPost]) -> Double {
        let total = posts.count
        let recentBonus = posts.filter(\.isRecent).count * 10
        return min(100, Double(total * 5 + recentBonus))
    }

    // agility based on issue close speed (simplified)
    private func calculateAgility(github: GitHubProfile) -> Double {
        let issueEvents = github.events.filter { $0.type == .issues }
        return issueEvents.isEmpty ? 40 : 80
    }

    // reputation = min(100, totalStars * 5 + followers * 3)
    private func calculateReputation(github: GitHubProfile) -> Double {
        min(100, Double(github.totalStars * 5 + github.followers * 3))
    }

    private func fetchUptimePercentage() async throws -> Double {
        let configs = serverRepo.getConfigs()
        guard let firstConfig = configs.first else { return 0 }
        if let history = serverRepo.getHistory(for: firstConfig.id) {
            return history.uptimePercentage
        }
        let status = try await serverRepo.ping(config: firstConfig)
        return status.isOnline ? 100 : 0
    }
}
