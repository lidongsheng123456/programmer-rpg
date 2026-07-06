import Foundation

/// 健康数据仓库协议
protocol HealthRepositoryProtocol: Sendable {
    func requestAuthorization() async throws
    func fetchTodayRecord() async throws -> FitnessRecord
    func fetchWeekRecords() async throws -> [FitnessRecord]
}