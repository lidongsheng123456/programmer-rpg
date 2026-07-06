import SwiftUI

/// \u4f9d\u8d56\u6ce8\u5165\u5bb9\u5668\uff0c\u7c7b\u6bd4 Spring Boot \u7684 ApplicationContext
/// \u7edf\u4e00\u7ba1\u7406\u6240\u6709 Bean\uff08\u57fa\u7840\u8bbe\u65bd\u3001\u6570\u636e\u6e90\u3001\u4ed3\u5e93\u3001\u670d\u52a1\u3001ViewModel\uff09
@MainActor
final class DIContainer: ObservableObject {

    // MARK: - \u57fa\u7840\u8bbe\u65bd\u5c42
    private(set) lazy var networkClient: NetworkClientProtocol = URLSessionNetworkClient()
    private(set) lazy var persistence: PersistenceProtocol = UserDefaultsPersistence()

    // MARK: - \u6570\u636e\u6e90\u5c42
    private(set) lazy var serverRemoteDS = ServerRemoteDataSource(network: networkClient)
    private(set) lazy var githubRemoteDS = GitHubRemoteDataSource(network: networkClient)
    private(set) lazy var blogRemoteDS = BlogRemoteDataSource(network: networkClient)
    private(set) lazy var localDS = UserDefaultsDataSource(persistence: persistence)

    // MARK: - \u4ed3\u5e93\u5c42\uff08\u7c7b\u6bd4 @Repository\uff09
    private(set) lazy var serverRepo: ServerRepositoryProtocol = ServerRepositoryImpl(remote: serverRemoteDS, local: localDS)
    private(set) lazy var githubRepo: GitHubRepositoryProtocol = GitHubRepositoryImpl(remote: githubRemoteDS, local: localDS)
    private(set) lazy var healthRepo: HealthRepositoryProtocol = HealthRepositoryImpl()
    private(set) lazy var blogRepo: BlogRepositoryProtocol = BlogRepositoryImpl(remote: blogRemoteDS, local: localDS)
    private(set) lazy var achievementRepo: AchievementRepositoryProtocol = AchievementRepositoryImpl(local: localDS)

    // MARK: - \u670d\u52a1\u5c42\uff08\u7c7b\u6bd4 @Service\uff09
    private(set) lazy var calculatePowerUseCase = CalculatePowerUseCase(serverRepo: serverRepo, githubRepo: githubRepo, healthRepo: healthRepo, blogRepo: blogRepo)
    private(set) lazy var checkServerHealthUseCase = CheckServerHealthUseCase(serverRepo: serverRepo)
    private(set) lazy var fetchGitHubDataUseCase = FetchGitHubDataUseCase(githubRepo: githubRepo)
    private(set) lazy var fetchFitnessDataUseCase = FetchFitnessDataUseCase(healthRepo: healthRepo)
    private(set) lazy var evaluateAchievementUseCase = EvaluateAchievementUseCase(achievementRepo: achievementRepo, calculatePower: calculatePowerUseCase)

    // MARK: - ViewModel \u5de5\u5382\u65b9\u6cd5
    func makeDashboardViewModel() -> DashboardViewModel { DashboardViewModel(calculatePower: calculatePowerUseCase, evaluateAchievement: evaluateAchievementUseCase) }
    func makeGuardianViewModel() -> GuardianViewModel { GuardianViewModel(checkServerHealth: checkServerHealthUseCase) }
    func makeGitHubBattleViewModel() -> GitHubBattleViewModel { GitHubBattleViewModel(fetchGitHubData: fetchGitHubDataUseCase) }
    func makeFitnessDungeonViewModel() -> FitnessDungeonViewModel { FitnessDungeonViewModel(fetchFitnessData: fetchFitnessDataUseCase) }
    func makeAchievementsViewModel() -> AchievementsViewModel { AchievementsViewModel(evaluateAchievement: evaluateAchievementUseCase) }
}
