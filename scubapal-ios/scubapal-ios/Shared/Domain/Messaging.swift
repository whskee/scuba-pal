import Foundation

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
