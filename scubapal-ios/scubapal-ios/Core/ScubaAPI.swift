import Foundation
import Security

enum APIError: LocalizedError, Equatable {
    case invalidBaseURL
    case invalidResponse
    case unauthorized
    case server(message: String, status: Int)
    case decoding(String)

    var errorDescription: String? {
        switch self {
        case .invalidBaseURL:
            "The API base URL is invalid."
        case .invalidResponse:
            "The server returned an invalid response."
        case .unauthorized:
            "Your session expired. Log in again."
        case let .server(message, _):
            message
        case let .decoding(message):
            message
        }
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

struct AppConfig {
    static let baseURL = URL(string: ProcessInfo.processInfo.environment["SCUBAPAL_API_BASE_URL"] ?? "http://127.0.0.1:8080")!
    static let requestTimeout: TimeInterval = 24
}

struct TokenPair: Codable, Equatable {
    var accessToken: String
    var refreshToken: String
}

final class TokenVault {
    private let service = "com.scubapal.ios.session"
    private let account = "scubapal-token-pair"

    func load() -> TokenPair? {
        var query = baseQuery()
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else { return nil }
        return try? JSONDecoder().decode(TokenPair.self, from: data)
    }

    func save(_ tokenPair: TokenPair) {
        guard let data = try? JSONEncoder().encode(tokenPair) else { return }
        delete()

        var query = baseQuery()
        query[kSecValueData as String] = data
        query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        SecItemAdd(query as CFDictionary, nil)
    }

    func delete() {
        SecItemDelete(baseQuery() as CFDictionary)
    }

    private func baseQuery() -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }
}

final class ScubaAPI {
    var tokenPair: TokenPair?

    private let baseURL: URL
    private let session: URLSession
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private var refreshTask: Task<TokenPair, Error>?

    init(baseURL: URL = AppConfig.baseURL, tokenPair: TokenPair? = nil) {
        self.baseURL = baseURL
        self.tokenPair = tokenPair

        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = AppConfig.requestTimeout
        configuration.timeoutIntervalForResource = AppConfig.requestTimeout
        configuration.waitsForConnectivity = true
        self.session = URLSession(configuration: configuration)

        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
    }

    func login(username: String, password: String) async throws -> AuthResponse {
        try await request("/api/auth/login", method: .post, body: LoginRequest(username: username, password: password), requiresAuth: false)
    }

    func register(_ request: RegisterRequest) async throws -> AuthResponse {
        try await self.request("/api/auth/register", method: .post, body: request, requiresAuth: false)
    }

    func logout(refreshToken: String?) async {
        guard let refreshToken else { return }
        let payload = RefreshTokenRequest(refreshToken: refreshToken)
        try? await requestNoContent("/api/auth/logout", method: .post, body: payload, requiresAuth: false)
    }

    func currentUser() async throws -> CurrentUserView {
        try await request("/api/me", method: .get)
    }

    func feed(page: Int = 0, size: Int = 30) async throws -> [Post] {
        let response: PageResponse<FeedPostView> = try await request("/api/posts", query: ["page": "\(page)", "size": "\(size)"])
        return response.content?.map(toPost) ?? []
    }

    func postDetail(id: Int) async throws -> Post {
        let response: PostDetailDTO = try await request("/api/posts/\(id)")
        return toPost(response)
    }

    func createPost(caption: String, mediaUrls: [String]) async throws -> Post {
        let payload = CreateCurrentUserPostRequest(caption: caption, visibilityStatus: "PUBLIC", mediaUrls: mediaUrls)
        let response: FeedPostView = try await request("/api/posts/me", method: .post, body: payload)
        return toPost(response)
    }

    func toggleLike(postID: Int) async throws -> Post {
        let response: FeedPostView = try await request("/api/posts/\(postID)/like", method: .post, body: Optional<String>.none)
        return toPost(response)
    }

    func addComment(postID: Int, body: String) async throws -> Post {
        let payload = CreateCommentRequest(commentText: body)
        let response: PostDetailDTO = try await request("/api/posts/\(postID)/comments", method: .post, body: payload)
        return toPost(response)
    }

    func profiles(query: String) async throws -> [User] {
        let response: PageResponse<PublicProfileResponse> = try await request("/api/profiles", query: ["q": query, "page": "0", "size": "50"])
        return response.content?.map { toUser($0) } ?? []
    }

    func locations(query: String) async throws -> [DiveLocation] {
        let response: PageResponse<DiveLocationResponse> = try await request("/api/locations", query: ["city": query, "page": "0", "size": "80"])
        return response.content?.map(toLocation) ?? []
    }

    func shops(query: String) async throws -> [DiveShop] {
        let response: PageResponse<DiveShopResponse> = try await request("/api/shops", query: ["q": query, "page": "0", "size": "80"])
        return response.content?.map(toShop) ?? []
    }

