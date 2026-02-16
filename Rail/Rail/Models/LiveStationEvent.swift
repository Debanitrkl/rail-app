import Foundation

struct LiveStationEvent: Codable, Identifiable, Hashable {
    var id: String { "\(trainNumber)-\(timestamp)" }

    let type: String // arrival, departure, delay, platform_change
    let trainNumber: String
    let trainName: String
    let platform: String
    let scheduledTime: String
    let actualTime: String
    let delayMinutes: Int
    let timestamp: String
}

struct LiveStationSSEData: Codable {
    let type: String? // initial_status, platform_refresh, or event types
    let platforms: [PlatformStatus]?
    let event: LiveStationEvent?
}
