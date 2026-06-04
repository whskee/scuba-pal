import Foundation

enum MappingError: LocalizedError, Equatable {
    case missingRequiredField(String)
    case invalidValue(field: String, value: String)

    var errorDescription: String? {
        switch self {
        case let .missingRequiredField(field):
            "The server response is missing required field '\(field)'."
        case let .invalidValue(field, value):
            "The server returned an invalid value for '\(field)': \(value)."
        }
    }
}

enum RequiredField {
    static func value<T>(_ value: T?, _ field: String) throws -> T {
        guard let value else { throw MappingError.missingRequiredField(field) }
        return value
    }

    static func nonBlank(_ value: String?, _ field: String) throws -> String {
        guard let value = value?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty else {
            throw MappingError.missingRequiredField(field)
        }
        return value
    }
}
