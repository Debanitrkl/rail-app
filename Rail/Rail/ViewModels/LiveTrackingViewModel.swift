import CoreLocation
import Foundation
import Observation
import SwiftUI

@Observable
@MainActor
final class LiveTrackingViewModel {
    var train: Train?
    var route: [RouteStop] = []
    var livePosition: LiveTrainPosition?
    var geoRoute: [GeoRouteStop] = []
    var isLoading = true
    var error: String?

    private var sseClient = SSEClient<LiveTrainPosition>()
    private var sseTask: Task<Void, Never>?

    var routeCoordinates: [CLLocationCoordinate2D] {
        geoRoute.map(\.coordinate)
    }

    var trainCoordinate: CLLocationCoordinate2D? {
        guard let pos = livePosition else { return nil }
        if pos.latitude != 0, pos.longitude != 0 {
            return CLLocationCoordinate2D(latitude: pos.latitude, longitude: pos.longitude)
        }
        // Fallback: use current station coordinate
        guard let idx = currentStopIndex else { return nil }
        return geoRoute[safe: idx]?.coordinate
    }

    var currentStopIndex: Int? {
        guard let position = livePosition else { return nil }
        return route.firstIndex { $0.station.code == position.currentStation }
    }

    var progress: Double {
        guard let idx = currentStopIndex, !route.isEmpty else { return 0 }
        return Double(idx) / Double(route.count - 1)
    }

    var completedStops: [RouteStop] {
        guard let idx = currentStopIndex else { return [] }
        return Array(route.prefix(idx))
    }

    var currentStop: RouteStop? {
        guard let idx = currentStopIndex else { return nil }
        return route[safe: idx]
    }

    var upcomingStops: [RouteStop] {
        guard let idx = currentStopIndex else { return route }
        return Array(route.suffix(from: min(idx + 1, route.count)))
    }

    func loadTrain(_ trainNumber: String) async {
        isLoading = true
        error = nil

        do {
            async let trainResult = TrainService.getTrainInfo(trainNumber)
            async let routeResult = TrainService.getTrainRoute(trainNumber)

            train = try await trainResult
            route = try await routeResult

            await loadGeoRoute()
            connectToLive(trainNumber)
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func connectToLive(_ trainNumber: String) {
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

    func loadGeoRoute() async {
        let service = StationCoordinateService.shared
        await service.loadCoordinates(for: route)

        geoRoute = route.compactMap { stop in
            guard let coord = service.coordinates(for: stop.station.code) else { return nil }
            return GeoRouteStop(routeStop: stop, coordinate: coord)
        }
    }

    func stopStatus(for stop: RouteStop) -> StopStatus {
        guard let idx = currentStopIndex else { return .upcoming }
        let stopIdx = route.firstIndex(of: stop) ?? 0
        if stopIdx < idx { return .completed }
        if stopIdx == idx { return .current }
        return .upcoming
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
