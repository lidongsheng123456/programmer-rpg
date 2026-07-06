$ErrorActionPreference = 'Stop'
$root = "D:\idea_project\my_project\programmer-rpg\DevQuest"

function WriteFile($rel, $content) {
    $path = Join-Path $root $rel
    $dir = Split-Path $path -Parent
    if (!(Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    [System.IO.File]::WriteAllText($path, $content, [System.Text.Encoding]::UTF8)
    Write-Host "  [OK] $rel"
}

Write-Host "=== Generating DevQuest Project ===" -ForegroundColor Cyan

# ==================== App ====================

WriteFile "App\DevQuestApp.swift" @'
import SwiftUI
import BackgroundTasks

@main
struct DevQuestApp: App {
    @StateObject private var container = DIContainer()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(container)
        }
    }

    init() {
        registerBackgroundTasks()
    }

    private func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: AppConfig.backgroundTaskIdentifier,
            using: nil
        ) { task in
            guard let refreshTask = task as? BGAppRefreshTask else { return }
            self.handleBackgroundRefresh(refreshTask)
        }
    }

    private func handleBackgroundRefresh(_ task: BGAppRefreshTask) {
        scheduleNextBackgroundRefresh()
        let operation = Task {
            try? await container.checkServerHealthUseCase.execute()
        }
        task.expirationHandler = { operation.cancel() }
        Task {
            await operation.value
            task.setTaskCompleted(success: true)
        }
    }

    private func scheduleNextBackgroundRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: AppConfig.backgroundTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
        try? BGTaskScheduler.shared.submit(request)
    }
}
'@

WriteFile "App\ContentView.swift" @'
import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var container: DIContainer
    @State private var selectedTab: AppTab = .dashboard

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(AppTab.allCases) { tab in
                tab.makeView(container: container)
                    .tabItem { Label(tab.title, systemImage: tab.icon) }
                    .tag(tab)
            }
        }
        .tint(AppColors.primary)
    }
}

enum AppTab: String, CaseIterable, Identifiable {
    case dashboard, guardian, github, fitness, achievements
    var id: String { rawValue }

    var title: String {
        switch self {
        case .dashboard:    return "战力"
        case .guardian:     return "守护兽"
        case .github:      return "战报"
        case .fitness:     return "副本"
        case .achievements: return "成就"
        }
    }

    var icon: String {
        switch self {
        case .dashboard:    return "shield.fill"
        case .guardian:     return "hare.fill"
        case .github:      return "flame.fill"
        case .fitness:     return "figure.run"
        case .achievements: return "trophy.fill"
        }
    }

    @ViewBuilder
    func makeView(container: DIContainer) -> some View {
        switch self {
        case .dashboard:    DashboardView(viewModel: container.makeDashboardViewModel())
        case .guardian:     GuardianListView(viewModel: container.makeGuardianViewModel())
        case .github:       GitHubBattleView(viewModel: container.makeGitHubBattleViewModel())
        case .fitness:      FitnessDungeonView(viewModel: container.makeFitnessDungeonViewModel())
        case .achievements: AchievementsView(viewModel: container.makeAchievementsViewModel())
        }
    }
}
'@

WriteFile "App\DI\DIContainer.swift" @'
import SwiftUI

@MainActor
final class DIContainer: ObservableObject {
    // Infrastructure
    private(set) lazy var networkClient: NetworkClientProtocol = URLSessionNetworkClient()
    private(set) lazy var persistence: PersistenceProtocol = UserDefaultsPersistence()

    // DataSources
    private(set) lazy var serverRemoteDS = ServerRemoteDataSource(network: networkClient)
    private(set) lazy var githubRemoteDS = GitHubRemoteDataSource(network: networkClient)
    private(set) lazy var blogRemoteDS = BlogRemoteDataSource(network: networkClient)
    private(set) lazy var localDS = UserDefaultsDataSource(persistence: persistence)

    // Repositories
    private(set) lazy var serverRepo: ServerRepositoryProtocol = ServerRepositoryImpl(remote: serverRemoteDS, local: localDS)
    private(set) lazy var githubRepo: GitHubRepositoryProtocol = GitHubRepositoryImpl(remote: githubRemoteDS, local: localDS)
    private(set) lazy var healthRepo: HealthRepositoryProtocol = HealthRepositoryImpl()
    private(set) lazy var blogRepo: BlogRepositoryProtocol = BlogRepositoryImpl(remote: blogRemoteDS, local: localDS)
    private(set) lazy var achievementRepo: AchievementRepositoryProtocol = AchievementRepositoryImpl(local: localDS)

    // UseCases
    private(set) lazy var calculatePowerUseCase = CalculatePowerUseCase(serverRepo: serverRepo, githubRepo: githubRepo, healthRepo: healthRepo, blogRepo: blogRepo)
    private(set) lazy var checkServerHealthUseCase = CheckServerHealthUseCase(serverRepo: serverRepo)
    private(set) lazy var fetchGitHubDataUseCase = FetchGitHubDataUseCase(githubRepo: githubRepo)
    private(set) lazy var fetchFitnessDataUseCase = FetchFitnessDataUseCase(healthRepo: healthRepo)
    private(set) lazy var evaluateAchievementUseCase = EvaluateAchievementUseCase(achievementRepo: achievementRepo, calculatePower: calculatePowerUseCase)

