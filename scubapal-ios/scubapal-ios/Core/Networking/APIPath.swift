enum APIPath {
    static let currentUser = "/api/me"
    static let currentUserProfile = "/api/me/profile"

    static let login = "/api/auth/login"
    static let logout = "/api/auth/logout"
    static let refreshToken = "/api/auth/refresh"
    static let register = "/api/auth/register"

    static let learnArticles = "/api/learn/articles"
    static let locations = "/api/locations"
    static let notifications = "/api/notifications"
    static let posts = "/api/posts"
    static let profiles = "/api/profiles"
    static let shops = "/api/shops"

    static let messageConversations = "/api/messages/conversations"
    static let messageUnreadCount = "/api/messages/unread-count"
    static let notificationUnreadCount = "/api/notifications/unread-count"

    static func messageConversation(userID: Int) -> String {
        "/api/messages/conversations/\(userID)"
    }

    static func messages(conversationID: Int) -> String {
        "/api/messages/\(conversationID)"
    }

    static func notificationRead(id: Int) -> String {
        "/api/notifications/\(id)/read"
    }

    static func post(id: Int) -> String {
        "/api/posts/\(id)"
    }

    static func postComments(postID: Int) -> String {
        "/api/posts/\(postID)/comments"
    }

    static func postLike(postID: Int) -> String {
        "/api/posts/\(postID)/like"
    }

    static let currentUserPosts = "/api/posts/me"

    static func userFollow(userID: Int) -> String {
        "/api/users/\(userID)/follow"
    }

    static func userFollowSummary(userID: Int) -> String {
        "/api/users/\(userID)/follow-summary"
    }

    static func userProfile(userID: Int) -> String {
        "/api/users/\(userID)/profile"
    }
}

struct PageRequest: Equatable, Sendable {
    let page: Int
    let size: Int

    init(page: Int = 0, size: Int) {
        self.page = page
        self.size = size
    }

    var queryParameters: [String: String] {
        [
            "page": "\(page)",
            "size": "\(size)"
        ]
    }

    func queryParameters(adding parameters: [String: String]) -> [String: String] {
        queryParameters.merging(parameters) { _, new in new }
    }
}
