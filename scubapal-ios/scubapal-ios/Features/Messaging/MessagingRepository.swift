import Foundation

struct MessagingRepository: Sendable {
    let apiClient: APIClient
    let mapper: MessagingMapper

    func conversations() async throws -> [Conversation] {
        let endpoint = Endpoint(
            path: "/api/messages/conversations",
            query: ["page": "0", "size": "50"]
        )
        let response: ConversationListDTO = try await apiClient.request(endpoint)
        return try (response.conversations ?? []).map(mapper.map)
    }

    func startConversation(userID: Int) async throws -> Conversation {
        let endpoint = Endpoint(path: "/api/messages/conversations/\(userID)", method: .post)
        let response: ConversationDTO = try await apiClient.request(endpoint)
        return try mapper.map(response)
    }

    func messages(conversationID: Int) async throws -> [ChatMessage] {
        let endpoint = Endpoint(
            path: "/api/messages/\(conversationID)",
            query: ["page": "0", "size": "80"]
        )
        let response: MessageListDTO = try await apiClient.request(endpoint)
        return try (response.messages ?? []).map(mapper.map)
    }

    func sendMessage(conversationID: Int, body: String) async throws {
        let endpoint = Endpoint(path: "/api/messages/\(conversationID)", method: .post)
        try await apiClient.requestNoContent(
            endpoint,
            body: SendMessageRequest(messageText: body)
        )
    }

    func unreadCount() async throws -> Int {
        let response: UnreadMessageCountDTO = try await apiClient.request(
            Endpoint(path: "/api/messages/unread-count")
        )
        return response.unreadMessageCount ?? 0
    }
}
