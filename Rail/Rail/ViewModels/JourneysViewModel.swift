import Foundation
import Observation
import SwiftUI

@Observable
@MainActor
final class JourneysViewModel {
    var activeJourney: Journey?
    var upcomingJourneys: [Journey] = []
    var livePosition: LiveTrainPosition?
    var allLivePositions: [LiveTrainPosition] = []
    var isLoading = true
    var error: String?

    private var sseClient = SSEClient<LiveTrainPosition>()
    private var sseTask: Task<Void, Never>?
    private var mapRefreshTask: Task<Void, Never>?

    var todayFormatted: String {
        Date().railFormatted(style: .weekdayFull)
    }

    func loadJourneys() async {
        isLoading = true
        error = nil

        do {
            async let journeysResult = JourneyService.getUserJourneys()
            async let positionsResult = TrainService.getAllLivePositions()

            let journeys = try await journeysResult
            allLivePositions = (try? await positionsResult) ?? []

            activeJourney = journeys.first(where: { $0.isActive })
            upcomingJourneys = journeys.filter { $0.isUpcoming }

            if let active = activeJourney {
                connectToLiveTracking(trainNumber: active.trainNumber)
            }

            startMapRefresh()
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    private func startMapRefresh() {
        mapRefreshTask?.cancel()
        mapRefreshTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(30))
                if Task.isCancelled { break }
                if let positions = try? await TrainService.getAllLivePositions() {
                    allLivePositions = positions
                }
            }
        }
    }

    func connectToLiveTracking(trainNumber: String) {
        sseTask?.cancel()
        sseTask = Task {
            let stream = sseClient.connect(to: .trainLive(number: trainNumber))
            for await position in stream {
                self.livePosition = position
            }
        }
    }

    func disconnect() {
        sseTask?.cancel()
        sseClient.disconnect()
    }
}
