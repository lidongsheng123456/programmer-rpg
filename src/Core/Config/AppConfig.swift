import Foundation

enum AppConfig {
    // MARK: - App Identity
    static let appGroupIdentifier = "group.com.devquest.shared"
    static let backgroundTaskIdentifier = "com.devquest.serverRefresh"

    // MARK: - GitHub
    static let defaultGitHubUsername = "lidongsheng123456"
    static let githubAPIBase = "https://api.github.com"

    // MARK: - Server Monitoring
    static let defaultServerURLs: [String] = [
        "http://47.104.236.251"
    ]
    static let serverCheckIntervalSeconds: TimeInterval = 60
    static let pingTimeoutSeconds: TimeInterval = 10

    // MARK: - Blog
    static let blogURL = "https://lds.andysama.work"

    // MARK: - Network
    static let networkTimeoutSeconds: TimeInterval = 30

    // MARK: - Widget
    static let widgetRefreshMinutes: Int = 30

    // MARK: - Persistence Keys
    enum StorageKey {
        static let githubUsername = "github_username"
        static let serverConfigs = "server_configs"
        static let achievementRecords = "achievement_records"
        static let serverHistory = "server_ping_history"
        static let cachedPowerStats = "cached_power_stats"
        static let lastSyncDate = "last_sync_date"
    }
}
