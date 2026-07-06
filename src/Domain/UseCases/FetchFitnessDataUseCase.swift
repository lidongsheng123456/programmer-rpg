import Foundation

final class FetchFitnessDataUseCase: @unchecked Sendable {
    private let healthRepo: HealthRepositoryProtocol

    init(healthRepo: HealthRepositoryProtocol) {
        self.healthRepo = healthRepo
    }

    func requestPermission() async throws {
        try await healthRepo.requestAuthorization()
    }

    func fetchToday() async throws -> FitnessRecord {
        try await healthRepo.fetchTodayRecord()
    }

    func fetchWeekly() async throws -> [FitnessRecord] {
        try await healthRepo.fetchWeekRecords()
    }

    func calculateDungeonProgress(record: FitnessRecord) -> DungeonProgress {
        let stepsGoal = 10000
        let caloriesGoal = 500.0
        let exerciseGoal = 30

        return DungeonProgress(
            stepsProgress: min(1.0, Double(record.steps) / Double(stepsGoal)),
            caloriesProgress: min(1.0, record.activeCalories / caloriesGoal),
            exerciseProgress: min(1.0, Double(record.exerciseMinutes) / Double(exerciseGoal)),
            overallProgress: min(1.0,
                (Double(record.steps) / Double(stepsGoal)
                + record.activeCalories / caloriesGoal
                + Double(record.exerciseMinutes) / Double(exerciseGoal)) / 3.0
            )
        )
    }
}

struct DungeonProgress: Sendable {
    let stepsProgress: Double
    let caloriesProgress: Double
    let exerciseProgress: Double
    let overallProgress: Double

    var isCompleted: Bool { overallProgress >= 1.0 }
}
