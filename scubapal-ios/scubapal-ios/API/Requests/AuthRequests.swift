import Foundation

struct LoginRequest: Codable {
    var username: String
    var password: String
}

struct RegisterRequest: Codable {
    var email: String
    var username: String
    var password: String
    var firstName: String?
    var lastName: String?
}

struct RefreshTokenRequest: Codable {
    var refreshToken: String
}
