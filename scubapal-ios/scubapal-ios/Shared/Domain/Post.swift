import Foundation

struct Post: Identifiable, Hashable {
    var id: Int
    var author: User
    var content: String
    var visibilityStatus: VisibilityStatus?
    var imageUrl: URL?
    var mediaUrls: [URL]
    var createdAt: Date
    var likeCount: Int
    var commentCount: Int
    var likedByMe: Bool
    var comments: [Comment]
}

struct Comment: Identifiable, Hashable {
    var id: Int
    var userId: Int
    var username: String
    var body: String
    var createdAt: Date
}
