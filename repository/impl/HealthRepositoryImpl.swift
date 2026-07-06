import Foundation
import HealthKit

/// 健康数据仓库实现，封装 HealthKit 读取逻辑

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