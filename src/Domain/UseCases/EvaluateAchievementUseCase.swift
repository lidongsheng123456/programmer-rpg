import Foundation

final class EvaluateAchievementUseCase: @unchecked Sendable {
    private let achievementRepo: AchievementRepositoryProtocol
    private let calculatePower: CalculatePowerUseCase

    init(
        achievementRepo: AchievementRepositoryProtocol,
        calculatePower: CalculatePowerUseCase
    ) {
        self.achievementRepo = achievementRepo
        self.calculatePower = calculatePower
    }

    func evaluate(username: String) async throws -> [AchievementStatus] {
        let stats = try await calculatePower.execute(username: username)
        return Achievement.allAchievements.map { achievement in
            let unlocked = achievementRepo.isUnlocked(achievementId: achievement.id)
            let meetsCondition = checkCondition(achievement.condition, stats: stats)

            if meetsCondition && !unlocked {
                try? achievementRepo.unlock(achievementId: achievement.id)
            }

            return AchievementStatus(
                achievement: achievement,
                isUnlocked: unlocked || meetsCondition,
                progress: calculateProgress(achievement.condition, stats: stats)
            )
        }
    }

    func getUnlockedCount() -> Int {
        achievementRepo.getUnlockedRecords().count
    }

    private func checkCondition(_ condition: Achievement.Condition, stats: PowerStats) -> Bool {
        switch condition {
        case .totalPowerAbove(let threshold):
            return stats.totalPower >= threshold
        case .singleStatAbove(let stat, let threshold):
            return statValue(stat, from: stats) >= threshold
        case .commitStreak:
            return false // Requires historical data, simplified
        case .serverUptimeAbove(let threshold):
            return stats.defense >= threshold
        case .stepsAbove(let threshold):
            return stats.health >= Double(threshold) / 100.0
        case .blogPostsAbove:
            return stats.intelligence > 0
        case .starsAbove(let threshold):
            return stats.reputation >= Double(threshold)
        }
    }

    private func calculateProgress(_ condition: Achievement.Condition, stats: PowerStats) -> Double {
        switch condition {
        case .totalPowerAbove(let threshold):
            return min(1.0, stats.totalPower / threshold)
        case .singleStatAbove(let stat, let threshold):
            return min(1.0, statValue(stat, from: stats) / threshold)
        case .serverUptimeAbove(let threshold):
            return min(1.0, stats.defense / threshold)
        default:
            return 0
        }
    }

    private func statValue(_ name: String, from stats: PowerStats) -> Double {
        switch name {
        case "attack":       return stats.attack
        case "defense":      return stats.defense
        case "health":       return stats.health
        case "intelligence": return stats.intelligence
        case "agility":      return stats.agility
        case "reputation":   return stats.reputation
        default:             return 0
        }
    }
}

struct AchievementStatus: Identifiable, Sendable {
    let achievement: Achievement
    let isUnlocked: Bool
    let progress: Double

    var id: String { achievement.id }
}
