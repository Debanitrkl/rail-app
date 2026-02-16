import Foundation

enum PersistenceService {
    private static let defaults = UserDefaults.standard

    private enum Keys {
        static let recentSearches = "rail.recentSearches"
        static let lastViewedTrain = "rail.lastViewedTrain"
        static let lastViewedStation = "rail.lastViewedStation"
    }

    // MARK: - Recent Searches

    static func getRecentSearches() -> [RecentSearch] {
        guard let data = defaults.data(forKey: Keys.recentSearches),
              let searches = try? JSONDecoder().decode([RecentSearch].self, from: data) else {
            return []
        }
        return searches
    }

    static func addRecentSearch(_ search: RecentSearch) {
        var searches = getRecentSearches()
        searches.removeAll { $0.query == search.query && $0.type == search.type }
        searches.insert(search, at: 0)
        if searches.count > 20 { searches = Array(searches.prefix(20)) }
        if let data = try? JSONEncoder().encode(searches) {
            defaults.set(data, forKey: Keys.recentSearches)
        }
    }

    static func clearRecentSearches() {
        defaults.removeObject(forKey: Keys.recentSearches)
    }

    // MARK: - Last Viewed

    static var lastViewedTrainNumber: String? {
        get { defaults.string(forKey: Keys.lastViewedTrain) }
        set { defaults.set(newValue, forKey: Keys.lastViewedTrain) }
    }

    static var lastViewedStationCode: String? {
        get { defaults.string(forKey: Keys.lastViewedStation) }
        set { defaults.set(newValue, forKey: Keys.lastViewedStation) }
    }
}

struct RecentSearch: Codable, Identifiable, Hashable {
    var id: String { "\(type)-\(query)" }
    let query: String
    let displayTitle: String
    let displaySubtitle: String
    let type: SearchType
    let timestamp: Date

    enum SearchType: String, Codable {
        case train
        case station
        case pnr
    }
}
