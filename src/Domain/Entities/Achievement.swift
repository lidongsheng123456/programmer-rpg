import Foundation

struct Achievement: Codable, Identifiable, Sendable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let category: Category
    let condition: Condition

    enum Category: String, Codable, CaseIterable, Sendable {
        case combat   = "战斗"
        case defense  = "防御"
        case fitness  = "健身"
        case wisdom   = "智慧"
        case social   = "社交"
        case special  = "特殊"
    }

    enum Condition: Codable, Sendable {
        case totalPowerAbove(Double)
        case singleStatAbove(String, Double)
        case commitStreak(Int)
        case serverUptimeAbove(Double)
        case stepsAbove(Int)
        case blogPostsAbove(Int)
        case starsAbove(Int)
    }

    static let allAchievements: [Achievement] = [
        Achievement(id: "first_blood", title: "初次见血", description: "首次提交代码",
                   icon: "drop.fill", category: .combat,
                   condition: .singleStatAbove("attack", 10)),
        Achievement(id: "iron_wall", title: "铜墙铁壁", description: "服务器 7 天在线率 > 99%",
                   icon: "shield.checkered", category: .defense,
                   condition: .serverUptimeAbove(99)),
        Achievement(id: "marathon", title: "代码马拉松", description: "连续 7 天提交代码",
                   icon: "flame.fill", category: .combat,
                   condition: .commitStreak(7)),
        Achievement(id: "walker", title: "行者无疆", description: "单日步数超过 10000",
                   icon: "figure.walk", category: .fitness,
                   condition: .stepsAbove(10000)),
        Achievement(id: "blogger", title: "笔耕不辍", description: "发布超过 10 篇博客",
                   icon: "text.book.closed.fill", category: .wisdom,
                   condition: .blogPostsAbove(10)),
        Achievement(id: "rising_star", title: "冉冉新星", description: "获得 50 个 GitHub Star",
                   icon: "star.fill", category: .social,
                   condition: .starsAbove(50)),
        Achievement(id: "full_power", title: "满级战神", description: "总战力达到 90 分",
                   icon: "bolt.shield.fill", category: .special,
                   condition: .totalPowerAbove(90)),
        Achievement(id: "balanced", title: "六边形战士", description: "所有维度超过 60 分",
                   icon: "hexagon.fill", category: .special,
                   condition: .totalPowerAbove(60)),
    ]
}

struct AchievementRecord: Codable, Identifiable, Sendable {
    let id: String
    let achievementId: String
    let unlockedAt: Date
}
