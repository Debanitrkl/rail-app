import Foundation

struct Journey: Codable, Identifiable, Hashable {
    let id: String
    let trainNumber: String
    let trainName: String
    let trainType: String
    let pnr: String?
    let boarding: StationRef
    let destination: StationRef
    let travelDate: String
    let coach: String?
    let berth: String?
    let travelClass: String?
    let status: String
    let createdAt: String?

    struct StationRef: Codable, Hashable {
        let code: String
        let name: String
    }

    var isActive: Bool {
        status == "active" || status == "en_route"
    }

    var isUpcoming: Bool {
        status == "upcoming" || status == "confirmed"
    }

    var travelDateParsed: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: travelDate)
    }
}
