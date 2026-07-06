import Foundation

extension Date {
    var startOfDay: Date { Calendar.current.startOfDay(for: self) }
    var startOfWeek: Date {
        let c = Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return Calendar.current.date(from: c) ?? self
    }
    var daysAgo7: Date { Calendar.current.date(byAdding: .day, value: -7, to: self) ?? self }
    var isToday: Bool { Calendar.current.isDateInToday(self) }
    var relativeString: String {
        let f = RelativeDateTimeFormatter(); f.locale = Locale(identifier: "zh_CN"); f.unitsStyle = .short
        return f.localizedString(for: self, relativeTo: .now)
    }
    var shortDateString: String {
        let f = DateFormatter(); f.dateFormat = "MM/dd"; return f.string(from: self)
    }
}