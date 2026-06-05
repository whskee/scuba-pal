import Foundation

extension Error {
    var userFacingMessage: String {
        if let apiError = self as? APIError {
            return apiError.userMessage
        }

        if let urlError = self as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost, .timedOut, .cannotFindHost, .cannotConnectToHost:
                return "Check your connection and try again."
            default:
                return "The network request could not be completed."
            }
        }

        if self is MappingError {
            return "The server response could not be read."
        }

        if self is TokenStoreError {
            return "Your saved session could not be restored. Log in again."
        }

        return "Something went wrong. Please try again."
    }

    var diagnosticDescription: String {
        if let apiError = self as? APIError {
            return apiError.diagnosticMessage
        }

        if let localizedError = self as? LocalizedError, let description = localizedError.errorDescription {
            return "\(type(of: self)): \(description)"
        }

        return "\(type(of: self)): \(localizedDescription)"
    }
}
