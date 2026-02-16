import Foundation

struct APIResponse<T: Decodable>: Decodable {
    let success: Bool
    let data: T
    let message: String?
    let timestamp: String?
}

struct APIError: Decodable {
    let success: Bool
    let error: String
    let statusCode: Int
    let timestamp: String?
}
