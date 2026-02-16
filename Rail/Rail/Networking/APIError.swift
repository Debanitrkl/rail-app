import Foundation

enum RailAPIError: LocalizedError {
    case invalidURL
    case networkError(Error)
    case httpError(Int, String?)
    case decodingError(Error)
    case noData
    case serverError(String)
    case timeout

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .httpError(let code, let message):
            return message ?? "HTTP error \(code)"
        case .decodingError(let error):
            return "Data error: \(error.localizedDescription)"
        case .noData:
            return "No data received"
        case .serverError(let message):
            return message
        case .timeout:
            return "Request timed out"
        }
    }
}
