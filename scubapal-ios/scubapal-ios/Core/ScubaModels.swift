import Foundation

struct PageMetaResponse: Codable {
    var page: Int?
    var size: Int?
    var totalElements: Int?
    var totalPages: Int?
    var hasNext: Bool?
}

struct PageResponse<T: Codable>: Codable {
    var content: [T]?
    var meta: PageMetaResponse?
}

struct CurrentUserView: Codable, Identifiable, Hashable {
    var id: Int?
    var username: String?
    var firstName: String?
    var lastName: String?
    var email: String?
    var role: String?
    var city: String?
    var country: String?
    var diveCount: Int?
    var bio: String?
    var profileImageUrl: String?
}

struct PublicUserView: Codable, Identifiable, Hashable {
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

struct ProfileResponse: Codable, Hashable {
    var profileId: Int?
    var userId: Int?
    var username: String?
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

struct PublicProfileResponse: Codable, Hashable {
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

struct AuthResponse: Codable {
    var accessToken: String?
    var refreshToken: String?
    var tokenType: String?
    var expiresAt: String?
    var user: CurrentUserView?
}

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

struct CreateCurrentUserPostRequest: Codable {
    var caption: String
    var visibilityStatus: String
    var mediaUrls: [String]
}

struct CreateCommentRequest: Codable {
    var commentText: String
}

struct UpsertProfileRequest: Codable {
    var firstName: String?
    var lastName: String?
    var phoneNumber: String?
    var city: String?
    var state: String?
    var country: String?
    var bio: String?
    var diveCount: Int?
    var profileImageUrl: String?
    var visibilityStatus: String = "PUBLIC"
}

struct SendMessageRequest: Codable {
    var messageText: String
}

struct FeedPostView: Codable, Identifiable, Hashable {
    var postId: Int?
    var userId: Int?
    var username: String?
    var authorProfileImageUrl: String?
    var caption: String?
    var visibilityStatus: String?
    var imageUrl: String?
    var mediaUrls: [String]?
    var likes: Int?
    var comments: Int?
    var likedByCurrentUser: Bool?
    var createdAt: String?

    var id: Int { postId ?? 0 }
}

struct CommentView: Codable, Identifiable, Hashable {
    var commentId: Int?
    var userId: Int?
    var username: String?
    var authorProfileImageUrl: String?
    var commentText: String?
    var createdAt: String?

    var id: Int { commentId ?? 0 }
}

struct PostDetailDTO: Codable, Identifiable, Hashable {
    var postId: Int?
    var userId: Int?
    var username: String?
    var authorProfileImageUrl: String?
    var caption: String?
    var imageUrl: String?
    var mediaUrls: [String]?
    var likes: Int?
    var comments: Int?
    var likedByCurrentUser: Bool?
    var createdAt: String?
    var commentList: [CommentView]?

    var id: Int { postId ?? 0 }
}

struct DiveLocationResponse: Codable, Identifiable, Hashable {
    var locationId: Int?
    var locationName: String?
    var description: String?
    var imageUrl: String?
    var city: String?
    var state: String?
    var country: String?
    var latitude: Double?
    var longitude: Double?
    var difficultyLevel: String?
    var popularityScore: Double?

    var id: Int { locationId ?? 0 }
}

struct DiveShopResponse: Codable, Identifiable, Hashable {
    var shopId: Int?
    var shopName: String?
    var description: String?
    var phoneNumber: String?
    var email: String?
    var websiteUrl: String?
    var imageUrl: String?
    var streetAddress: String?
    var city: String?
    var state: String?
    var country: String?
    var latitude: Double?
    var longitude: Double?
    var locationId: Int?
    var locationName: String?

    var id: Int { shopId ?? 0 }
}

struct ConversationListResponse: Codable {
    var conversations: [ConversationView]?
    var page: PageMetaResponse?
}

struct ConversationView: Codable, Identifiable, Hashable {
    var conversationId: Int?
    var otherUserId: Int?
    var otherUsername: String?
    var otherInitial: String?
    var otherProfileImageUrl: String?
    var unreadCount: Int?
    var lastMessagePreview: String?
    var updatedAt: String?

