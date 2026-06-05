import Foundation

struct CreatePostRequest: Codable {
    var caption: String
    var visibilityStatus: VisibilityStatus
    var mediaUrls: [String]
}

struct CreateCommentRequest: Codable {
    var commentText: String
}

struct FeedPostDTO: Codable, Hashable {
    var postId: Int?
    var userId: Int?
    var username: String?
    var authorProfileImageUrl: String?
    var caption: String?
    var visibilityStatus: VisibilityStatus?
    var imageUrl: String?
    var mediaUrls: [String]?
    var likes: Int?
    var comments: Int?
    var likedByCurrentUser: Bool?
    var createdAt: String?
}

struct CommentDTO: Codable, Hashable {
    var commentId: Int?
    var userId: Int?
    var username: String?
    var authorProfileImageUrl: String?
    var commentText: String?
    var createdAt: String?
}

struct PostDetailDTO: Codable, Hashable {
    var postId: Int?
    var userId: Int?
    var username: String?
    var authorProfileImageUrl: String?
    var caption: String?
    var visibilityStatus: VisibilityStatus?
    var imageUrl: String?
    var mediaUrls: [String]?
    var likes: Int?
    var comments: Int?
    var likedByCurrentUser: Bool?
    var createdAt: String?
    var commentList: [CommentDTO]?
}
