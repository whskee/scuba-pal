import Foundation

struct AppDependencies: Sendable {
    static let live = AppDependencies()

    let authRepository: any AuthRepositoryProtocol
    let feedRepository: any FeedRepositoryProtocol
    let profileRepository: any ProfileRepositoryProtocol
    let discoverRepository: any DiscoverRepositoryProtocol
    let messagingRepository: any MessagingRepositoryProtocol
    let notificationsRepository: any NotificationsRepositoryProtocol

    init(config: AppConfig = .live(), tokenStore: any TokenStore = KeychainTokenStore()) {
        let apiClient = APIClient(config: config, tokenStore: tokenStore)
        let mediaURLResolver = MediaURLResolver(baseURL: config.baseURL)
        let userMapper = UserMapper(mediaURLResolver: mediaURLResolver)

        authRepository = AuthRepository(
            apiClient: apiClient,
            tokenStore: tokenStore,
            userMapper: userMapper
        )
        feedRepository = FeedRepository(
            apiClient: apiClient,
            mapper: PostMapper(mediaURLResolver: mediaURLResolver)
        )
        profileRepository = ProfileRepository(apiClient: apiClient, mapper: userMapper)
        discoverRepository = DiscoverRepository(
            apiClient: apiClient,
            mapper: DiscoveryMapper(mediaURLResolver: mediaURLResolver)
        )
        messagingRepository = MessagingRepository(
            apiClient: apiClient,
            mapper: MessagingMapper(mediaURLResolver: mediaURLResolver)
        )
        notificationsRepository = NotificationsRepository(
            apiClient: apiClient,
            mapper: NotificationMapper()
        )
    }

    init(
        authRepository: any AuthRepositoryProtocol,
        feedRepository: any FeedRepositoryProtocol,
        profileRepository: any ProfileRepositoryProtocol,
        discoverRepository: any DiscoverRepositoryProtocol,
        messagingRepository: any MessagingRepositoryProtocol,
        notificationsRepository: any NotificationsRepositoryProtocol
    ) {
        self.authRepository = authRepository
        self.feedRepository = feedRepository
        self.profileRepository = profileRepository
        self.discoverRepository = discoverRepository
        self.messagingRepository = messagingRepository
        self.notificationsRepository = notificationsRepository
    }
}

enum AppEnvironment {
    static let live = AppDependencies.live
    static let preview = AppDependencies.preview
}
