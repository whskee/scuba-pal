import Foundation

struct MediaURLResolver: Sendable {
    let baseURL: URL

    func resolve(_ value: String?) -> URL? {
        guard let value = value?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty else {
            return nil
        }
        if let url = URL(string: value), url.scheme != nil { return url }
        let base = baseURL.absoluteString.hasSuffix("/") ? baseURL : baseURL.appendingPathComponent("")
        return URL(string: value, relativeTo: base)?.absoluteURL
    }
}
