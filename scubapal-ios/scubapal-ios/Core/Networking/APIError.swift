import Foundation

enum APIError: LocalizedError, Equatable {
    case invalidBaseURL
    case loopbackBaseURLOnDevice
    case invalidResponse
    case unauthorized
    case server(message: String, status: Int)
    case decoding(String)
    case encoding(String)

    var errorDescription: String? {
        userMessage
    }

    var userMessage: String {
        switch self {
        case .invalidBaseURL:
            "ScubaPal is not configured with a valid API server."
        case .loopbackBaseURLOnDevice:
            "This iPhone cannot reach a server at localhost. Configure the Debug API URL with your Mac's .local hostname."
        case .invalidResponse:
            "The server returned an invalid response."
        case .unauthorized:
            "Your session expired. Log in again."
        case let .server(_, status):
            if status == 400 || status == 422 {
                "Check your entries and try again."
            } else if status == 403 {
                "You do not have permission to do that."
            } else if status == 404 {
                "We could not find that item."
            } else if status == 409 {
                "That change conflicts with the current server state."
            } else if status >= 500 {
                "ScubaPal is having trouble right now. Please try again soon."
            } else {
                "The request could not be completed."
            }
        case .decoding:
            "The server response could not be read."
        case .encoding:
            "The request could not be prepared."
        }
    }

    var diagnosticMessage: String {
        switch self {
        case .invalidBaseURL:
            "APIError.invalidBaseURL"
        case .loopbackBaseURLOnDevice:
            "APIError.loopbackBaseURLOnDevice"
        case .invalidResponse:
            "APIError.invalidResponse"
        case .unauthorized:
            "APIError.unauthorized"
        case let .server(message, status):
            "APIError.server(status: \(status), message: \(AppLogRedactor.redact(message)))"
        case let .decoding(message):
            "APIError.decoding(\(AppLogRedactor.redact(message)))"
        case let .encoding(message):
            "APIError.encoding(\(AppLogRedactor.redact(message)))"
        }
    }
}
