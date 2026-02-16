import Foundation

enum APIEndpoint {
    // Journeys
    case journeys
    case journeyDetail(id: String)
    case createJourney
    case deleteJourney(id: String)

    // Trains
    case trainInfo(number: String)
    case trainRoute(number: String)
    case trainCoachComposition(number: String)
    case trainLive(number: String)
    case allLivePositions
    case searchTrains(query: String)
    case trainsBetween(from: String, to: String, date: String?)

    // Stations
    case allStations
    case stationInfo(code: String)
    case stationPlatforms(code: String)
    case stationLive(code: String)
    case searchStations(query: String)

    // PNR
    case pnrStatus(number: String)
    case watchedPnrs
    case watchPnr
    case unwatchPnr(number: String)

    // Widget
    case widgetJourney
    case widgetPnr

    // Health
    case health

    var path: String {
        switch self {
        case .journeys: return "/journeys"
        case .journeyDetail(let id): return "/journeys/\(id)"
        case .createJourney: return "/journeys"
        case .deleteJourney(let id): return "/journeys/\(id)"
        case .trainInfo(let number): return "/trains/\(number)"
        case .trainRoute(let number): return "/trains/\(number)/route"
        case .trainCoachComposition(let number): return "/trains/\(number)/coach-composition"
        case .trainLive(let number): return "/trains/\(number)/live"
        case .allLivePositions: return "/trains/live/all"
        case .searchTrains(let query): return "/trains/search?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query)"
        case .trainsBetween(let from, let to, let date):
            var path = "/trains/between?from=\(from)&to=\(to)"
            if let date { path += "&date=\(date)" }
            return path
        case .allStations: return "/stations"
        case .stationInfo(let code): return "/stations/\(code)"
        case .stationPlatforms(let code): return "/stations/\(code)/platforms"
        case .stationLive(let code): return "/stations/\(code)/live"
        case .searchStations(let query): return "/stations/search?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query)"
        case .pnrStatus(let number): return "/pnr/\(number)"
        case .watchedPnrs: return "/pnr/watched"
        case .watchPnr: return "/pnr/watch"
        case .unwatchPnr(let number): return "/pnr/watch/\(number)"
        case .widgetJourney: return "/widget/journey"
        case .widgetPnr: return "/widget/pnr"
        case .health: return "/health"
        }
    }

    var method: String {
        switch self {
        case .createJourney, .watchPnr: return "POST"
        case .deleteJourney, .unwatchPnr: return "DELETE"
        default: return "GET"
        }
    }

    var url: URL? {
        URL(string: AppConfig.baseURL + path)
    }
}
