import Foundation

/// Date \u6269\u5c55\u65b9\u6cd5\uff0c\u63d0\u4f9b\u5e38\u7528\u65e5\u671f\u8ba1\u7b97\u548c\u683c\u5f0f\u5316
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
