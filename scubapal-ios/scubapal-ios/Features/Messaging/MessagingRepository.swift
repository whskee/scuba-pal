import Foundation

protocol MessagingRepositoryProtocol: Sendable {
    func conversations() async throws -> [Conversation]
    func startConversation(userID: Int) async throws -> Conversation
    func messages(conversationID: Int) async throws -> [ChatMessage]
    func sendMessage(conversationID: Int, body: String) async throws
    func unreadCount() async throws -> Int
}

struct MessagingRepository: Sendable {
    let apiClient: APIClient
    let mapper: MessagingMapper

    func conversations() async throws -> [Conversation] {
        let endpoint = Endpoint(
            path: APIPath.messageConversations,
            query: PageRequest(size: 50).queryParameters
        )
        let response: ConversationListDTO = try await apiClient.request(endpoint)
        return try (response.conversations ?? []).map(mapper.map)
    }

    func startConversation(userID: Int) async throws -> Conversation {
        let endpoint = Endpoint(path: APIPath.messageConversation(userID: userID), method: .post)
        let response: ConversationDTO = try await apiClient.request(endpoint)
        return try mapper.map(response)
    }

    func messages(conversationID: Int) async throws -> [ChatMessage] {
        let endpoint = Endpoint(
            path: APIPath.messages(conversationID: conversationID),
            query: PageRequest(size: 80).queryParameters
        )
        let response: MessageListDTO = try await apiClient.request(endpoint)
        return try (response.messages ?? []).map(mapper.map)
    }

    func sendMessage(conversationID: Int, body: String) async throws {
        let endpoint = Endpoint(path: APIPath.messages(conversationID: conversationID), method: .post)
        try await apiClient.requestNoContent(
            endpoint,
            body: SendMessageRequest(messageText: body)
        )
    }

    func unreadCount() async throws -> Int {
        let response: UnreadMessageCountDTO = try await apiClient.request(
            Endpoint(path: APIPath.messageUnreadCount)
        )
        return response.unreadMessageCount ?? 0
    }
}

extension MessagingRepository: MessagingRepositoryProtocol {}
