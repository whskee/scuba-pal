import Foundation

struct User: Identifiable, Hashable {
    var id: Int
    var username: String
    var firstName: String?
    var lastName: String?
    var email: String?
    var role: UserRole? = nil
    var city: String?
    var state: String?
    var country: String?
    var profileImageUrl: String?
    var profileImageURL: URL?
    var visibilityStatus: VisibilityStatus? = nil
    var bio: String?
    var diveCount: Int
    var followersCount: Int
    var followingCount: Int
    var followedByMe: Bool

    var displayName: String {
        let fullName = [firstName, lastName]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        return fullName.isEmpty ? "@\(username)" : fullName
    }
}

struct ProfileUpdate: Equatable {
    var firstName: String?
    var lastName: String?
    var phoneNumber: String?
    var city: String?
    var state: String?
    var country: String?
    var bio: String?
    var diveCount: Int?
    var profileImageUrl: String?
}

struct FollowSummary: Equatable {
    var followingCount: Int
    var followerCount: Int
    var followedByCurrentUser: Bool
}
