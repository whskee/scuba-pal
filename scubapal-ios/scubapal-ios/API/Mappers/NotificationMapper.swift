import Foundation

struct NotificationMapper: Sendable {
    func map(_ input: NotificationDTO) throws -> AppNotification {
        AppNotification(
            id: try RequiredField.value(input.notificationId, "notificationId"),
            title: input.title ?? "Notification",
            body: input.message ?? "",
            read: input.read ?? false,
            createdAt: try DateParsing.fromAPI(input.createdAt, field: "notification.createdAt"),
            type: input.type
        )
    }
}
