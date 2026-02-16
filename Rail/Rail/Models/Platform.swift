import Foundation

struct PlatformStatus: Codable, Identifiable, Hashable {
    var id: Int { platformNumber }

    let platformNumber: Int
    let currentTrain: String?
    let nextTrain: String?
    let status: PlatformState

    var isOccupied: Bool {
        status == .occupied
    }
}

enum PlatformState: String, Codable, Hashable {
    case occupied
    case available
    case reserved
}
