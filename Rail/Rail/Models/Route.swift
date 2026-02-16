import Foundation

struct RouteStop: Codable, Identifiable, Hashable {
    var id: String { "\(station.code)-\(stopNumber)" }

    let stopNumber: Int
    let station: StationRef
    let arrivalTime: String?
    let departureTime: String?
    let haltMinutes: Int
    let distanceFromSource: Double
    let dayNumber: Int
    let platform: String?

    struct StationRef: Codable, Hashable {
        let code: String
        let name: String
    }
}

enum StopStatus {
    case completed
    case current
    case upcoming

    var dotColor: String {
        switch self {
        case .completed: return "accent"
        case .current: return "accentRing"
        case .upcoming: return "gray"
        }
    }
}
