import Foundation
import Observation
import SwiftUI

@Observable
@MainActor
final class SearchViewModel {
    var searchQuery = ""
    var trainResults: [TrainSearchResult] = []
    var stationResults: [StationSearchResult] = []
    var pnrStatus: PNRStatus?
    var recentSearches: [RecentSearch] = []
    var isSearching = false
    var isPNRLoading = false
    var error: String?

    private var searchTask: Task<Void, Never>?

    func loadInitial() {
        recentSearches = PersistenceService.getRecentSearches()
    }

    func search() {
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            clearResults()
            return
        }

        searchTask?.cancel()
        searchTask = Task {
            isSearching = true
            error = nil

            // Check if PNR (10+ digits)
            if query.filter({ $0.isNumber }).count >= 10 {
                await searchPNR(query)
            } else {
                await searchTrainsAndStations(query)
            }

            isSearching = false
        }
    }

    func searchPNR(_ pnr: String) async {
        isPNRLoading = true
        let cleanPNR = pnr.filter { $0.isNumber }
        do {
            pnrStatus = try await PNRService.getPNRStatus(cleanPNR)

            PersistenceService.addRecentSearch(RecentSearch(
                query: cleanPNR,
                displayTitle: "PNR \(cleanPNR.formattedPNR)",
                displaySubtitle: "Checked just now",
                type: .pnr,
                timestamp: Date()
            ))
            recentSearches = PersistenceService.getRecentSearches()
        } catch {
            self.error = error.localizedDescription
        }
        isPNRLoading = false
    }

    func searchTrainsAndStations(_ query: String) async {
        do {
            async let trains = TrainService.searchTrains(query)
            async let stations = StationService.searchStations(query)

            trainResults = try await trains
            stationResults = try await stations
        } catch {
            self.error = error.localizedDescription
        }
    }

    func clearResults() {
        trainResults = []
        stationResults = []
        pnrStatus = nil
    }

    func selectTrain(_ train: TrainSearchResult) {
        PersistenceService.addRecentSearch(RecentSearch(
            query: train.number,
            displayTitle: "\(train.number) \(train.name)",
            displaySubtitle: "\(train.sourceStation) → \(train.destinationStation)",
            type: .train,
            timestamp: Date()
        ))
        recentSearches = PersistenceService.getRecentSearches()
        PersistenceService.lastViewedTrainNumber = train.number
    }

    func selectStation(_ station: StationSearchResult) {
        PersistenceService.addRecentSearch(RecentSearch(
            query: station.code,
            displayTitle: "\(station.name) (\(station.code))",
            displaySubtitle: "Station info",
            type: .station,
            timestamp: Date()
        ))
        recentSearches = PersistenceService.getRecentSearches()
        PersistenceService.lastViewedStationCode = station.code
    }
}
