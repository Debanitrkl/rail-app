import Foundation

struct Train: Codable, Identifiable, Hashable {
    var id: String { number }

    let number: String
    let name: String
    let type: String
    let source: StationRef
    let destination: StationRef
    let runsOn: String
    let avgSpeedKmph: Double
    let distanceKm: Double
    let durationMinutes: Int
    let amenities: TrainAmenities
    let schedule: [RouteStop]?

    struct StationRef: Codable, Hashable {
        let code: String
        let name: String
    }

    struct TrainAmenities: Codable, Hashable {
        let pantry: Bool
        let charging: Bool
        let bioToilet: Bool
        let cctv: Bool
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(number)
    }

    static func == (lhs: Train, rhs: Train) -> Bool {
        lhs.number == rhs.number
    }
}

struct TrainSearchResult: Codable, Identifiable, Hashable {
    var id: String { number }
    let number: String
    let name: String
    let type: String
    let sourceStation: String
    let destinationStation: String
}
