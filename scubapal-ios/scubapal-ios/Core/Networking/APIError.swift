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
        switch self {
        case .invalidBaseURL:
            "The API base URL is invalid."
        case .loopbackBaseURLOnDevice:
            "This iPhone cannot reach a server at localhost. Configure the Debug API URL with your Mac's .local hostname."
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
