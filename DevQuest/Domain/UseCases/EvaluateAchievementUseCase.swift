import Foundation

final class EvaluateAchievementUseCase: @unchecked Sendable {
    private let achievementRepo: AchievementRepositoryProtocol
    private let calculatePower: CalculatePowerUseCase
    init(achievementRepo: AchievementRepositoryProtocol, calculatePower: CalculatePowerUseCase) {
        self.achievementRepo = achievementRepo; self.calculatePower = calculatePower
    }

    func evaluate(username: String) async throws -> [AchievementStatus] {
        let stats = try await calculatePower.execute(username: username)
        return Achievement.allAchievements.map { a in
            let unlocked = achievementRepo.isUnlocked(achievementId: a.id)
            let meets = checkCondition(a.condition, stats: stats)
            if meets && !unlocked { try? achievementRepo.unlock(achievementId: a.id) }
            return AchievementStatus(achievement: a, isUnlocked: unlocked || meets, progress: calcProgress(a.condition, stats: stats))
        }
    }
    func getUnlockedCount() -> Int { achievementRepo.getUnlockedRecords().count }

    private func checkCondition(_ c: Achievement.Condition, stats: PowerStats) -> Bool {
        switch c {
        case .totalPowerAbove(let t): return stats.totalPower >= t
        case .singleStatAbove(let s, let t): return statVal(s, stats) >= t
        case .serverUptimeAbove(let t): return stats.defense >= t
        case .stepsAbove(let t): return stats.health >= Double(t) / 100.0
        default: return false
        }
    }
    private func calcProgress(_ c: Achievement.Condition, stats: PowerStats) -> Double {
        switch c {
        case .totalPowerAbove(let t): return min(1, stats.totalPower / t)
        case .singleStatAbove(let s, let t): return min(1, statVal(s, stats) / t)
        case .serverUptimeAbove(let t): return min(1, stats.defense / t)
        default: return 0
        }
    }
    private func statVal(_ n: String, _ s: PowerStats) -> Double {
        switch n { case "attack": return s.attack; case "defense": return s.defense; case "health": return s.health
        case "intelligence": return s.intelligence; case "agility": return s.agility; case "reputation": return s.reputation; default: return 0 }
    }
}

struct AchievementStatus: Identifiable, Sendable {
    let achievement: Achievement; let isUnlocked: Bool; let progress: Double
    var id: String { achievement.id }
}