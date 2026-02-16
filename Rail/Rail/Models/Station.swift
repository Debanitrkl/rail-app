import Foundation

struct Station: Codable, Identifiable, Hashable {
    var id: String { code }

    let code: String
    let name: String
    let zone: String
    let division: String
    let state: String
    let latitude: Double
    let longitude: Double
    let platformsCount: Int
    let amenities: StationAmenities
    let trains: [StationTrain]?

    struct StationAmenities: Codable, Hashable {
        let wifi: Bool
        let parking: Bool
    }
}

struct StationTrain: Codable, Identifiable, Hashable {
    var id: String { "\(trainNumber)-\(stopNumber)" }

    let trainNumber: String
    let trainName: String
    let arrivalTime: String?
    let departureTime: String?
    let platform: String?
    let stopNumber: Int
}

struct StationSearchResult: Codable, Identifiable, Hashable {
    var id: String { code }
    let code: String
    let name: String
    let zone: String
    let state: String
}
