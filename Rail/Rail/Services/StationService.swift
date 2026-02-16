import Foundation

enum StationService {
    static func getStationInfo(_ code: String) async throws -> Station {
        try await APIClient.shared.request(.stationInfo(code: code))
    }

    static func getPlatformStatus(_ code: String) async throws -> [PlatformStatus] {
        try await APIClient.shared.request(.stationPlatforms(code: code))
    }

    static func searchStations(_ query: String) async throws -> [StationSearchResult] {
        try await APIClient.shared.request(.searchStations(query: query))
    }
}
