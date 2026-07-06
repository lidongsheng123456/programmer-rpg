import Foundation

/// \u6210\u5c31\u5b9e\u4f53\uff0c\u5b9a\u4e49\u6e38\u620f\u4e2d\u53ef\u89e3\u9501\u7684\u6210\u5c31\u7cfb\u7edf
struct Achievement: Codable, Identifiable, Sendable {
    let id: String; let title: String; let description: String; let icon: String
    let category: Category; let condition: Condition

    /// \u6210\u5c31\u5206\u7c7b
    enum Category: String, Codable, CaseIterable, Sendable {
        case combat = "\u653b\u51fb", defense = "\u9632\u5fa1", fitness = "\u4f53\u80fd", wisdom = "\u667a\u6167", social = "\u793e\u4ea4", special = "\u7279\u6b8a"
    }

    /// \u89e3\u9501\u6761\u4ef6
    enum Condition: Codable, Sendable {
        case totalPowerAbove(Double), singleStatAbove(String, Double), commitStreak(Int)
        case serverUptimeAbove(Double), stepsAbove(Int), blogPostsAbove(Int), starsAbove(Int)
    }

    /// \u9884\u5b9a\u4e49\u6210\u5c31\u5217\u8868
    static let allAchievements: [Achievement] = [
        Achievement(id: "first_blood", title: "\u7b2c\u4e00\u6ef4\u8840", description: "\u63d0\u4ea4\u7b2c\u4e00\u6b21 Commit", icon: "drop.fill", category: .combat, condition: .singleStatAbove("attack", 10)),
        Achievement(id: "iron_wall", title: "\u94dc\u5899\u94c1\u58c1", description: "\u670d\u52a1\u5668\u8fde\u7eed7\u5929\u5728\u7ebf\u7387>99%", icon: "shield.checkered", category: .defense, condition: .serverUptimeAbove(99)),
        Achievement(id: "marathon", title: "\u4ee3\u7801\u9a6c\u62c9\u677e", description: "\u8fde\u7eed7\u5929\u6bcf\u5929\u90fd\u6709 Commit", icon: "flame.fill", category: .combat, condition: .commitStreak(7)),
        Achievement(id: "walker", title: "\u4e0d\u77e5\u75b2\u5026", description: "\u5355\u65e5\u6b65\u6570\u8d85\u8fc710000\u6b65", icon: "figure.walk", category: .fitness, condition: .stepsAbove(10000)),
        Achievement(id: "blogger", title: "\u7b14\u8015\u4e0d\u8f8d", description: "\u53d1\u5e03\u8d85\u8fc710\u7bc7\u535a\u5ba2\u6587\u7ae0", icon: "text.book.closed.fill", category: .wisdom, condition: .blogPostsAbove(10)),
        Achievement(id: "rising_star", title: "\u5192\u5934\u65b0\u661f", description: "\u83b7\u5f9750\u4e2a GitHub Star", icon: "star.fill", category: .social, condition: .starsAbove(50)),
        Achievement(id: "full_power", title: "\u6ee1\u7ea7\u6218\u529b", description: "\u603b\u6218\u529b\u8fbe\u523090\u5206", icon: "bolt.shield.fill", category: .special, condition: .totalPowerAbove(90)),
        Achievement(id: "balanced", title: "\u516d\u8fb9\u5f62\u6218\u58eb", description: "\u6240\u6709\u7ef4\u5ea6\u5747\u8d85\u8fc760\u5206", icon: "hexagon.fill", category: .special, condition: .totalPowerAbove(60)),
    ]
}

/// \u6210\u5c31\u89e3\u9501\u8bb0\u5f55
struct AchievementRecord: Codable, Identifiable, Sendable {
    let id: String; let achievementId: String; let unlockedAt: Date
}
