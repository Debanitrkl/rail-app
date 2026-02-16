import Foundation

enum TrainService {
    static func getTrainInfo(_ trainNumber: String) async throws -> Train {
        try await APIClient.shared.request(.trainInfo(number: trainNumber))
    }

    static func getTrainRoute(_ trainNumber: String) async throws -> [RouteStop] {
        try await APIClient.shared.request(.trainRoute(number: trainNumber))
    }

    static func getCoachComposition(_ trainNumber: String) async throws -> [Coach] {
        try await APIClient.shared.request(.trainCoachComposition(number: trainNumber))
    }

    static func searchTrains(_ query: String) async throws -> [TrainSearchResult] {
        try await APIClient.shared.request(.searchTrains(query: query))
    }

    static func getTrainsBetween(from: String, to: String, date: String? = nil) async throws -> [TrainSearchResult] {
        try await APIClient.shared.request(.trainsBetween(from: from, to: to, date: date))
    }

    static func getAllLivePositions() async throws -> [LiveTrainPosition] {
        try await APIClient.shared.request(.allLivePositions)
    }
}
