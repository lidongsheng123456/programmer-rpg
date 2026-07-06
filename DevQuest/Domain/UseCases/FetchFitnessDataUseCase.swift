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