    func profile(userID: Int) async throws -> User {
        async let profile: PublicProfileResponse = request("/api/users/\(userID)/profile")
        async let summary: FollowSummaryView? = try? request("/api/users/\(userID)/follow-summary")
        return toUser(try await profile, follow: await summary)
    }

    func currentProfile() async throws -> User {
        let response: ProfileResponse = try await request("/api/me/profile")
        let user = toUser(response)
        let summary: FollowSummaryView? = try? await request("/api/users/\(user.id)/follow-summary")
        return toUser(response, follow: summary)
    }

    func updateCurrentProfile(_ update: UpsertProfileRequest) async throws -> User {
        let response: ProfileResponse = try await request("/api/me/profile", method: .put, body: update)
        return toUser(response)
    }

    func follow(userID: Int, shouldFollow: Bool) async throws -> FollowSummaryView {
        let method: HTTPMethod = shouldFollow ? .post : .delete
        return try await request("/api/users/\(userID)/follow", method: method, body: Optional<String>.none)
    }

    func conversations() async throws -> [Conversation] {
        let response: ConversationListResponse = try await request("/api/messages/conversations", query: ["page": "0", "size": "50"])
        return response.conversations?.map(toConversation) ?? []
    }

    func startConversation(userID: Int) async throws -> Conversation {
        let response: ConversationView = try await request("/api/messages/conversations/\(userID)", method: .post, body: Optional<String>.none)
        return toConversation(response)
    }

    func messages(conversationID: Int) async throws -> [ChatMessage] {
        let response: MessageListResponse = try await request("/api/messages/\(conversationID)", query: ["page": "0", "size": "80"])
        return (response.messages ?? []).map(toMessage)
    }

    func sendMessage(conversationID: Int, body: String) async throws {
        let payload = SendMessageRequest(messageText: body)
        try await requestNoContent("/api/messages/\(conversationID)", method: .post, body: payload)
    }

    func unreadMessages() async throws -> Int {
        let response: UnreadCountView = try await request("/api/messages/unread-count")
        return response.unreadMessageCount ?? 0
    }

    func notifications() async throws -> [AppNotification] {
        let response: NotificationListResponse = try await request("/api/notifications", query: ["page": "0", "size": "50"])
        return response.notifications?.map(toNotification) ?? []
    }

    func unreadNotifications() async throws -> Int {
        let response: UnreadNotificationCountView = try await request("/api/notifications/unread-count")
        return response.unreadNotificationCount ?? 0
    }

    func markNotificationRead(id: Int) async throws {
        try await requestNoContent("/api/notifications/\(id)/read", method: .post, body: Optional<String>.none)
    }

    func learnArticles() async throws -> [LearnArticle] {
        let response: [LearnArticleResponse] = try await request("/api/learn/articles")
        return response.map(toLearnArticle)
    }

    private func request<T: Decodable>(_ path: String, method: HTTPMethod = .get, query: [String: String] = [:], requiresAuth: Bool = true) async throws -> T {
        try await request(path, method: method, query: query, bodyData: nil, requiresAuth: requiresAuth)
    }

    private func request<T: Decodable, Body: Encodable>(_ path: String, method: HTTPMethod = .get, query: [String: String] = [:], body: Body?, requiresAuth: Bool = true) async throws -> T {
        let bodyData = try body.map { try encoder.encode($0) }
        return try await request(path, method: method, query: query, bodyData: bodyData, requiresAuth: requiresAuth)
    }

    private func requestNoContent<Body: Encodable>(_ path: String, method: HTTPMethod, body: Body?, requiresAuth: Bool = true) async throws {
        let bodyData = try body.map { try encoder.encode($0) }
        let _: EmptyResponse = try await request(path, method: method, bodyData: bodyData, requiresAuth: requiresAuth)
    }

    private func request<T: Decodable>(_ path: String, method: HTTPMethod = .get, query: [String: String] = [:], bodyData: Data?, requiresAuth: Bool = true, retrying: Bool = false) async throws -> T {
        var urlRequest = try makeURLRequest(path: path, method: method, query: query, bodyData: bodyData, requiresAuth: requiresAuth)
        let (data, response) = try await session.data(for: urlRequest)
        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }

        if http.statusCode == 401, requiresAuth, !retrying, tokenPair?.refreshToken != nil {
            tokenPair = try await refreshTokens()
            urlRequest = try makeURLRequest(path: path, method: method, query: query, bodyData: bodyData, requiresAuth: requiresAuth)
            let (retryData, retryResponse) = try await session.data(for: urlRequest)
            guard let retryHTTP = retryResponse as? HTTPURLResponse else { throw APIError.invalidResponse }
            return try decodeResponse(retryData, status: retryHTTP.statusCode)
        }

        return try decodeResponse(data, status: http.statusCode)
    }

