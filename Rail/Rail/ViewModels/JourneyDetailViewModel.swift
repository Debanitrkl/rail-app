import Foundation
import Observation
import SwiftUI

@Observable
@MainActor
final class JourneyDetailViewModel {
    var train: Train?
    var coaches: [Coach] = []
    var journey: Journey?
    var isLoading = true
    var error: String?

    func loadDetail(trainNumber: String, journeyId: String? = nil) async {
        isLoading = true
        error = nil

        do {
            async let trainResult = TrainService.getTrainInfo(trainNumber)
            async let coachResult = TrainService.getCoachComposition(trainNumber)

            train = try await trainResult
            coaches = try await coachResult

            if let jId = journeyId {
                journey = try? await JourneyService.getJourneyDetail(jId)
            }
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    var userCoachLabel: String? {
        journey?.coach
    }

    var amenitiesList: [(String, String)] {
        guard let amenities = train?.amenities else { return [] }
        var list: [(String, String)] = []
        if amenities.pantry { list.append(("cup.and.saucer.fill", "Pantry Car")) }
        if amenities.charging { list.append(("bolt.fill", "Charging Point")) }
        if amenities.bioToilet { list.append(("leaf.fill", "Bio Toilet")) }
        if amenities.cctv { list.append(("video.fill", "CCTV")) }
        return list
    }
}
