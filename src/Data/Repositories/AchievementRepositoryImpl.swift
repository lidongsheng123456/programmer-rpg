import Foundation

final class AchievementRepositoryImpl: AchievementRepositoryProtocol, @unchecked Sendable {
    private let local: UserDefaultsDataSource

    init(local: UserDefaultsDataSource) {
        self.local = local
    }

    func getUnlockedRecords() -> [AchievementRecord] {
        local.getAchievementRecords()
    }

    func unlock(achievementId: String) throws {
        var records = local.getAchievementRecords()
        guard !records.contains(where: { $0.achievementId == achievementId }) else { return }

        let record = AchievementRecord(
            id: UUID().uuidString,
            achievementId: achievementId,
            unlockedAt: Date()
        )
        records.append(record)
        local.saveAchievementRecords(records)
    }

    func isUnlocked(achievementId: String) -> Bool {
        local.getAchievementRecords().contains { $0.achievementId == achievementId }
    }
}