    private func makeURLRequest(path: String, method: HTTPMethod, query: [String: String], bodyData: Data?, requiresAuth: Bool) throws -> URLRequest {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))), resolvingAgainstBaseURL: false) else {
            throw APIError.invalidBaseURL
        }
        let queryItems = query
            .filter { !$0.value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .map { URLQueryItem(name: $0.key, value: $0.value) }
        if !queryItems.isEmpty { components.queryItems = queryItems }
        guard let url = components.url else { throw APIError.invalidBaseURL }

        var request = URLRequest(url: url, timeoutInterval: AppConfig.requestTimeout)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let bodyData {
            request.httpBody = bodyData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        if requiresAuth, let token = tokenPair?.accessToken, !token.isEmpty {
            request.setValue(token.hasPrefix("Bearer ") ? token : "Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }

    private func decodeResponse<T: Decodable>(_ data: Data, status: Int) throws -> T {
        guard (200..<300).contains(status) else {
            let apiError = try? decoder.decode(ApiErrorBody.self, from: data)
            let message = apiError?.message ?? apiError?.detail ?? apiError?.error ?? HTTPURLResponse.localizedString(forStatusCode: status)
            if status == 401 { throw APIError.unauthorized }
            throw APIError.server(message: message, status: status)
        }

        if T.self == EmptyResponse.self {
            return EmptyResponse() as! T
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decoding("Could not decode the server response: \(error.localizedDescription)")
        }
    }

    private func refreshTokens() async throws -> TokenPair {
        if let refreshTask { return try await refreshTask.value }
        guard let refreshToken = tokenPair?.refreshToken else { throw APIError.unauthorized }

        let task = Task<TokenPair, Error> {
            let payload = RefreshTokenRequest(refreshToken: refreshToken)
            let response: AuthResponse = try await request("/api/auth/refresh", method: .post, body: payload, requiresAuth: false)
            guard let accessToken = response.accessToken else { throw APIError.unauthorized }
            return TokenPair(accessToken: accessToken, refreshToken: response.refreshToken ?? refreshToken)
        }
        refreshTask = task
        defer { refreshTask = nil }
        return try await task.value
    }
}

private struct EmptyResponse: Decodable {}

extension ScubaAPI {
    func resolveMediaURL(_ value: String?) -> URL? {
        guard let value = value?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty else { return nil }
        if let url = URL(string: value), url.scheme != nil { return url }
        return baseURL.appendingPathComponent(value.trimmingCharacters(in: CharacterSet(charactersIn: "/")))
    }

    func toUser(_ input: CurrentUserView, follow: FollowSummaryView? = nil) -> User {
        User(
            id: input.id ?? 0,
            username: input.username ?? "diver-\(input.id ?? 0)",
            firstName: input.firstName,
            lastName: input.lastName,
            email: input.email,
            city: input.city,
            state: nil,
            country: input.country,
            profileImageUrl: input.profileImageUrl,
            bio: input.bio,
            diveCount: input.diveCount ?? 0,
            followersCount: follow?.followerCount ?? 0,
            followingCount: follow?.followingCount ?? 0,
            followedByMe: follow?.followedByCurrentUser ?? false
        )
    }

    func toUser(_ input: PublicProfileResponse, follow: FollowSummaryView? = nil) -> User {
        User(
            id: input.userId ?? 0,
            username: input.username ?? "diver-\(input.userId ?? 0)",
            firstName: input.firstName,
            lastName: input.lastName,
            email: nil,
            city: input.city,
            state: nil,
            country: input.country,
            profileImageUrl: input.profileImageUrl,
            bio: input.bio,
            diveCount: input.diveCount ?? 0,
            followersCount: follow?.followerCount ?? 0,
            followingCount: follow?.followingCount ?? 0,
            followedByMe: follow?.followedByCurrentUser ?? false
        )
    }

    func toUser(_ input: ProfileResponse, follow: FollowSummaryView? = nil) -> User {
        User(
            id: input.userId ?? input.profileId ?? 0,
            username: input.username ?? "diver-\(input.userId ?? 0)",
            firstName: input.firstName,
            lastName: input.lastName,
            email: nil,
            city: input.city,
            state: input.state,
            country: input.country,
            profileImageUrl: input.profileImageUrl,
            bio: input.bio,
            diveCount: input.diveCount ?? 0,
            followersCount: follow?.followerCount ?? 0,
            followingCount: follow?.followingCount ?? 0,
            followedByMe: follow?.followedByCurrentUser ?? false
        )
    }

    func toPost(_ input: FeedPostView) -> Post {
        post(
            id: input.postId,
            userID: input.userId,
            username: input.username,
            authorImage: input.authorProfileImageUrl,
            caption: input.caption,
            imageURL: input.imageUrl,
            mediaURLs: input.mediaUrls,
            likes: input.likes,
            comments: input.comments,
            liked: input.likedByCurrentUser,
            createdAt: input.createdAt,
            commentList: []
        )
    }

    func toPost(_ input: PostDetailDTO) -> Post {
        post(
            id: input.postId,
            userID: input.userId,
            username: input.username,
            authorImage: input.authorProfileImageUrl,
            caption: input.caption,
            imageURL: input.imageUrl,
            mediaURLs: input.mediaUrls,
            likes: input.likes,
            comments: input.comments ?? input.commentList?.count,
            liked: input.likedByCurrentUser,
            createdAt: input.createdAt,
            commentList: input.commentList?.map(toComment) ?? []
        )
    }

    private func post(id: Int?, userID: Int?, username: String?, authorImage: String?, caption: String?, imageURL: String?, mediaURLs: [String]?, likes: Int?, comments: Int?, liked: Bool?, createdAt: String?, commentList: [Comment]) -> Post {
        let resolved = (mediaURLs ?? [])
            .compactMap(resolveMediaURL)
        let primary = resolveMediaURL(imageURL) ?? resolved.first
        return Post(
            id: id ?? 0,
            author: User(
                id: userID ?? 0,
                username: username ?? "diver",
                firstName: nil,
                lastName: nil,
                email: nil,
                city: nil,
                state: nil,
                country: nil,
                profileImageUrl: authorImage,
                bio: nil,
                diveCount: 0,
                followersCount: 0,
                followingCount: 0,
                followedByMe: false
            ),
            content: caption ?? "",
            imageUrl: primary,
            mediaUrls: resolved.isEmpty ? (primary.map { [$0] } ?? []) : resolved,
            createdAt: .fromAPI(createdAt),
            likeCount: likes ?? 0,
            commentCount: comments ?? commentList.count,
            likedByMe: liked ?? false,
            comments: commentList
        )
    }

    func toComment(_ input: CommentView) -> Comment {
        Comment(
            id: input.commentId ?? abs("\(input.userId ?? 0)-\(input.createdAt ?? "")".hashValue),
            userId: input.userId ?? 0,
            username: input.username ?? "diver",
            body: input.commentText ?? "",
            createdAt: .fromAPI(input.createdAt)
        )
    }

    func toLocation(_ input: DiveLocationResponse) -> DiveLocation {
        DiveLocation(
            id: input.locationId ?? 0,
            name: input.locationName ?? "Dive location",
            description: input.description,
            imageUrl: resolveMediaURL(input.imageUrl),
            city: input.city,
            state: input.state,
            country: input.country,
            latitude: input.latitude,
            longitude: input.longitude,
            difficultyLevel: input.difficultyLevel,
            popularityScore: input.popularityScore
        )
    }

    func toShop(_ input: DiveShopResponse) -> DiveShop {
        DiveShop(
            id: input.shopId ?? 0,
            name: input.shopName ?? "Dive shop",
            description: input.description,
            imageUrl: resolveMediaURL(input.imageUrl),
            phoneNumber: input.phoneNumber,
            email: input.email,
            websiteUrl: input.websiteUrl,
            streetAddress: input.streetAddress,
            city: input.city,
            state: input.state,
            country: input.country,
            locationName: input.locationName
        )
    }

    func toConversation(_ input: ConversationView) -> Conversation {
        Conversation(
            id: input.conversationId ?? 0,
            participant: User(
                id: input.otherUserId ?? 0,
                username: input.otherUsername ?? "diver",
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
            updatedAt: .fromAPI(input.updatedAt)
        )
    }

    func toMessage(_ input: MessageView) -> ChatMessage {
        ChatMessage(
            id: input.id,
            senderId: input.senderUserId ?? 0,
            senderProfileImageUrl: resolveMediaURL(input.senderProfileImageUrl),
            body: input.messageText ?? "",
            createdAt: .fromAPI(input.createdAt),
            sentByCurrentUser: input.sentByCurrentUser ?? false
        )
    }

    func toNotification(_ input: NotificationView) -> AppNotification {
        AppNotification(
            id: input.notificationId ?? 0,
            title: input.title ?? "Notification",
            body: input.message ?? "",
            read: input.read ?? false,
            createdAt: .fromAPI(input.createdAt),
            type: input.type
        )
    }

    func toLearnArticle(_ input: LearnArticleResponse) -> LearnArticle {
        LearnArticle(
            id: input.id,
            slug: input.slug ?? "learn-article",
            title: input.title ?? "Scuba lesson",
            summary: input.summary ?? "",
            content: input.content ?? "",
            category: input.category ?? "Learning",
            difficultyLevel: input.difficultyLevel ?? "Beginner",
            estimatedMinutes: input.estimatedMinutes ?? 5,
            updatedAt: .fromAPI(input.updatedAt)
        )
    }
}
