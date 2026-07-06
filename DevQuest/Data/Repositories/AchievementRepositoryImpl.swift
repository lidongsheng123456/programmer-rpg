import Foundation
final class AchievementRepositoryImpl: AchievementRepositoryProtocol, @unchecked Sendable {
    private let local: UserDefaultsDataSource
    init(local: UserDefaultsDataSource) { self.local = local }
    func getUnlockedRecords() -> [AchievementRecord] { local.getAchievementRecords() }
    func unlock(achievementId: String) throws {
        var r = local.getAchievementRecords()
        guard !r.contains(where: { $0.achievementId == achievementId }) else { return }
        r.append(AchievementRecord(id: UUID().uuidString, achievementId: achievementId, unlockedAt: Date()))
        local.saveAchievementRecords(r)
    }
    func isUnlocked(achievementId: String) -> Bool { local.getAchievementRecords().contains { $0.achievementId == achievementId } }
}