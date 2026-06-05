import Foundation

struct UpdateProfileRequest: Codable {
    var firstName: String?
    var lastName: String?
    var phoneNumber: String?
    var city: String?
    var state: String?
    var country: String?
    var bio: String?
    var diveCount: Int?
    var profileImageUrl: String?
    var visibilityStatus: VisibilityStatus = .publicStatus
}
