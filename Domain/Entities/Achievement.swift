import Foundation

struct Achievement: Codable, Identifiable, Sendable {
    let id: String; let title: String; let description: String; let icon: String
    let category: Category; let condition: Condition

    enum Category: String, Codable, CaseIterable, Sendable {
        case combat = "Combat", defense = "Defense", fitness = "Fitness", wisdom = "Wisdom", social = "Social", special = "Special"
    }
    enum Condition: Codable, Sendable {
        case totalPowerAbove(Double), singleStatAbove(String, Double), commitStreak(Int)
        case serverUptimeAbove(Double), stepsAbove(Int), blogPostsAbove(Int), starsAbove(Int)
    }
    static let allAchievements: [Achievement] = [
        Achievement(id: "first_blood", title: "First Blood", description: "Submit your first commit", icon: "drop.fill", category: .combat, condition: .singleStatAbove("attack", 10)),
        Achievement(id: "iron_wall", title: "Iron Wall", description: "Server uptime > 99% for 7 days", icon: "shield.checkered", category: .defense, condition: .serverUptimeAbove(99)),
        Achievement(id: "marathon", title: "Code Marathon", description: "Commit streak for 7 consecutive days", icon: "flame.fill", category: .combat, condition: .commitStreak(7)),
        Achievement(id: "walker", title: "Tireless Walker", description: "Daily steps exceed 10,000", icon: "figure.walk", category: .fitness, condition: .stepsAbove(10000)),
        Achievement(id: "blogger", title: "Prolific Writer", description: "Publish more than 10 blog posts", icon: "text.book.closed.fill", category: .wisdom, condition: .blogPostsAbove(10)),
        Achievement(id: "rising_star", title: "Rising Star", description: "Earn 50 GitHub Stars", icon: "star.fill", category: .social, condition: .starsAbove(50)),
        Achievement(id: "full_power", title: "Max Power", description: "Total power reaches 90 points", icon: "bolt.shield.fill", category: .special, condition: .totalPowerAbove(90)),
        Achievement(id: "balanced", title: "Hexagon Warrior", description: "All dimensions exceed 60 points", icon: "hexagon.fill", category: .special, condition: .totalPowerAbove(60)),
    ]
}

struct AchievementRecord: Codable, Identifiable, Sendable {
    let id: String; let achievementId: String; let unlockedAt: Date
}
