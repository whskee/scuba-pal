import Foundation

struct MediaURLResolver: Sendable {
    let baseURL: URL

    func resolve(_ value: String?) -> URL? {
        guard let value = value?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty else {
            return nil
        }
        if let url = URL(string: value), url.scheme != nil { return url }
        return baseURL.appendingPathComponent(value.trimmingCharacters(in: CharacterSet(charactersIn: "/")))
    }
}
