import Foundation

struct ConversationListDTO: Codable {
    var conversations: [ConversationDTO]?
    var page: PageMetaDTO?
}

struct ConversationDTO: Codable, Hashable {
    var conversationId: Int?
    var otherUserId: Int?
    var otherUsername: String?
    var otherInitial: String?
    var otherProfileImageUrl: String?
    var unreadCount: Int?
    var lastMessagePreview: String?
    var updatedAt: String?
}

struct MessageListDTO: Codable {
    var messages: [MessageDTO]?
    var page: PageMetaDTO?
}

struct MessageDTO: Codable, Hashable {
    var messageId: Int?
    var senderUserId: Int?
    var senderProfileImageUrl: String?
    var messageText: String?
    var createdAt: String?
    var readAt: String?
    var sentByCurrentUser: Bool?
}

struct UnreadMessageCountDTO: Codable {
    var unreadMessageCount: Int?
}
