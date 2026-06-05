import Foundation

struct PublicUserDTO: Codable, Hashable {
    var id: Int?
    var username: String?
    var firstName: String?
    var lastName: String?
    var city: String?
    var country: String?
    var diveCount: Int?
    var bio: String?
    var profileImageUrl: String?
}

struct ProfileDTO: Codable, Hashable {
    var profileId: Int?
    var userId: Int?
    var username: String?
    var firstName: String?
    var lastName: String?
    var phoneNumber: String?
    var city: String?
    var state: String?
    var country: String?
    var visibilityStatus: VisibilityStatus?
    var bio: String?
    var diveCount: Int?
    var profileImageUrl: String?
}

struct PublicProfileDTO: Codable, Hashable {
    var userId: Int?
    var username: String?
    var firstName: String?
    var lastName: String?
    var city: String?
    var country: String?
    var bio: String?
    var diveCount: Int?
    var profileImageUrl: String?
}

struct FollowSummaryDTO: Codable, Hashable {
    var followingCount: Int?
    var followerCount: Int?
    var followedByCurrentUser: Bool?
    var following: [PublicUserDTO]?
    var followers: [PublicUserDTO]?
}
