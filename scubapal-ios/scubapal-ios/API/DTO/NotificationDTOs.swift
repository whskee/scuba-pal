import Foundation

struct NotificationListDTO: Codable {
    var notifications: [NotificationDTO]?
    var page: PageMetaDTO?
}

struct NotificationDTO: Codable, Hashable {
    var notificationId: Int?
    var title: String?
    var message: String?
    var read: Bool?
    var createdAt: String?
    // TODO: Type this when NotificationView includes a documented backend enum.
    var type: String?
}

struct UnreadNotificationCountDTO: Codable {
    var unreadNotificationCount: Int?
}
