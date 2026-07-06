import Foundation

/// 健康数据获取服务，封装 HealthKit 数据读取和副本进度计算
final class FetchFitnessDataUseCase: @unchecked Sendable {
    private let healthRepo: HealthRepositoryProtocol
    init(healthRepo: HealthRepositoryProtocol) { self.healthRepo = healthRepo }

    func requestPermission() async throws { try await healthRepo.requestAuthorization() }
    func fetchToday() async throws -> FitnessRecord { try await healthRepo.fetchTodayRecord() }
    func fetchWeekly() async throws -> [FitnessRecord] { try await healthRepo.fetchWeekRecords() }

    /// 根据今日健康数据计算副本通关进度
    func calculateDungeonProgress(record: FitnessRecord) -> DungeonProgress {
        DungeonProgress(
            stepsProgress: min(1.0, Double(record.steps) / 10000.0),
            caloriesProgress: min(1.0, record.activeCalories / 500.0),
            exerciseProgress: min(1.0, Double(record.exerciseMinutes) / 30.0),
            overallProgress: min(1.0, (Double(record.steps) / 10000.0 + record.activeCalories / 500.0 + Double(record.exerciseMinutes) / 30.0) / 3.0)
        )
    }
}

/// 副本通关进度
struct DungeonProgress: Sendable {
    let stepsProgress: Double; let caloriesProgress: Double; let exerciseProgress: Double; let overallProgress: Double
    var isCompleted: Bool { overallProgress >= 1.0 }
}
