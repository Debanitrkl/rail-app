import Foundation
import Observation
import SwiftUI

@Observable
@MainActor
final class StationViewModel {
    var station: Station?
    var platforms: [PlatformStatus] = []
    var departures: [StationTrain] = []
    var searchQuery = ""
    var searchResults: [StationSearchResult] = []
    var isSearching = false
    var isLoading = true
    var error: String?

    private var sseClient = SSEClient<LiveStationSSEData>()
    private var sseTask: Task<Void, Never>?
    private var searchTask: Task<Void, Never>?

    func searchStations(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 2 else {
            searchResults = []
            return
        }

        searchTask?.cancel()
        searchTask = Task {
            isSearching = true
            do {
                searchResults = try await StationService.searchStations(trimmed)
            } catch {
                searchResults = []
            }
            isSearching = false
        }
    }

    func loadStation(_ code: String) async {
        isLoading = true
        error = nil

        do {
            async let stationResult = StationService.getStationInfo(code)
            async let platformResult = StationService.getPlatformStatus(code)

            station = try await stationResult
            platforms = try await platformResult

            // Extract departures from station trains
            if let trains = station?.trains {
                departures = trains
                    .filter { $0.departureTime != nil }
                    .sorted { ($0.departureTime ?? "") < ($1.departureTime ?? "") }
            }

            connectToLive(code)
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func connectToLive(_ code: String) {
        sseTask?.cancel()
        sseTask = Task {
            let stream = sseClient.connect(to: .stationLive(code: code))
            for await event in stream {
                if let updatedPlatforms = event.platforms {
                    self.platforms = updatedPlatforms
                }
            }
        }
    }

    func disconnect() {
        sseTask?.cancel()
        sseClient.disconnect()
    }
}
