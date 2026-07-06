import Foundation

/// 成就仓库协议
protocol AchievementRepositoryProtocol: Sendable {
    func getUnlockedRecords() -> [AchievementRecord]
    func unlock(achievementId: String) throws
    func isUnlocked(achievementId: String) -> Bool
}