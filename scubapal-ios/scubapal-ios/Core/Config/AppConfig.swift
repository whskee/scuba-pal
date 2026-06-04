import Foundation

struct AppConfig: Sendable {
    static let requestTimeout: TimeInterval = 24

    let baseURL: URL

    static func live(
        bundle: Bundle = .main,
        processInfo: ProcessInfo = .processInfo
    ) -> AppConfig {
        let configuredValue = processInfo.environment["SCUBAPAL_API_BASE_URL"]
            ?? bundle.object(forInfoDictionaryKey: "SCUBAPAL_API_BASE_URL") as? String

        guard
            let value = configuredValue?.trimmingCharacters(in: .whitespacesAndNewlines),
            !value.isEmpty,
            let url = URL(string: value),
            let scheme = url.scheme,
            ["http", "https"].contains(scheme.lowercased())
        else {
            preconditionFailure("SCUBAPAL_API_BASE_URL must be configured as a valid HTTP(S) URL.")
        }

        return AppConfig(baseURL: url)
    }
}
