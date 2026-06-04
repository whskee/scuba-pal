import Foundation

struct NotificationsRepository: Sendable {
    let apiClient: APIClient
    let mapper: NotificationMapper

    func notifications() async throws -> [AppNotification] {
        let endpoint = Endpoint(
            path: "/api/notifications",
            query: ["page": "0", "size": "50"]
        )
        let response: NotificationListDTO = try await apiClient.request(endpoint)
        return try (response.notifications ?? []).map(mapper.map)
    }

    func unreadCount() async throws -> Int {
        let response: UnreadNotificationCountDTO = try await apiClient.request(
            Endpoint(path: "/api/notifications/unread-count")
        )
        return response.unreadNotificationCount ?? 0
    }

    func markRead(id: Int) async throws {
        try await apiClient.requestNoContent(
            Endpoint(path: "/api/notifications/\(id)/read", method: .post)
        )
    }
}
