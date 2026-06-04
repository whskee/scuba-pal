import Foundation

enum APIError: LocalizedError, Equatable {
    case invalidBaseURL
    case invalidResponse
    case unauthorized
    case server(message: String, status: Int)
    case decoding(String)
    case encoding(String)

    var errorDescription: String? {
        switch self {
        case .invalidBaseURL:
            "The API base URL is invalid."
        case .invalidResponse:
            "The server returned an invalid response."
        case .unauthorized:
            "Your session expired. Log in again."
        case let .server(message, _):
            message
        case let .decoding(message), let .encoding(message):
            message
        }
    }
}
