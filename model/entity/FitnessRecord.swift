import Foundation

/// \u5065\u5eb7\u6570\u636e\u8bb0\u5f55\u5b9e\u4f53
struct FitnessRecord: Codable, Sendable {
    let date: Date; let steps: Int; let activeCalories: Double; let exerciseMinutes: Int
    var stepsDisplay: String { let f = NumberFormatter(); f.numberStyle = .decimal; return f.string(from: NSNumber(value: steps)) ?? "\(steps)" }
    var caloriesDisplay: String { String(format: "%.0f \u5361", activeCalories) }
    var exerciseDisplay: String { "\(exerciseMinutes) \u5206\u949f" }
    static let empty = FitnessRecord(date: Date(), steps: 0, activeCalories: 0, exerciseMinutes: 0)
}