    // ViewModel Factories
    func makeDashboardViewModel() -> DashboardViewModel { DashboardViewModel(calculatePower: calculatePowerUseCase, evaluateAchievement: evaluateAchievementUseCase) }
    func makeGuardianViewModel() -> GuardianViewModel { GuardianViewModel(checkServerHealth: checkServerHealthUseCase) }
    func makeGitHubBattleViewModel() -> GitHubBattleViewModel { GitHubBattleViewModel(fetchGitHubData: fetchGitHubDataUseCase) }
    func makeFitnessDungeonViewModel() -> FitnessDungeonViewModel { FitnessDungeonViewModel(fetchFitnessData: fetchFitnessDataUseCase) }
    func makeAchievementsViewModel() -> AchievementsViewModel { AchievementsViewModel(evaluateAchievement: evaluateAchievementUseCase) }
}
'@

Write-Host "`n=== App layer done ===" -ForegroundColor Green

# ==================== Core ====================

WriteFile "Core\Network\NetworkClientProtocol.swift" @'
import Foundation

protocol NetworkClientProtocol: Sendable {
    func get<T: Decodable>(url: URL, headers: [String: String]) async throws -> T
    func head(url: URL) async throws -> HTTPPingResult
}

struct HTTPPingResult: Sendable {
    let statusCode: Int
    let responseTimeMs: Int
    let isHealthy: Bool
}
'@

WriteFile "Core\Network\NetworkError.swift" @'
import Foundation

enum NetworkError: LocalizedError {
    case invalidURL(String)
    case httpError(statusCode: Int)
    case decodingFailed(Error)
    case timeout
    case noConnection
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL(let url):       return "Invalid URL: \(url)"
        case .httpError(let code):       return "HTTP error: \(code)"
        case .decodingFailed(let error): return "Decode failed: \(error.localizedDescription)"
        case .timeout:                   return "Request timeout"
        case .noConnection:              return "No connection"
        case .unknown(let error):        return "Unknown: \(error.localizedDescription)"
        }
    }
}
'@

WriteFile "Core\Network\URLSessionNetworkClient.swift" @'
import Foundation

final class URLSessionNetworkClient: NetworkClientProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    func get<T: Decodable>(url: URL, headers: [String: String] = [:]) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = AppConfig.networkTimeoutSeconds
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else { throw NetworkError.unknown(URLError(.badServerResponse)) }
            guard (200...299).contains(http.statusCode) else { throw NetworkError.httpError(statusCode: http.statusCode) }
            do { return try decoder.decode(T.self, from: data) } catch { throw NetworkError.decodingFailed(error) }
        } catch let e as NetworkError { throw e }
        catch let e as URLError where e.code == .timedOut { throw NetworkError.timeout }
        catch let e as URLError where e.code == .notConnectedToInternet { throw NetworkError.noConnection }
        catch { throw NetworkError.unknown(error) }
    }

    func head(url: URL) async throws -> HTTPPingResult {
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        request.timeoutInterval = AppConfig.pingTimeoutSeconds
        let start = CFAbsoluteTimeGetCurrent()
        do {
            let (_, response) = try await session.data(for: request)
            let elapsed = Int((CFAbsoluteTimeGetCurrent() - start) * 1000)
            let code = (response as? HTTPURLResponse)?.statusCode ?? 0
            return HTTPPingResult(statusCode: code, responseTimeMs: elapsed, isHealthy: (200...399).contains(code))
        } catch {
            let elapsed = Int((CFAbsoluteTimeGetCurrent() - start) * 1000)
            return HTTPPingResult(statusCode: 0, responseTimeMs: elapsed, isHealthy: false)
        }
    }
}
'@

WriteFile "Core\Persistence\PersistenceProtocol.swift" @'
import Foundation

protocol PersistenceProtocol: Sendable {
    func save<T: Encodable>(_ value: T, forKey key: String) throws
    func load<T: Decodable>(forKey key: String) throws -> T?
    func remove(forKey key: String)
    func getString(forKey key: String) -> String?
    func setString(_ value: String, forKey key: String)
}
'@

WriteFile "Core\Persistence\UserDefaultsPersistence.swift" @'
import Foundation

final class UserDefaultsPersistence: PersistenceProtocol {
    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(suiteName: String? = AppConfig.appGroupIdentifier) {
        self.defaults = UserDefaults(suiteName: suiteName) ?? .standard
    }

    func save<T: Encodable>(_ value: T, forKey key: String) throws {
        defaults.set(try encoder.encode(value), forKey: key)
    }
    func load<T: Decodable>(forKey key: String) throws -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try decoder.decode(T.self, from: data)
    }
    func remove(forKey key: String) { defaults.removeObject(forKey: key) }
    func getString(forKey key: String) -> String? { defaults.string(forKey: key) }
    func setString(_ value: String, forKey key: String) { defaults.set(value, forKey: key) }
}
'@

WriteFile "Core\Config\AppConfig.swift" @'
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
'@

WriteFile "Core\Extensions\Date+Extensions.swift" @'
import Foundation

extension Date {
    var startOfDay: Date { Calendar.current.startOfDay(for: self) }
    var startOfWeek: Date {
        let c = Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return Calendar.current.date(from: c) ?? self
    }
    var daysAgo7: Date { Calendar.current.date(byAdding: .day, value: -7, to: self) ?? self }
    var isToday: Bool { Calendar.current.isDateInToday(self) }
    var relativeString: String {
        let f = RelativeDateTimeFormatter(); f.locale = Locale(identifier: "zh_CN"); f.unitsStyle = .short
        return f.localizedString(for: self, relativeTo: .now)
    }
    var shortDateString: String {
        let f = DateFormatter(); f.dateFormat = "MM/dd"; return f.string(from: self)
    }
}
'@

Write-Host "=== Core layer done ===" -ForegroundColor Green

Write-Host "`n=== All base layers generated. Run generate_project_2.ps1 for remaining layers ===" -ForegroundColor Cyan
