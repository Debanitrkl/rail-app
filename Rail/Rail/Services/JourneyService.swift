import Foundation

enum JourneyService {
    static func getUserJourneys() async throws -> [Journey] {
        try await APIClient.shared.request(.journeys)
    }

    static func getJourneyDetail(_ id: String) async throws -> Journey {
        try await APIClient.shared.request(.journeyDetail(id: id))
    }

    static func createJourney(_ dto: CreateJourneyRequest) async throws -> Journey {
        try await APIClient.shared.request(.createJourney, body: dto)
    }

    static func deleteJourney(_ id: String) async throws {
        let _: EmptyData = try await APIClient.shared.request(.deleteJourney(id: id))
    }
}

struct CreateJourneyRequest: Encodable {
    let trainNumber: String
    let pnr: String?
    let boardingStation: String
    let destinationStation: String
    let travelDate: String
    let coach: String?
    let berth: String?
    let travelClass: String?
}

private struct EmptyData: Decodable {}
