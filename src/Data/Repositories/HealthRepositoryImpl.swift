import Foundation
import HealthKit

final class HealthRepositoryImpl: HealthRepositoryProtocol, @unchecked Sendable {
    private let healthStore = HKHealthStore()

    private let readTypes: Set<HKObjectType> = {
        var types = Set<HKObjectType>()
        if let steps = HKQuantityType.quantityType(forIdentifier: .stepCount) {
            types.insert(steps)
        }
        if let calories = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) {
            types.insert(calories)
        }
        if let exercise = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime) {
            types.insert(exercise)
        }
        return types
    }()

    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        try await healthStore.requestAuthorization(toShare: [], read: readTypes)
    }

    func fetchTodayRecord() async throws -> FitnessRecord {
        let start = Date().startOfDay
        let end = Date()

        async let steps = querySum(.stepCount, unit: .count(), start: start, end: end)
        async let calories = querySum(.activeEnergyBurned, unit: .kilocalorie(), start: start, end: end)
        async let exercise = querySum(.appleExerciseTime, unit: .minute(), start: start, end: end)

        return FitnessRecord(
            date: start,
            steps: Int(try await steps),
            activeCalories: try await calories,
            exerciseMinutes: Int(try await exercise)
        )
    }

    func fetchWeekRecords() async throws -> [FitnessRecord] {
        var records: [FitnessRecord] = []
        let calendar = Calendar.current

        for dayOffset in 0..<7 {
            guard let dayStart = calendar.date(byAdding: .day, value: -dayOffset, to: Date())?.startOfDay,
                  let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else { continue }

            let steps = (try? await querySum(.stepCount, unit: .count(), start: dayStart, end: dayEnd)) ?? 0
            let calories = (try? await querySum(.activeEnergyBurned, unit: .kilocalorie(), start: dayStart, end: dayEnd)) ?? 0
            let exercise = (try? await querySum(.appleExerciseTime, unit: .minute(), start: dayStart, end: dayEnd)) ?? 0

            records.append(FitnessRecord(
                date: dayStart,
                steps: Int(steps),
                activeCalories: calories,
                exerciseMinutes: Int(exercise)
            ))
        }

        return records.reversed()
    }

    private func querySum(
        _ identifier: HKQuantityTypeIdentifier,
        unit: HKUnit,
        start: Date,
        end: Date
    ) async throws -> Double {
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: identifier) else {
            return 0
        }

        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: quantityType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, statistics, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                let value = statistics?.sumQuantity()?.doubleValue(for: unit) ?? 0
                continuation.resume(returning: value)
            }
            healthStore.execute(query)
        }
    }
}
