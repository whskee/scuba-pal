import Foundation
import OSLog

enum AppLogger {
    static let networking = Logger(subsystem: subsystem, category: "networking")
    static let auth = Logger(subsystem: subsystem, category: "auth")
    static let repository = Logger(subsystem: subsystem, category: "repository")
    static let ui = Logger(subsystem: subsystem, category: "ui")

    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.scubapal.ios"

    static func log(_ error: any Error, category logger: Logger, context: String) {
        let diagnostic = AppLogRedactor.redact(error.diagnosticDescription)
        logger.error("\(context, privacy: .public): \(diagnostic, privacy: .public)")
    }
}

enum AppLogRedactor {
    private static let redacted = "<redacted>"

    static func redact(_ value: String) -> String {
        var output = value
        output = output.replacingOccurrences(
            of: #"(?i)bearer\s+[A-Za-z0-9._~+/=-]+"#,
            with: "Bearer \(redacted)",
            options: .regularExpression
        )
        output = output.replacingOccurrences(
            of: #"(?i)(accessToken|refreshToken|authorization|password|token|secret)\s*[:=]\s*["']?[^"',\s}]+"#,
            with: "$1=\(redacted)",
            options: .regularExpression
        )
        return output
    }
}
