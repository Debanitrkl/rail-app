import Foundation

struct LiveTrainPosition: Codable, Hashable {
    let trainNumber: String
    let latitude: Double
    let longitude: Double
    let speedKmph: Double
    let delayMinutes: Int
    let currentStation: String
    let nextStation: String
    let etaNext: String
    let timestamp: String

    var isOnTime: Bool {
        delayMinutes <= 0
    }

    var isDelayed: Bool {
        delayMinutes > 5
    }

    var statusText: String {
        if delayMinutes <= 0 { return "On Time" }
        return "Late \(delayMinutes)m"
    }
}
