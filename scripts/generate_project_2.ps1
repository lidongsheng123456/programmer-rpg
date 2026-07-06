$ErrorActionPreference = 'Stop'
$root = "D:\idea_project\my_project\programmer-rpg\DevQuest"

function WriteFile($rel, $content) {
    $path = Join-Path $root $rel
    $dir = Split-Path $path -Parent
    if (!(Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    [System.IO.File]::WriteAllText($path, $content, [System.Text.Encoding]::UTF8)
    Write-Host "  [OK] $rel"
}

Write-Host "=== Generating Domain + Data layers ===" -ForegroundColor Cyan

# ==================== Domain/Entities ====================

WriteFile "Domain\Entities\PowerStats.swift" @'
import Foundation

struct PowerStats: Codable, Equatable, Sendable {
    let attack: Double
    let defense: Double
    let health: Double
    let intelligence: Double
    let agility: Double
    let reputation: Double

    var totalPower: Double { (attack + defense + health + intelligence + agility + reputation) / 6.0 }
    var dimensions: [(label: String, value: Double)] {
        [("攻击", attack), ("防御", defense), ("生命", health), ("智力", intelligence), ("敏捷", agility), ("声望", reputation)]
    }
    var level: CharacterLevel { CharacterLevel.from(power: totalPower) }
    static let zero = PowerStats(attack: 0, defense: 0, health: 0, intelligence: 0, agility: 0, reputation: 0)
}

enum CharacterLevel: String, Codable, Sendable {
    case bronze = "青铜码农", silver = "白银工程师", gold = "黄金架构师"
    case platinum = "铂金技术专家", diamond = "钻石全栈大师", master = "传说码神"
    var minPower: Double {
        switch self { case .bronze: return 0; case .silver: return 20; case .gold: return 40; case .platinum: return 60; case .diamond: return 80; case .master: return 95 }
    }
    static func from(power: Double) -> CharacterLevel {
        switch power { case 95...: return .master; case 80..<95: return .diamond; case 60..<80: return .platinum; case 40..<60: return .gold; case 20..<40: return .silver; default: return .bronze }
    }
}
'@

WriteFile "Domain\Entities\ServerStatus.swift" @'
import Foundation

struct ServerConfig: Codable, Identifiable, Sendable {
    let id: UUID; var name: String; var url: String; var guardianEmoji: String
    init(id: UUID = UUID(), name: String, url: String, guardianEmoji: String = "🐉") {
        self.id = id; self.name = name; self.url = url; self.guardianEmoji = guardianEmoji
    }
    static let `default` = ServerConfig(name: "主服务器", url: "http://47.104.236.251", guardianEmoji: "🐉")
}

struct ServerStatus: Codable, Identifiable, Sendable {
    let id: UUID; let config: ServerConfig; let isOnline: Bool; let statusCode: Int; let responseTimeMs: Int; let checkedAt: Date
    var uptimeDisplay: String { isOnline ? "\(responseTimeMs)ms" : "离线" }
}

struct ServerPingHistory: Codable, Sendable {
    let configId: UUID; var records: [PingRecord]
    struct PingRecord: Codable, Sendable { let timestamp: Date; let responseTimeMs: Int; let isOnline: Bool }
    var uptimePercentage: Double {
        guard !records.isEmpty else { return 0 }
        return Double(records.filter(\.isOnline).count) / Double(records.count) * 100.0
    }
    var recentRecords: [PingRecord] { records.filter { $0.timestamp > Date().daysAgo7 } }
}
'@

WriteFile "Domain\Entities\GitHubProfile.swift" @'
import Foundation

struct GitHubProfile: Codable, Sendable {
    let username: String; let avatarURL: String; let followers: Int; let publicRepos: Int; let totalStars: Int
    var events: [Event]; var repos: [Repo]

    struct Event: Codable, Identifiable, Sendable {
        let id: String; let type: EventType; let repoName: String; let createdAt: Date
        enum EventType: String, Codable, Sendable {
            case push = "PushEvent", pullRequest = "PullRequestEvent", issues = "IssuesEvent"
            case issueComment = "IssueCommentEvent", create = "CreateEvent", watch = "WatchEvent", fork = "ForkEvent", other
            init(from decoder: Decoder) throws { let v = try decoder.singleValueContainer().decode(String.self); self = EventType(rawValue: v) ?? .other }
        }
    }
    struct Repo: Codable, Identifiable, Sendable {
        let id: Int; let name: String; let fullName: String; let description: String?; let language: String?
        let stargazersCount: Int; let forksCount: Int; let updatedAt: Date
    }
    var todayCommits: Int { events.filter { $0.type == .push && $0.createdAt.isToday }.count }
    var weekCommits: Int { let w = Date().daysAgo7; return events.filter { $0.type == .push && $0.createdAt > w }.count }
}
'@

WriteFile "Domain\Entities\FitnessRecord.swift" @'
import Foundation

struct FitnessRecord: Codable, Sendable {
    let date: Date; let steps: Int; let activeCalories: Double; let exerciseMinutes: Int
    var stepsDisplay: String { let f = NumberFormatter(); f.numberStyle = .decimal; return f.string(from: NSNumber(value: steps)) ?? "\(steps)" }
    var caloriesDisplay: String { String(format: "%.0f kcal", activeCalories) }
    var exerciseDisplay: String { "\(exerciseMinutes) 分钟" }
    static let empty = FitnessRecord(date: Date(), steps: 0, activeCalories: 0, exerciseMinutes: 0)
}
'@

WriteFile "Domain\Entities\Achievement.swift" @'
import Foundation

struct Achievement: Codable, Identifiable, Sendable {
    let id: String; let title: String; let description: String; let icon: String
    let category: Category; let condition: Condition

    enum Category: String, Codable, CaseIterable, Sendable {
        case combat = "战斗", defense = "防御", fitness = "健身", wisdom = "智慧", social = "社交", special = "特殊"
    }
    enum Condition: Codable, Sendable {
        case totalPowerAbove(Double), singleStatAbove(String, Double), commitStreak(Int)
        case serverUptimeAbove(Double), stepsAbove(Int), blogPostsAbove(Int), starsAbove(Int)
    }
    static let allAchievements: [Achievement] = [
        Achievement(id: "first_blood", title: "初次见血", description: "首次提交代码", icon: "drop.fill", category: .combat, condition: .singleStatAbove("attack", 10)),
        Achievement(id: "iron_wall", title: "铜墙铁壁", description: "服务器7天在线率>99%", icon: "shield.checkered", category: .defense, condition: .serverUptimeAbove(99)),
        Achievement(id: "marathon", title: "代码马拉松", description: "连续7天提交代码", icon: "flame.fill", category: .combat, condition: .commitStreak(7)),
        Achievement(id: "walker", title: "行者无疆", description: "单日步数超过10000", icon: "figure.walk", category: .fitness, condition: .stepsAbove(10000)),
        Achievement(id: "blogger", title: "笔耕不辍", description: "发布超过10篇博客", icon: "text.book.closed.fill", category: .wisdom, condition: .blogPostsAbove(10)),
        Achievement(id: "rising_star", title: "冉冉新星", description: "获得50个GitHub Star", icon: "star.fill", category: .social, condition: .starsAbove(50)),
        Achievement(id: "full_power", title: "满级战神", description: "总战力达到90分", icon: "bolt.shield.fill", category: .special, condition: .totalPowerAbove(90)),
        Achievement(id: "balanced", title: "六边形战士", description: "所有维度超过60分", icon: "hexagon.fill", category: .special, condition: .totalPowerAbove(60)),
    ]
}

struct AchievementRecord: Codable, Identifiable, Sendable {
    let id: String; let achievementId: String; let unlockedAt: Date
}
'@

WriteFile "Domain\Entities\BlogPost.swift" @'
import Foundation

struct BlogPost: Codable, Identifiable, Sendable {
    let id: String; let title: String; let url: String; let publishedAt: Date?
    var isRecent: Bool { guard let d = publishedAt else { return false }; return d > Date().daysAgo7 }
    var dateDisplay: String { guard let d = publishedAt else { return "未知" }; return d.shortDateString }
}
'@

# ==================== Domain/Repositories ====================

WriteFile "Domain\Repositories\ServerRepositoryProtocol.swift" @'
import Foundation
protocol ServerRepositoryProtocol: Sendable {
    func ping(config: ServerConfig) async throws -> ServerStatus
    func pingAll() async throws -> [ServerStatus]
    func getConfigs() -> [ServerConfig]
    func saveConfig(_ config: ServerConfig)
    func removeConfig(id: UUID)
    func getHistory(for configId: UUID) -> ServerPingHistory?
    func saveHistory(_ history: ServerPingHistory)
}
'@

WriteFile "Domain\Repositories\GitHubRepositoryProtocol.swift" @'
import Foundation
protocol GitHubRepositoryProtocol: Sendable {
    func fetchProfile(username: String) async throws -> GitHubProfile
    func fetchEvents(username: String) async throws -> [GitHubProfile.Event]
    func fetchRepos(username: String) async throws -> [GitHubProfile.Repo]
}
'@

WriteFile "Domain\Repositories\HealthRepositoryProtocol.swift" @'
import Foundation
protocol HealthRepositoryProtocol: Sendable {
    func requestAuthorization() async throws
    func fetchTodayRecord() async throws -> FitnessRecord
    func fetchWeekRecords() async throws -> [FitnessRecord]
}
'@

WriteFile "Domain\Repositories\BlogRepositoryProtocol.swift" @'
import Foundation
protocol BlogRepositoryProtocol: Sendable {
    func fetchPosts() async throws -> [BlogPost]
    func getCachedPosts() -> [BlogPost]
}
'@

WriteFile "Domain\Repositories\AchievementRepositoryProtocol.swift" @'
import Foundation
protocol AchievementRepositoryProtocol: Sendable {
    func getUnlockedRecords() -> [AchievementRecord]
    func unlock(achievementId: String) throws
    func isUnlocked(achievementId: String) -> Bool
}
'@

# ==================== Domain/UseCases ====================

WriteFile "Domain\UseCases\CalculatePowerUseCase.swift" @'
import Foundation

final class CalculatePowerUseCase: @unchecked Sendable {
    private let serverRepo: ServerRepositoryProtocol
    private let githubRepo: GitHubRepositoryProtocol
    private let healthRepo: HealthRepositoryProtocol
    private let blogRepo: BlogRepositoryProtocol

    init(serverRepo: ServerRepositoryProtocol, githubRepo: GitHubRepositoryProtocol, healthRepo: HealthRepositoryProtocol, blogRepo: BlogRepositoryProtocol) {
        self.serverRepo = serverRepo; self.githubRepo = githubRepo; self.healthRepo = healthRepo; self.blogRepo = blogRepo
    }

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

    private func fetchUptime() async throws -> Double {
        let configs = serverRepo.getConfigs()
        guard let first = configs.first else { return 0 }
        if let h = serverRepo.getHistory(for: first.id) { return h.uptimePercentage }
        let s = try await serverRepo.ping(config: first)
        return s.isOnline ? 100 : 0
    }
}
'@

WriteFile "Domain\UseCases\CheckServerHealthUseCase.swift" @'
import Foundation

final class CheckServerHealthUseCase: @unchecked Sendable {
    private let serverRepo: ServerRepositoryProtocol
    init(serverRepo: ServerRepositoryProtocol) { self.serverRepo = serverRepo }

    func execute() async throws -> [ServerStatus] {
        let statuses = try await serverRepo.pingAll()
        for status in statuses {
            var history = serverRepo.getHistory(for: status.config.id) ?? ServerPingHistory(configId: status.config.id, records: [])
            history.records.append(ServerPingHistory.PingRecord(timestamp: status.checkedAt, responseTimeMs: status.responseTimeMs, isOnline: status.isOnline))
            history.records = history.records.filter { $0.timestamp > Date().daysAgo7 }
            serverRepo.saveHistory(history)
        }
        return statuses
    }

    func executeForConfig(_ config: ServerConfig) async throws -> ServerStatus {
        try await serverRepo.ping(config: config)
    }

    func getHistory(for configId: UUID) -> ServerPingHistory? {
        serverRepo.getHistory(for: configId)
    }
}
'@

WriteFile "Domain\UseCases\FetchGitHubDataUseCase.swift" @'
import Foundation

final class FetchGitHubDataUseCase: @unchecked Sendable {
    private let githubRepo: GitHubRepositoryProtocol
    init(githubRepo: GitHubRepositoryProtocol) { self.githubRepo = githubRepo }

    func execute(username: String) async throws -> GitHubProfile { try await githubRepo.fetchProfile(username: username) }

    func fetchContributions(username: String) async throws -> ContributionSummary {
        let events = try await githubRepo.fetchEvents(username: username)
        var daily: [String: Int] = [:]
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
        for e in events.filter({ $0.type == .push }) { daily[f.string(from: e.createdAt), default: 0] += 1 }
        return ContributionSummary(dailyCounts: daily)
    }
}

struct ContributionSummary: Sendable {
    let dailyCounts: [String: Int]
    var maxCount: Int { dailyCounts.values.max() ?? 0 }
    func count(for dateString: String) -> Int { dailyCounts[dateString] ?? 0 }
}
'@

WriteFile "Domain\UseCases\FetchFitnessDataUseCase.swift" @'
import Foundation

final class FetchFitnessDataUseCase: @unchecked Sendable {
    private let healthRepo: HealthRepositoryProtocol
    init(healthRepo: HealthRepositoryProtocol) { self.healthRepo = healthRepo }

    func requestPermission() async throws { try await healthRepo.requestAuthorization() }
    func fetchToday() async throws -> FitnessRecord { try await healthRepo.fetchTodayRecord() }
    func fetchWeekly() async throws -> [FitnessRecord] { try await healthRepo.fetchWeekRecords() }

    func calculateDungeonProgress(record: FitnessRecord) -> DungeonProgress {
        DungeonProgress(
            stepsProgress: min(1.0, Double(record.steps) / 10000.0),
            caloriesProgress: min(1.0, record.activeCalories / 500.0),
            exerciseProgress: min(1.0, Double(record.exerciseMinutes) / 30.0),
            overallProgress: min(1.0, (Double(record.steps) / 10000.0 + record.activeCalories / 500.0 + Double(record.exerciseMinutes) / 30.0) / 3.0)
        )
    }
}

struct DungeonProgress: Sendable {
    let stepsProgress: Double; let caloriesProgress: Double; let exerciseProgress: Double; let overallProgress: Double
    var isCompleted: Bool { overallProgress >= 1.0 }
}
'@

WriteFile "Domain\UseCases\EvaluateAchievementUseCase.swift" @'
import Foundation

final class EvaluateAchievementUseCase: @unchecked Sendable {
    private let achievementRepo: AchievementRepositoryProtocol
    private let calculatePower: CalculatePowerUseCase
    init(achievementRepo: AchievementRepositoryProtocol, calculatePower: CalculatePowerUseCase) {
        self.achievementRepo = achievementRepo; self.calculatePower = calculatePower
    }

    func evaluate(username: String) async throws -> [AchievementStatus] {
        let stats = try await calculatePower.execute(username: username)
        return Achievement.allAchievements.map { a in
            let unlocked = achievementRepo.isUnlocked(achievementId: a.id)
            let meets = checkCondition(a.condition, stats: stats)
            if meets && !unlocked { try? achievementRepo.unlock(achievementId: a.id) }
            return AchievementStatus(achievement: a, isUnlocked: unlocked || meets, progress: calcProgress(a.condition, stats: stats))
        }
    }
    func getUnlockedCount() -> Int { achievementRepo.getUnlockedRecords().count }

    private func checkCondition(_ c: Achievement.Condition, stats: PowerStats) -> Bool {
        switch c {
        case .totalPowerAbove(let t): return stats.totalPower >= t
        case .singleStatAbove(let s, let t): return statVal(s, stats) >= t
        case .serverUptimeAbove(let t): return stats.defense >= t
        case .stepsAbove(let t): return stats.health >= Double(t) / 100.0
        default: return false
        }
    }
    private func calcProgress(_ c: Achievement.Condition, stats: PowerStats) -> Double {
        switch c {
        case .totalPowerAbove(let t): return min(1, stats.totalPower / t)
        case .singleStatAbove(let s, let t): return min(1, statVal(s, stats) / t)
        case .serverUptimeAbove(let t): return min(1, stats.defense / t)
        default: return 0
        }
    }
    private func statVal(_ n: String, _ s: PowerStats) -> Double {
        switch n { case "attack": return s.attack; case "defense": return s.defense; case "health": return s.health
        case "intelligence": return s.intelligence; case "agility": return s.agility; case "reputation": return s.reputation; default: return 0 }
    }
}

struct AchievementStatus: Identifiable, Sendable {
    let achievement: Achievement; let isUnlocked: Bool; let progress: Double
    var id: String { achievement.id }
}
'@

Write-Host "=== Domain layer done ===" -ForegroundColor Green

# ==================== Data/DTOs ====================

WriteFile "Data\DTOs\GitHubEventDTO.swift" @'
import Foundation
struct GitHubEventDTO: Decodable {
    let id: String; let type: String; let repo: RepoRef; let createdAt: Date
    struct RepoRef: Decodable { let name: String }
    func toDomain() -> GitHubProfile.Event {
        GitHubProfile.Event(id: id, type: GitHubProfile.Event.EventType(rawValue: type) ?? .other, repoName: repo.name, createdAt: createdAt)
    }
}
'@

WriteFile "Data\DTOs\GitHubRepoDTO.swift" @'
import Foundation
struct GitHubRepoDTO: Decodable {
    let id: Int; let name: String; let fullName: String; let description: String?; let language: String?
    let stargazersCount: Int; let forksCount: Int; let updatedAt: Date
    func toDomain() -> GitHubProfile.Repo {
        GitHubProfile.Repo(id: id, name: name, fullName: fullName, description: description, language: language, stargazersCount: stargazersCount, forksCount: forksCount, updatedAt: updatedAt)
    }
}
struct GitHubUserDTO: Decodable {
    let login: String; let avatarUrl: String; let followers: Int; let publicRepos: Int
    func toDomain(stars: Int, events: [GitHubProfile.Event], repos: [GitHubProfile.Repo]) -> GitHubProfile {
        GitHubProfile(username: login, avatarURL: avatarUrl, followers: followers, publicRepos: publicRepos, totalStars: stars, events: events, repos: repos)
    }
}
'@

WriteFile "Data\DTOs\ServerPingResult.swift" @'
import Foundation
struct ServerPingResultDTO: Sendable {
    let statusCode: Int; let responseTimeMs: Int; let isHealthy: Bool; let timestamp: Date
    func toDomain(config: ServerConfig) -> ServerStatus {
        ServerStatus(id: config.id, config: config, isOnline: isHealthy, statusCode: statusCode, responseTimeMs: responseTimeMs, checkedAt: timestamp)
    }
}
'@

# ==================== Data/DataSources ====================

WriteFile "Data\DataSources\Remote\ServerRemoteDataSource.swift" @'
import Foundation
final class ServerRemoteDataSource: @unchecked Sendable {
    private let network: NetworkClientProtocol
    init(network: NetworkClientProtocol) { self.network = network }
    func ping(url: String) async throws -> ServerPingResultDTO {
        guard let u = URL(string: url) else { throw NetworkError.invalidURL(url) }
        let r = try await network.head(url: u)
        return ServerPingResultDTO(statusCode: r.statusCode, responseTimeMs: r.responseTimeMs, isHealthy: r.isHealthy, timestamp: Date())
    }
}
'@

WriteFile "Data\DataSources\Remote\GitHubRemoteDataSource.swift" @'
import Foundation
final class GitHubRemoteDataSource: @unchecked Sendable {
    private let network: NetworkClientProtocol; private let baseURL: String
    init(network: NetworkClientProtocol, baseURL: String = AppConfig.githubAPIBase) { self.network = network; self.baseURL = baseURL }
    private var headers: [String: String] { ["Accept": "application/vnd.github.v3+json", "User-Agent": "DevQuest-iOS"] }

    func fetchUser(username: String) async throws -> GitHubUserDTO {
        guard let url = URL(string: "\(baseURL)/users/\(username)") else { throw NetworkError.invalidURL(username) }
        return try await network.get(url: url, headers: headers)
    }
    func fetchEvents(username: String) async throws -> [GitHubEventDTO] {
        guard let url = URL(string: "\(baseURL)/users/\(username)/events?per_page=100") else { throw NetworkError.invalidURL(username) }
        return try await network.get(url: url, headers: headers)
    }
    func fetchRepos(username: String) async throws -> [GitHubRepoDTO] {
        guard let url = URL(string: "\(baseURL)/users/\(username)/repos?sort=updated&per_page=100") else { throw NetworkError.invalidURL(username) }
        return try await network.get(url: url, headers: headers)
    }
}
'@

WriteFile "Data\DataSources\Remote\BlogRemoteDataSource.swift" @'
import Foundation
final class BlogRemoteDataSource: @unchecked Sendable {
    private let network: NetworkClientProtocol; private let blogURL: String
    init(network: NetworkClientProtocol, blogURL: String = AppConfig.blogURL) { self.network = network; self.blogURL = blogURL }

    func fetchPosts() async throws -> [BlogPost] {
        guard let url = URL(string: blogURL) else { throw NetworkError.invalidURL(blogURL) }
        var req = URLRequest(url: url); req.httpMethod = "GET"; req.timeoutInterval = AppConfig.networkTimeoutSeconds
        let (data, _) = try await URLSession.shared.data(for: req)
        guard let html = String(data: data, encoding: .utf8) else { return [] }
        return parseHTML(html)
    }

    private func parseHTML(_ html: String) -> [BlogPost] {
        var posts: [BlogPost] = []
        let pattern = #"<a[^>]*href=[\"']([^\"']*)[\"'][^>]*>([^<]+)</a>"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let range = NSRange(html.startIndex..., in: html)
        for (i, m) in regex.matches(in: html, range: range).enumerated() where i < 50 {
            guard let ur = Range(m.range(at: 1), in: html), let tr = Range(m.range(at: 2), in: html) else { continue }
            let href = String(html[ur]); let title = String(html[tr]).trimmingCharacters(in: .whitespacesAndNewlines)
            guard !title.isEmpty, title.count > 2, !href.contains("javascript:"), !href.contains("#") else { continue }
            let full = href.hasPrefix("http") ? href : "\(blogURL)\(href)"
            posts.append(BlogPost(id: "\(i)", title: title, url: full, publishedAt: nil))
        }
        return posts
    }
}
'@

WriteFile "Data\DataSources\Local\UserDefaultsDataSource.swift" @'
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
'@

# ==================== Data/Repositories ====================

WriteFile "Data\Repositories\ServerRepositoryImpl.swift" @'
import Foundation
final class ServerRepositoryImpl: ServerRepositoryProtocol, @unchecked Sendable {
    private let remote: ServerRemoteDataSource; private let local: UserDefaultsDataSource
    init(remote: ServerRemoteDataSource, local: UserDefaultsDataSource) { self.remote = remote; self.local = local }

    func ping(config: ServerConfig) async throws -> ServerStatus { (try await remote.ping(url: config.url)).toDomain(config: config) }
    func pingAll() async throws -> [ServerStatus] {
        try await withThrowingTaskGroup(of: ServerStatus.self) { group in
            for c in getConfigs() { group.addTask { try await self.ping(config: c) } }
            var r: [ServerStatus] = []; for try await s in group { r.append(s) }; return r
        }
    }
    func getConfigs() -> [ServerConfig] { local.getServerConfigs() }
    func saveConfig(_ config: ServerConfig) {
        var cs = local.getServerConfigs()
        if let i = cs.firstIndex(where: { $0.id == config.id }) { cs[i] = config } else { cs.append(config) }
        local.saveServerConfigs(cs)
    }
    func removeConfig(id: UUID) { var cs = local.getServerConfigs(); cs.removeAll { $0.id == id }; local.saveServerConfigs(cs) }
    func getHistory(for configId: UUID) -> ServerPingHistory? { local.getPingHistory(for: configId) }
    func saveHistory(_ history: ServerPingHistory) { local.savePingHistory(history) }
}
'@

WriteFile "Data\Repositories\GitHubRepositoryImpl.swift" @'
import Foundation
final class GitHubRepositoryImpl: GitHubRepositoryProtocol, @unchecked Sendable {
    private let remote: GitHubRemoteDataSource; private let local: UserDefaultsDataSource
    init(remote: GitHubRemoteDataSource, local: UserDefaultsDataSource) { self.remote = remote; self.local = local }

    func fetchProfile(username: String) async throws -> GitHubProfile {
        async let u = remote.fetchUser(username: username)
        async let e = remote.fetchEvents(username: username)
        async let r = remote.fetchRepos(username: username)
        let user = try await u; let events = (try await e).map { $0.toDomain() }; let repos = (try await r).map { $0.toDomain() }
        return user.toDomain(stars: repos.reduce(0) { $0 + $1.stargazersCount }, events: events, repos: repos)
    }
    func fetchEvents(username: String) async throws -> [GitHubProfile.Event] { (try await remote.fetchEvents(username: username)).map { $0.toDomain() } }
    func fetchRepos(username: String) async throws -> [GitHubProfile.Repo] { (try await remote.fetchRepos(username: username)).map { $0.toDomain() } }
}
'@

WriteFile "Data\Repositories\HealthRepositoryImpl.swift" @'
import Foundation
import HealthKit

final class HealthRepositoryImpl: HealthRepositoryProtocol, @unchecked Sendable {
    private let store = HKHealthStore()
    private let readTypes: Set<HKObjectType> = {
        var t = Set<HKObjectType>()
        [HKQuantityTypeIdentifier.stepCount, .activeEnergyBurned, .appleExerciseTime].forEach {
            if let qt = HKQuantityType.quantityType(forIdentifier: $0) { t.insert(qt) }
        }
        return t
    }()

    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        try await store.requestAuthorization(toShare: [], read: readTypes)
    }
    func fetchTodayRecord() async throws -> FitnessRecord {
        let start = Date().startOfDay
        async let s = querySum(.stepCount, unit: .count(), start: start, end: Date())
        async let c = querySum(.activeEnergyBurned, unit: .kilocalorie(), start: start, end: Date())
        async let e = querySum(.appleExerciseTime, unit: .minute(), start: start, end: Date())
        return FitnessRecord(date: start, steps: Int(try await s), activeCalories: try await c, exerciseMinutes: Int(try await e))
    }
    func fetchWeekRecords() async throws -> [FitnessRecord] {
        var records: [FitnessRecord] = []
        for d in 0..<7 {
            guard let ds = Calendar.current.date(byAdding: .day, value: -d, to: Date())?.startOfDay,
                  let de = Calendar.current.date(byAdding: .day, value: 1, to: ds) else { continue }
            let s = (try? await querySum(.stepCount, unit: .count(), start: ds, end: de)) ?? 0
            let c = (try? await querySum(.activeEnergyBurned, unit: .kilocalorie(), start: ds, end: de)) ?? 0
            let e = (try? await querySum(.appleExerciseTime, unit: .minute(), start: ds, end: de)) ?? 0
            records.append(FitnessRecord(date: ds, steps: Int(s), activeCalories: c, exerciseMinutes: Int(e)))
        }
        return records.reversed()
    }
    private func querySum(_ id: HKQuantityTypeIdentifier, unit: HKUnit, start: Date, end: Date) async throws -> Double {
        guard let qt = HKQuantityType.quantityType(forIdentifier: id) else { return 0 }
        let pred = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        return try await withCheckedThrowingContinuation { cont in
            store.execute(HKStatisticsQuery(quantityType: qt, quantitySamplePredicate: pred, options: .cumulativeSum) { _, stats, err in
                if let err = err { cont.resume(throwing: err) } else { cont.resume(returning: stats?.sumQuantity()?.doubleValue(for: unit) ?? 0) }
            })
        }
    }
}
'@

WriteFile "Data\Repositories\BlogRepositoryImpl.swift" @'
import Foundation
final class BlogRepositoryImpl: BlogRepositoryProtocol, @unchecked Sendable {
    private let remote: BlogRemoteDataSource; private let local: UserDefaultsDataSource
    init(remote: BlogRemoteDataSource, local: UserDefaultsDataSource) { self.remote = remote; self.local = local }
    func fetchPosts() async throws -> [BlogPost] { let p = try await remote.fetchPosts(); local.cacheBlogPosts(p); return p }
    func getCachedPosts() -> [BlogPost] { local.getCachedBlogPosts() }
}
'@

WriteFile "Data\Repositories\AchievementRepositoryImpl.swift" @'
import Foundation
final class AchievementRepositoryImpl: AchievementRepositoryProtocol, @unchecked Sendable {
    private let local: UserDefaultsDataSource
    init(local: UserDefaultsDataSource) { self.local = local }
    func getUnlockedRecords() -> [AchievementRecord] { local.getAchievementRecords() }
    func unlock(achievementId: String) throws {
        var r = local.getAchievementRecords()
        guard !r.contains(where: { $0.achievementId == achievementId }) else { return }
        r.append(AchievementRecord(id: UUID().uuidString, achievementId: achievementId, unlockedAt: Date()))
        local.saveAchievementRecords(r)
    }
    func isUnlocked(achievementId: String) -> Bool { local.getAchievementRecords().contains { $0.achievementId == achievementId } }
}
'@

Write-Host "`n=== Data layer done ===" -ForegroundColor Green
Write-Host "Run generate_project_3.ps1 for Features + DesignSystem + Widget" -ForegroundColor Cyan
