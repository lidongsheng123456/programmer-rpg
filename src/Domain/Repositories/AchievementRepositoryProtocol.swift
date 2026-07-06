import Foundation

protocol AchievementRepositoryProtocol: Sendable {
    func getUnlockedRecords() -> [AchievementRecord]
    func unlock(achievementId: String) throws
    func isUnlocked(achievementId: String) -> Bool
}
