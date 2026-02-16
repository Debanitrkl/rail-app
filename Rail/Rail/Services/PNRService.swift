import Foundation

enum PNRService {
    static func getPNRStatus(_ pnrNumber: String) async throws -> PNRStatus {
        try await APIClient.shared.request(.pnrStatus(number: pnrNumber))
    }

    static func getWatchedPNRs() async throws -> [WatchedPNR] {
        try await APIClient.shared.request(.watchedPnrs)
    }

    static func watchPNR(pnr: String, trainNumber: String? = nil, travelDate: String? = nil) async throws -> WatchedPNR {
        let body = WatchPNRRequest(pnr: pnr, trainNumber: trainNumber, travelDate: travelDate)
        return try await APIClient.shared.request(.watchPnr, body: body)
    }

    static func unwatchPNR(_ pnrNumber: String) async throws {
        let _: EmptyPNRData = try await APIClient.shared.request(.unwatchPnr(number: pnrNumber))
    }
}

struct WatchPNRRequest: Encodable {
    let pnr: String
    let trainNumber: String?
    let travelDate: String?
}

struct WatchedPNR: Codable, Identifiable, Hashable {
    let id: Int
    let pnr: String
    let trainNumber: String
    let travelDate: String
    let lastStatus: [String: AnyCodable]?
    let lastCheckedAt: String
    let createdAt: String

    static func == (lhs: WatchedPNR, rhs: WatchedPNR) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct AnyCodable: Codable, Hashable {
    let value: Any

    init(_ value: Any) { self.value = value }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let str = try? container.decode(String.self) { value = str }
        else if let int = try? container.decode(Int.self) { value = int }
        else if let double = try? container.decode(Double.self) { value = double }
        else if let bool = try? container.decode(Bool.self) { value = bool }
        else { value = "" }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let str = value as? String { try container.encode(str) }
        else if let int = value as? Int { try container.encode(int) }
        else if let double = value as? Double { try container.encode(double) }
        else if let bool = value as? Bool { try container.encode(bool) }
    }

    static func == (lhs: AnyCodable, rhs: AnyCodable) -> Bool {
        String(describing: lhs.value) == String(describing: rhs.value)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(String(describing: value))
    }
}

private struct EmptyPNRData: Decodable {}
