import Foundation

struct AppEnvironment: Sendable {
    static let live = AppEnvironment()

    let authRepository: AuthRepository
    let feedRepository: FeedRepository
    let profileRepository: ProfileRepository
    let discoverRepository: DiscoverRepository
    let messagingRepository: MessagingRepository
    let notificationsRepository: NotificationsRepository

    init(config: AppConfig = .live(), tokenStore: any TokenStore = KeychainTokenStore()) {
        let apiClient = APIClient(config: config, tokenStore: tokenStore)
        let mediaURLResolver = MediaURLResolver(baseURL: config.baseURL)
        let userMapper = UserMapper()

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
}
