import Foundation

/// \u516d\u7ef4\u6218\u529b\u503c\u5b9e\u4f53\uff0c\u6838\u5fc3\u6570\u636e\u6a21\u578b
struct PowerStats: Codable, Equatable, Sendable {
    let attack: Double
    let defense: Double
    let health: Double
    let intelligence: Double
    let agility: Double
    let reputation: Double

    /// \u7efc\u5408\u6218\u529b\uff08\u516d\u7ef4\u5e73\u5747\u503c\uff09
    var totalPower: Double { (attack + defense + health + intelligence + agility + reputation) / 6.0 }

    /// \u96f7\u8fbe\u56fe\u7ef4\u5ea6\u6570\u636e
    var dimensions: [(label: String, value: Double)] {
        [("\u653b\u51fb", attack), ("\u9632\u5fa1", defense), ("\u4f53\u529b", health), ("\u667a\u529b", intelligence), ("\u654f\u6377", agility), ("\u58f0\u671b", reputation)]
    }

    var level: CharacterLevel { CharacterLevel.from(power: totalPower) }
    static let zero = PowerStats(attack: 0, defense: 0, health: 0, intelligence: 0, agility: 0, reputation: 0)
}

/// \u89d2\u8272\u7b49\u7ea7\u679a\u4e3e
enum CharacterLevel: String, Codable, Sendable {
    case bronze = "\u9752\u94dc\u7801\u519c"
    case silver = "\u767d\u94f6\u5de5\u7a0b\u5e08"
    case gold = "\u9ec4\u91d1\u67b6\u6784\u5e08"
    case platinum = "\u94c2\u91d1\u4e13\u5bb6"
    case diamond = "\u94bb\u77f3\u5927\u5e08"
    case master = "\u4f20\u5947\u5f00\u53d1\u8005"

    var minPower: Double {
        switch self { case .bronze: return 0; case .silver: return 20; case .gold: return 40; case .platinum: return 60; case .diamond: return 80; case .master: return 95 }
    }

    static func from(power: Double) -> CharacterLevel {
        switch power { case 95...: return .master; case 80..<95: return .diamond; case 60..<80: return .platinum; case 40..<60: return .gold; case 20..<40: return .silver; default: return .bronze }
    }
}
