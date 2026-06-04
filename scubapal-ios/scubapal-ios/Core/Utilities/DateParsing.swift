import Foundation

enum DateParsing {
    static func fromAPI(_ value: String?, field: String) throws -> Date {
        guard let value = value?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty else {
            throw MappingError.missingRequiredField(field)
        }
        if let parsed = ISO8601DateFormatter.api.date(from: value) { return parsed }
        if let parsed = ISO8601DateFormatter.fractionalAPI.date(from: value) { return parsed }
        if let parsed = parseUTCLocalFractional(value) { return parsed }
        if let parsed = DateFormatter.utcLocalDateTime.date(from: value) { return parsed }
        throw MappingError.invalidValue(field: field, value: value)
    }

    private static func parseUTCLocalFractional(_ value: String) -> Date? {
        let parts = value.split(separator: ".", maxSplits: 1, omittingEmptySubsequences: false)
        guard
            parts.count == 2,
            !parts[1].isEmpty,
            parts[1].allSatisfy(\.isNumber),
            let base = DateFormatter.utcLocalDateTime.date(from: String(parts[0]))
        else {
            return nil
        }

        let fraction = String(parts[1])
        guard let fractionalSeconds = Double("0.\(fraction)") else { return nil }
        return base.addingTimeInterval(fractionalSeconds)
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

private extension DateFormatter {
    static let utcLocalDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.isLenient = false
        return formatter
    }()

}