    var id: Int { conversationId ?? 0 }
}

struct MessageListResponse: Codable {
    var messages: [MessageView]?
    var page: PageMetaResponse?
}

struct MessageView: Codable, Identifiable, Hashable {
    var messageId: Int?
    var senderUserId: Int?
    var senderProfileImageUrl: String?
    var messageText: String?
    var createdAt: String?
    var readAt: String?
    var sentByCurrentUser: Bool?

    var id: Int { messageId ?? abs("\(senderUserId ?? 0)-\(createdAt ?? "")".hashValue) }
}

struct UnreadCountView: Codable {
    var unreadMessageCount: Int?
}

struct UnreadNotificationCountView: Codable {
    var unreadNotificationCount: Int?
}

struct NotificationListResponse: Codable {
    var notifications: [NotificationView]?
    var page: PageMetaResponse?
}

struct NotificationView: Codable, Identifiable, Hashable {
    var notificationId: Int?
    var title: String?
    var message: String?
    var read: Bool?
    var createdAt: String?
    var type: String?

    var id: Int { notificationId ?? 0 }
}

struct LearnArticleResponse: Codable, Identifiable, Hashable {
    var articleId: Int?
    var slug: String?
    var title: String?
    var summary: String?
    var content: String?
    var category: String?
    var difficultyLevel: String?
    var estimatedMinutes: Int?
    var updatedAt: String?

    var id: Int { articleId ?? abs((slug ?? "lesson").hashValue) }
}

struct FollowSummaryView: Codable, Hashable {
    var followingCount: Int?
    var followerCount: Int?
    var followedByCurrentUser: Bool?
    var following: [PublicUserView]?
    var followers: [PublicUserView]?
}

struct ApiErrorBody: Codable {
    var message: String?
    var error: String?
    var detail: String?
    var status: Int?
}

struct User: Identifiable, Hashable {
    var id: Int
    var username: String
    var firstName: String?
    var lastName: String?
    var email: String?
    var city: String?
    var state: String?
    var country: String?
    var profileImageUrl: String?
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

struct Post: Identifiable, Hashable {
    var id: Int
    var author: User
    var content: String
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

struct DiveLocation: Identifiable, Hashable {
    var id: Int
    var name: String
    var description: String?
    var imageUrl: URL?
    var city: String?
    var state: String?
    var country: String?
    var latitude: Double?
    var longitude: Double?
    var difficultyLevel: String?
    var popularityScore: Double?
}

struct DiveShop: Identifiable, Hashable {
    var id: Int
    var name: String
    var description: String?
    var imageUrl: URL?
    var phoneNumber: String?
    var email: String?
    var websiteUrl: String?
    var streetAddress: String?
    var city: String?
    var state: String?
    var country: String?
    var locationName: String?
}

struct Conversation: Identifiable, Hashable {
    var id: Int
    var participant: User
    var lastMessage: String
    var unreadCount: Int
    var updatedAt: Date
}

struct ChatMessage: Identifiable, Hashable {
    var id: Int
    var senderId: Int
    var senderProfileImageUrl: URL?
    var body: String
    var createdAt: Date
    var sentByCurrentUser: Bool
}

struct AppNotification: Identifiable, Hashable {
    var id: Int
    var title: String
    var body: String
    var read: Bool
    var createdAt: Date
    var type: String?
}

struct LearnArticle: Identifiable, Hashable {
    var id: Int
    var slug: String
    var title: String
    var summary: String
    var content: String
    var category: String
    var difficultyLevel: String
    var estimatedMinutes: Int
    var updatedAt: Date
}

extension Date {
    static func fromAPI(_ value: String?) -> Date {
        guard let value, !value.isEmpty else { return Date() }
        if let parsed = ISO8601DateFormatter.api.date(from: value) { return parsed }
        if let parsed = ISO8601DateFormatter.fractionalAPI.date(from: value) { return parsed }
        return Date()
    }
}

extension ISO8601DateFormatter {
    static let api: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
        return formatter
    }()

    static let fractionalAPI: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
}
