import ActivityKit
import Foundation

struct RailActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var trainNumber: String
        var trainName: String
        var fromCode: String
        var toCode: String
        var currentStation: String
        var nextStation: String
        var speedKmph: Double
        var delayMinutes: Int
        var eta: String
        var progress: Double
        var platform: String
    }

    var journeyId: String
    var coach: String
    var berth: String
}
