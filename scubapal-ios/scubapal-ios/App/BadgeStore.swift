import Combine

@MainActor
final class BadgeStore: ObservableObject {
    @Published private(set) var unreadMessages = 0
    @Published private(set) var unreadNotifications = 0

    private let messagingRepository: MessagingRepository
    private let notificationsRepository: NotificationsRepository

    init(
        messagingRepository: MessagingRepository,
        notificationsRepository: NotificationsRepository
    ) {
        self.messagingRepository = messagingRepository
        self.notificationsRepository = notificationsRepository
    }

    func refresh() async {
        async let messages = try? messagingRepository.unreadCount()
        async let notifications = try? notificationsRepository.unreadCount()
        unreadMessages = await messages ?? unreadMessages
        unreadNotifications = await notifications ?? unreadNotifications
    }

    func reset() {
        unreadMessages = 0
        unreadNotifications = 0
    }
}
