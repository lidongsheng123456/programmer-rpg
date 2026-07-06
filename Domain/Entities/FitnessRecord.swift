import Foundation

struct FitnessRecord: Codable, Sendable {
    let date: Date; let steps: Int; let activeCalories: Double; let exerciseMinutes: Int
    var stepsDisplay: String { let f = NumberFormatter(); f.numberStyle = .decimal; return f.string(from: NSNumber(value: steps)) ?? "\(steps)" }
    var caloriesDisplay: String { String(format: "%.0f kcal", activeCalories) }
    var exerciseDisplay: String { "\(exerciseMinutes) 鍒嗛挓" }
    static let empty = FitnessRecord(date: Date(), steps: 0, activeCalories: 0, exerciseMinutes: 0)
}