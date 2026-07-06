import Foundation

struct PowerStats: Codable, Equatable, Sendable {
    let attack: Double      // 攻击力 - 基于 commit 数量
    let defense: Double     // 防御力 - 基于服务器在线率
    let health: Double      // 生命值 - 基于运动数据
    let intelligence: Double // 智力  - 基于博客产出
    let agility: Double     // 敏捷  - 基于 issue 关闭速度
    let reputation: Double  // 声望  - 基于 star/follower 数

    var totalPower: Double {
        (attack + defense + health + intelligence + agility + reputation) / 6.0
    }

    var dimensions: [(label: String, value: Double)] {
        [
            ("攻击", attack),
            ("防御", defense),
            ("生命", health),
            ("智力", intelligence),
            ("敏捷", agility),
            ("声望", reputation)
        ]
    }

    var level: CharacterLevel {
        CharacterLevel.from(power: totalPower)
    }

    static let zero = PowerStats(
        attack: 0, defense: 0, health: 0,
        intelligence: 0, agility: 0, reputation: 0
    )
}

enum CharacterLevel: String, Codable, Sendable {
    case bronze   = "青铜码农"
    case silver   = "白银工程师"
    case gold     = "黄金架构师"
    case platinum = "铂金技术专家"
    case diamond  = "钻石全栈大师"
    case master   = "传说码神"

    var minPower: Double {
        switch self {
        case .bronze:   return 0
        case .silver:   return 20
        case .gold:     return 40
        case .platinum: return 60
        case .diamond:  return 80
        case .master:   return 95
        }
    }

    static func from(power: Double) -> CharacterLevel {
        switch power {
        case 95...:  return .master
        case 80..<95: return .diamond
        case 60..<80: return .platinum
        case 40..<60: return .gold
        case 20..<40: return .silver
        default:      return .bronze
        }
    }
}
