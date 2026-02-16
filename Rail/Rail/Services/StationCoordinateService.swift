import CoreLocation
import Foundation

@MainActor
final class StationCoordinateService {
    static let shared = StationCoordinateService()

    private var cache: [String: CLLocationCoordinate2D] = [:]
    private var isLoaded = false
    private var loadTask: Task<Void, Never>?

    private init() {}

    func coordinates(for stationCode: String) -> CLLocationCoordinate2D? {
        cache[stationCode.uppercased()]
    }

    func preload() {
        guard !isLoaded, loadTask == nil else { return }
        loadTask = Task {
            await loadAllStations()
        }
    }

    func ensureLoaded() async {
        if isLoaded { return }
        if let task = loadTask {
            await task.value
        } else {
            await loadAllStations()
        }
    }

    private func loadAllStations() async {
        do {
            let stations: [Station] = try await APIClient.shared.request(.allStations)
            for station in stations {
                cache[station.code.uppercased()] = CLLocationCoordinate2D(
                    latitude: station.latitude,
                    longitude: station.longitude
                )
            }
            isLoaded = true
        } catch {
            // Fallback: service will return nil for unknown stations
        }
        loadTask = nil
    }

    func cacheFromRoute(_ stops: [RouteStop], stations: [Station]) {
        for station in stations {
            cache[station.code.uppercased()] = CLLocationCoordinate2D(
                latitude: station.latitude,
                longitude: station.longitude
            )
        }
    }

    func loadCoordinates(for stops: [RouteStop]) async {
        for stop in stops {
            let code = stop.station.code.uppercased()
            if cache[code] != nil { continue }
            do {
                let station: Station = try await APIClient.shared.request(.stationInfo(code: code))
                cache[code] = CLLocationCoordinate2D(
                    latitude: station.latitude,
                    longitude: station.longitude
                )
            } catch {
                continue
            }
        }
    }
}
