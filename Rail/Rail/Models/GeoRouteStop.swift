import CoreLocation
import Foundation

struct GeoRouteStop: Identifiable {
    let routeStop: RouteStop
    let coordinate: CLLocationCoordinate2D

    var id: String { routeStop.id }
    var stationCode: String { routeStop.station.code }
    var stationName: String { routeStop.station.name }
    var stopNumber: Int { routeStop.stopNumber }
    var arrivalTime: String? { routeStop.arrivalTime }
    var departureTime: String? { routeStop.departureTime }
    var platform: String? { routeStop.platform }

    func isPassed(currentIndex: Int) -> Bool {
        let idx = routeStop.stopNumber - 1
        return idx < currentIndex
    }

    func isCurrent(currentIndex: Int) -> Bool {
        let idx = routeStop.stopNumber - 1
        return idx == currentIndex
    }
}
