import Foundation

extension String {
    var formattedPNR: String {
        guard count >= 10 else { return self }
        let cleaned = filter { $0.isNumber }
        guard cleaned.count >= 10 else { return self }
        let idx1 = cleaned.index(cleaned.startIndex, offsetBy: 3)
        let idx2 = cleaned.index(idx1, offsetBy: 7)
        return "\(cleaned[cleaned.startIndex..<idx1])-\(cleaned[idx1..<idx2])"
    }

    func durationFormatted(minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        if hours > 0 && mins > 0 {
            return "\(hours)h \(mins)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(mins)m"
        }
    }

    static func duration(minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        if hours > 0 && mins > 0 {
            return "\(hours)h \(mins)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(mins)m"
        }
    }

    static func distanceFormatted(km: Double) -> String {
        if km >= 1000 {
            return String(format: "%.0f km", km)
        }
        return String(format: "%.0f km", km)
    }
}
