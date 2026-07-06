import Foundation

protocol HealthRepositoryProtocol: Sendable {
    func requestAuthorization() async throws
    func fetchTodayRecord() async throws -> FitnessRecord
    func fetchWeekRecords() async throws -> [FitnessRecord]
}
