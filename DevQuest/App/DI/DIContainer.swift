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