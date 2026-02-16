import Foundation

final class SSEClient<T: Decodable>: NSObject, URLSessionDataDelegate {
    private var task: URLSessionDataTask?
    private var continuation: AsyncStream<T>.Continuation?
    private var buffer = ""
    private let decoder = JSONDecoder()
    private var currentEndpoint: APIEndpoint?

    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = AppConfig.sseTimeout
        config.timeoutIntervalForResource = .infinity
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()

    func connect(to endpoint: APIEndpoint) -> AsyncStream<T> {
        disconnect()
        currentEndpoint = endpoint

        return AsyncStream { continuation in
            self.continuation = continuation

            guard let url = endpoint.url else {
                continuation.finish()
                return
            }

            var request = URLRequest(url: url)
            request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
            request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")

            self.task = self.session.dataTask(with: request)
            self.task?.resume()

            continuation.onTermination = { @Sendable _ in
                self.task?.cancel()
            }
        }
    }

    func disconnect() {
        task?.cancel()
        task = nil
        continuation?.finish()
        continuation = nil
        buffer = ""
        currentEndpoint = nil
    }

    // MARK: - URLSessionDataDelegate

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let text = String(data: data, encoding: .utf8) else { return }
        buffer += text

        while let lineEnd = buffer.firstIndex(of: "\n") {
            let line = String(buffer[buffer.startIndex..<lineEnd])
            buffer = String(buffer[buffer.index(after: lineEnd)...])

            if line.hasPrefix("data:") {
                let jsonString = String(line.dropFirst(5)).trimmingCharacters(in: .whitespaces)
                guard !jsonString.isEmpty else { continue }

                if let jsonData = jsonString.data(using: .utf8),
                   let value = try? decoder.decode(T.self, from: jsonData) {
                    continuation?.yield(value)
                }
            }
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error, (error as NSError).code != NSURLErrorCancelled {
            let endpoint = self.currentEndpoint
            Task {
                try? await Task.sleep(for: .seconds(AppConfig.sseRetryDelay))
                if let endpoint {
                    _ = self.connect(to: endpoint)
                }
            }
        }
        continuation?.finish()
    }
}
