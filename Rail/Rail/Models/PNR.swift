import Foundation
import SwiftUI

struct PNRStatus: Codable, Identifiable, Hashable {
    var id: String { pnr }

    let pnr: String
    let trainNumber: String
    let trainName: String
    let from: String
    let to: String
    let travelDate: String
    let bookingStatus: String
    let currentStatus: String
    let passengers: [PNRPassenger]
    let lastUpdated: String
}

struct PNRPassenger: Codable, Identifiable, Hashable {
    var id: Int { number }

    let number: Int
    let bookingStatus: String
    let currentStatus: String
    let coach: String
    let berth: String

    var statusColor: Color {
        let status = currentStatus.uppercased()
        if status.contains("CNF") || status.contains("CONFIRM") {
            return .railGreen
        } else if status.contains("WL") || status.contains("WAITLIST") {
            return .railRed
        } else if status.contains("RAC") {
            return .railYellow
        }
        return .textSecondary
    }

    var displayStatus: String {
        if !coach.isEmpty && !berth.isEmpty {
            return "\(coach) / \(berth)"
        }
        return currentStatus
    }
}
