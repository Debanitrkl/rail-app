import Foundation

extension Date {
    func railFormatted(style: RailDateStyle) -> String {
        let formatter = DateFormatter()
        switch style {
        case .dayMonth:
            formatter.dateFormat = "dd MMM"
        case .dayMonthYear:
            formatter.dateFormat = "dd MMM yyyy"
        case .weekdayFull:
            formatter.dateFormat = "EEEE, d MMMM"
        case .time24:
            formatter.dateFormat = "HH:mm"
        case .time12:
            formatter.dateFormat = "hh:mm a"
        case .dateTime:
            formatter.dateFormat = "dd MMM • HH:mm"
        case .monthShort:
            formatter.dateFormat = "MMM"
        case .dayOnly:
            formatter.dateFormat = "dd"
        case .iso:
            formatter.dateFormat = "yyyy-MM-dd"
        }
        return formatter.string(from: self)
    }

    static func fromISO(_ string: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: string) { return date }
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: string)
    }

    static func fromTimeString(_ time: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.date(from: time)
    }
}

enum RailDateStyle {
    case dayMonth, dayMonthYear, weekdayFull, time24, time12, dateTime, monthShort, dayOnly, iso
}
