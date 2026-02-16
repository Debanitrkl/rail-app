import Foundation
import Observation

@Observable
@MainActor
final class LiveTrackingService {
    static let shared = LiveTrackingService()

    private var trainSSEClient = SSEClient<LiveTrainPosition>()
    private var stationSSEClient = SSEClient<LiveStationSSEData>()

    private(set) var activeTrainPositions: [String: LiveTrainPosition] = [:]

    func connectToTrain(_ trainNumber: String) -> AsyncStream<LiveTrainPosition> {
        trainSSEClient.connect(to: .trainLive(number: trainNumber))
    }

    func disconnectTrain() {
        trainSSEClient.disconnect()
    }

    func connectToStation(_ code: String) -> AsyncStream<LiveStationSSEData> {
        stationSSEClient.connect(to: .stationLive(code: code))
    }

    func disconnectStation() {
        stationSSEClient.disconnect()
    }

    func updatePosition(_ position: LiveTrainPosition) {
        activeTrainPositions[position.trainNumber] = position
    }
}
