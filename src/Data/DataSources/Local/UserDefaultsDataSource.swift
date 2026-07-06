import Foundation

final class UserDefaultsDataSource: @unchecked Sendable {
    private let persistence: PersistenceProtocol

    init(persistence: PersistenceProtocol) {
        self.persistence = persistence
    }

    // MARK: - GitHub Username

    func getGitHubUsername() -> String {
        persistence.getString(forKey: AppConfig.StorageKey.githubUsername)
            ?? AppConfig.defaultGitHubUsername
    }

    func setGitHubUsername(_ username: String) {
        persistence.setString(username, forKey: AppConfig.StorageKey.githubUsername)
    }

    // MARK: - Server Configs

    func getServerConfigs() -> [ServerConfig] {
        (try? persistence.load(forKey: AppConfig.StorageKey.serverConfigs))
            ?? [ServerConfig.default]
    }

    func saveServerConfigs(_ configs: [ServerConfig]) {
        try? persistence.save(configs, forKey: AppConfig.StorageKey.serverConfigs)
    }

    // MARK: - Ping History

    func getPingHistory(for configId: UUID) -> ServerPingHistory? {
        let key = "\(AppConfig.StorageKey.serverHistory)_\(configId.uuidString)"
        return try? persistence.load(forKey: key)
    }

    func savePingHistory(_ history: ServerPingHistory) {
        let key = "\(AppConfig.StorageKey.serverHistory)_\(history.configId.uuidString)"
        try? persistence.save(history, forKey: key)
    }

    // MARK: - Achievement Records

    func getAchievementRecords() -> [AchievementRecord] {
        (try? persistence.load(forKey: AppConfig.StorageKey.achievementRecords)) ?? []
    }

    func saveAchievementRecords(_ records: [AchievementRecord]) {
        try? persistence.save(records, forKey: AppConfig.StorageKey.achievementRecords)
    }

    // MARK: - Cached Power Stats

    func getCachedPowerStats() -> PowerStats? {
        try? persistence.load(forKey: AppConfig.StorageKey.cachedPowerStats)
    }

    func cachePowerStats(_ stats: PowerStats) {
        try? persistence.save(stats, forKey: AppConfig.StorageKey.cachedPowerStats)
    }

    // MARK: - Blog Cache

    func getCachedBlogPosts() -> [BlogPost] {
        (try? persistence.load(forKey: "cached_blog_posts")) ?? []
    }

    func cacheBlogPosts(_ posts: [BlogPost]) {
        try? persistence.save(posts, forKey: "cached_blog_posts")
    }
}
