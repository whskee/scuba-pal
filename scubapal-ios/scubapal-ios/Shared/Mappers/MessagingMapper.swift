import Foundation

struct MessagingMapper: Sendable {
    let mediaURLResolver: MediaURLResolver

    func map(_ input: ConversationDTO) throws -> Conversation {
        Conversation(
            id: try RequiredField.value(input.conversationId, "conversationId"),
            participant: User(
                id: try RequiredField.value(input.otherUserId, "conversation.otherUserId"),
                username: try RequiredField.nonBlank(input.otherUsername, "conversation.otherUsername"),
                firstName: nil,
                lastName: nil,
                email: nil,
                city: nil,
                state: nil,
                country: nil,
                profileImageUrl: input.otherProfileImageUrl,
                bio: nil,
                diveCount: 0,
                followersCount: 0,
                followingCount: 0,
                followedByMe: false
            ),
            lastMessage: input.lastMessagePreview ?? "No messages yet",
            unreadCount: input.unreadCount ?? 0,
            updatedAt: try DateParsing.fromAPI(input.updatedAt, field: "conversation.updatedAt")
        )
    }

    func map(_ input: MessageDTO) throws -> ChatMessage {
        ChatMessage(
            id: try RequiredField.value(input.messageId, "messageId"),
            senderId: try RequiredField.value(input.senderUserId, "message.senderUserId"),
            senderProfileImageUrl: mediaURLResolver.resolve(input.senderProfileImageUrl),
            body: input.messageText ?? "",
            createdAt: try DateParsing.fromAPI(input.createdAt, field: "message.createdAt"),
            sentByCurrentUser: input.sentByCurrentUser ?? false
        )
    }
}
