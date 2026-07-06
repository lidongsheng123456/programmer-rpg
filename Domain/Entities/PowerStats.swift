import Foundation

struct PowerStats: Codable, Equatable, Sendable {
    let attack: Double
    let defense: Double
    let health: Double
    let intelligence: Double
    let agility: Double
    let reputation: Double

    var totalPower: Double { (attack + defense + health + intelligence + agility + reputation) / 6.0 }
    var dimensions: [(label: String, value: Double)] {
        [("鏀诲嚮", attack), ("闃插尽", defense), ("鐢熷懡", health), ("鏅哄姏", intelligence), ("鏁忔嵎", agility), ("澹版湜", reputation)]
    }
    var level: CharacterLevel { CharacterLevel.from(power: totalPower) }
    static let zero = PowerStats(attack: 0, defense: 0, health: 0, intelligence: 0, agility: 0, reputation: 0)
}

enum CharacterLevel: String, Codable, Sendable {
    case bronze = "闈掗摐鐮佸啘", silver = "鐧介摱宸ョ▼甯?, gold = "榛勯噾鏋舵瀯甯?
    case platinum = "閾傞噾鎶€鏈笓瀹?, diamond = "閽荤煶鍏ㄦ爤澶у笀", master = "浼犺鐮佺"
    var minPower: Double {
        switch self { case .bronze: return 0; case .silver: return 20; case .gold: return 40; case .platinum: return 60; case .diamond: return 80; case .master: return 95 }
    }
    static func from(power: Double) -> CharacterLevel {
        switch power { case 95...: return .master; case 80..<95: return .diamond; case 60..<80: return .platinum; case 40..<60: return .gold; case 20..<40: return .silver; default: return .bronze }
    }
}