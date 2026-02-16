import Foundation

enum AppConfig {
    #if targetEnvironment(simulator)
    static let baseURL = "http://localhost:3001/api/v1"
    #else
    static let baseURL = "http://192.168.1.6:3001/api/v1"
    #endif

    static let requestTimeout: TimeInterval = 30
    static let sseTimeout: TimeInterval = 300
    static let sseRetryDelay: TimeInterval = 3
    static let pollingInterval: TimeInterval = 30

    static let appGroupIdentifier = "group.com.rail.app"
}
