import Foundation
final class UserDefaultsDataSource: @unchecked Sendable {
    private let persistence: PersistenceProtocol
    init(persistence: PersistenceProtocol) { self.persistence = persistence }

    func getGitHubUsername() -> String { persistence.getString(forKey: AppConfig.StorageKey.githubUsername) ?? AppConfig.defaultGitHubUsername }
    func setGitHubUsername(_ u: String) { persistence.setString(u, forKey: AppConfig.StorageKey.githubUsername) }
    func getServerConfigs() -> [ServerConfig] { (try? persistence.load(forKey: AppConfig.StorageKey.serverConfigs)) ?? [ServerConfig.default] }
    func saveServerConfigs(_ c: [ServerConfig]) { try? persistence.save(c, forKey: AppConfig.StorageKey.serverConfigs) }
    func getPingHistory(for id: UUID) -> ServerPingHistory? { try? persistence.load(forKey: "\(AppConfig.StorageKey.serverHistory)_\(id.uuidString)") }
    func savePingHistory(_ h: ServerPingHistory) { try? persistence.save(h, forKey: "\(AppConfig.StorageKey.serverHistory)_\(h.configId.uuidString)") }
    func getAchievementRecords() -> [AchievementRecord] { (try? persistence.load(forKey: AppConfig.StorageKey.achievementRecords)) ?? [] }
    func saveAchievementRecords(_ r: [AchievementRecord]) { try? persistence.save(r, forKey: AppConfig.StorageKey.achievementRecords) }
    func getCachedPowerStats() -> PowerStats? { try? persistence.load(forKey: AppConfig.StorageKey.cachedPowerStats) }
    func cachePowerStats(_ s: PowerStats) { try? persistence.save(s, forKey: AppConfig.StorageKey.cachedPowerStats) }
    func getCachedBlogPosts() -> [BlogPost] { (try? persistence.load(forKey: "cached_blog_posts")) ?? [] }
    func cacheBlogPosts(_ p: [BlogPost]) { try? persistence.save(p, forKey: "cached_blog_posts") }
}