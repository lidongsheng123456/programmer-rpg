import Foundation

struct Achievement: Codable, Identifiable, Sendable {
    let id: String; let title: String; let description: String; let icon: String
    let category: Category; let condition: Condition

    enum Category: String, Codable, CaseIterable, Sendable {
        case combat = "鎴樻枟", defense = "闃插尽", fitness = "鍋ヨ韩", wisdom = "鏅烘収", social = "绀句氦", special = "鐗规畩"
    }
    enum Condition: Codable, Sendable {
        case totalPowerAbove(Double), singleStatAbove(String, Double), commitStreak(Int)
        case serverUptimeAbove(Double), stepsAbove(Int), blogPostsAbove(Int), starsAbove(Int)
    }
    static let allAchievements: [Achievement] = [
        Achievement(id: "first_blood", title: "鍒濇瑙佽", description: "棣栨鎻愪氦浠ｇ爜", icon: "drop.fill", category: .combat, condition: .singleStatAbove("attack", 10)),
        Achievement(id: "iron_wall", title: "閾滃閾佸", description: "鏈嶅姟鍣?澶╁湪绾跨巼>99%", icon: "shield.checkered", category: .defense, condition: .serverUptimeAbove(99)),
        Achievement(id: "marathon", title: "浠ｇ爜椹媺鏉?, description: "杩炵画7澶╂彁浜や唬鐮?, icon: "flame.fill", category: .combat, condition: .commitStreak(7)),
        Achievement(id: "walker", title: "琛岃€呮棤鐤?, description: "鍗曟棩姝ユ暟瓒呰繃10000", icon: "figure.walk", category: .fitness, condition: .stepsAbove(10000)),
        Achievement(id: "blogger", title: "绗旇€曚笉杈?, description: "鍙戝竷瓒呰繃10绡囧崥瀹?, icon: "text.book.closed.fill", category: .wisdom, condition: .blogPostsAbove(10)),
        Achievement(id: "rising_star", title: "鍐夊唹鏂版槦", description: "鑾峰緱50涓狦itHub Star", icon: "star.fill", category: .social, condition: .starsAbove(50)),
        Achievement(id: "full_power", title: "婊＄骇鎴樼", description: "鎬绘垬鍔涜揪鍒?0鍒?, icon: "bolt.shield.fill", category: .special, condition: .totalPowerAbove(90)),
        Achievement(id: "balanced", title: "鍏竟褰㈡垬澹?, description: "鎵€鏈夌淮搴﹁秴杩?0鍒?, icon: "hexagon.fill", category: .special, condition: .totalPowerAbove(60)),
    ]
}

struct AchievementRecord: Codable, Identifiable, Sendable {
    let id: String; let achievementId: String; let unlockedAt: Date
}