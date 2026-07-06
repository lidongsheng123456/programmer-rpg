import Foundation

enum AppConfig {
    static let appGroupIdentifier = "group.com.devquest.shared"
    static let backgroundTaskIdentifier = "com.devquest.serverRefresh"
    static let defaultGitHubUsername = "lidongsheng123456"
    static let githubAPIBase = "https://api.github.com"
    static let defaultServerURLs = ["http://47.104.236.251"]
    static let serverCheckIntervalSeconds: TimeInterval = 60
    static let pingTimeoutSeconds: TimeInterval = 10
    static let blogURL = "https://lds.andysama.work"
    static let networkTimeoutSeconds: TimeInterval = 30
    static let widgetRefreshMinutes = 30

    enum StorageKey {
        static let githubUsername = "github_username"
        static let serverConfigs = "server_configs"
        static let achievementRecords = "achievement_records"
        static let serverHistory = "server_ping_history"
        static let cachedPowerStats = "cached_power_stats"
        static let lastSyncDate = "last_sync_date"
    }
}