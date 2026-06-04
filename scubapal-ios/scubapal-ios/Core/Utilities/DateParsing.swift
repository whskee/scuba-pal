import Foundation

enum DateParsing {
    static func fromAPI(_ value: String?, field: String) throws -> Date {
        guard let value, !value.isEmpty else {
            throw MappingError.missingRequiredField(field)
        }
        if let parsed = ISO8601DateFormatter.api.date(from: value) { return parsed }
        if let parsed = ISO8601DateFormatter.fractionalAPI.date(from: value) { return parsed }
        throw MappingError.invalidValue(field: field, value: value)
    }
}

private extension ISO8601DateFormatter {
    static let api: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
        return formatter
    }()

    static let fractionalAPI: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
}
