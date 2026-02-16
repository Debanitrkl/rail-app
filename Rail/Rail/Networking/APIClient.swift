import Foundation

actor APIClient {
    static let shared = APIClient()

    private let session: URLSession
    private let decoder: JSONDecoder

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = AppConfig.requestTimeout
        config.timeoutIntervalForResource = AppConfig.requestTimeout * 2
        self.session = URLSession(configuration: config)

        self.decoder = JSONDecoder()
    }

    func request<T: Decodable>(
        _ endpoint: APIEndpoint,
        body: Encodable? = nil
    ) async throws -> T {
        guard let url = endpoint.url else {
            throw RailAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method

        if let body {
            request.httpBody = try JSONEncoder().encode(body)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: request)
        } catch let error as URLError where error.code == .timedOut {
            throw RailAPIError.timeout
        } catch {
            throw RailAPIError.networkError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw RailAPIError.noData
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let errorBody = try? decoder.decode(APIError.self, from: data)
            throw RailAPIError.httpError(httpResponse.statusCode, errorBody?.error)
        }

        do {
            let apiResponse = try decoder.decode(APIResponse<T>.self, from: data)
            return apiResponse.data
        } catch {
            throw RailAPIError.decodingError(error)
        }
    }

    func requestRaw(_ endpoint: APIEndpoint) async throws -> Data {
        guard let url = endpoint.url else {
            throw RailAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw RailAPIError.noData
        }

        return data
    }
}
