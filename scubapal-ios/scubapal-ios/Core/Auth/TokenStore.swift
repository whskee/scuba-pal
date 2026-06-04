import Foundation

struct TokenPair: Codable, Equatable, Sendable {
    var accessToken: String
    var refreshToken: String
}

protocol TokenStore: Sendable {
    func load() throws -> TokenPair?
    func save(_ tokenPair: TokenPair) throws
    func delete() throws
}
