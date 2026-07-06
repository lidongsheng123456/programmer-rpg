import Foundation

struct FitnessRecord: Codable, Sendable {
    let date: Date
    let steps: Int
    let activeCalories: Double
    let exerciseMinutes: Int

    var stepsDisplay: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: steps)) ?? "\(steps)"
    }

    var caloriesDisplay: String {
        String(format: "%.0f kcal", activeCalories)
    }

    var exerciseDisplay: String {
        "\(exerciseMinutes) 分钟"
    }

    static let empty = FitnessRecord(
        date: Date(), steps: 0, activeCalories: 0, exerciseMinutes: 0
    )
}
