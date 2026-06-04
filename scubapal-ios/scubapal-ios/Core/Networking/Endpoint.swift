import Foundation

enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

struct Endpoint: Sendable {
    let path: String
    var method: HTTPMethod = .get
    var query: [String: String] = [:]
    var requiresAuth = true
}
