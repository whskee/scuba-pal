import Foundation

struct CreatePostRequest: Codable {
    var caption: String
    var visibilityStatus: VisibilityStatus
    var mediaUrls: [String]
}

struct CreateCommentRequest: Codable {
    var commentText: String
}
