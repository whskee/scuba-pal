import Foundation

struct CurrentUserDTO: Codable, Hashable {
    var id: Int?
    var username: String?
    var firstName: String?
    var lastName: String?
    var email: String?
    var role: UserRole?
    var city: String?
    var country: String?
    var diveCount: Int?
    var bio: String?
    var profileImageUrl: String?
}

struct AuthResponse: Codable {
    var accessToken: String?
    var refreshToken: String?
    var tokenType: String?
    var expiresAt: String?
    var user: CurrentUserDTO?
}
