import Foundation

extension AppDependencies {
    static let preview = AppDependencies(
        authRepository: PreviewAuthRepository(),
        feedRepository: PreviewFeedRepository(),
        profileRepository: PreviewProfileRepository(),
        discoverRepository: PreviewDiscoverRepository(),
        messagingRepository: PreviewMessagingRepository(),
        notificationsRepository: PreviewNotificationsRepository()
    )
}

enum PreviewData {
    static let now = Date(timeIntervalSince1970: 1_780_000_000)

    static let currentUser = User(
        id: 1,
        username: "reefwatcher",
        firstName: "Reef",
        lastName: "Watcher",
        email: "reef@example.com",
        role: .user,
        city: "Kailua",
        state: "HI",
        country: "US",
        profileImageUrl: nil,
        profileImageURL: nil,
        visibilityStatus: .publicStatus,
        bio: "Warm water fan, wreck curious, always up for a shore dive.",
        diveCount: 42,
        followersCount: 128,
        followingCount: 76,
        followedByMe: false
    )

    static let buddy = User(
        id: 2,
        username: "kelpguide",
        firstName: "Kai",
        lastName: "Mori",
        email: nil,
        role: .user,
        city: "Monterey",
        state: "CA",
        country: "US",
        profileImageUrl: nil,
        profileImageURL: nil,
        visibilityStatus: .publicStatus,
        bio: "Cold-water local with a soft spot for nudibranchs.",
        diveCount: 87,
        followersCount: 211,
        followingCount: 98,
        followedByMe: true
    )

    static let posts = [
        Post(
            id: 101,
            author: currentUser,
            content: "Morning viz opened up right as the reef woke up.",
            visibilityStatus: .publicStatus,
            imageUrl: nil,
            mediaUrls: [],
            createdAt: now.addingTimeInterval(-3_600),
            likeCount: 24,
            commentCount: 1,
            likedByMe: true,
            comments: [
                Comment(id: 501, userId: buddy.id, username: buddy.username, body: "That light looks unreal.", createdAt: now.addingTimeInterval(-2_800))
            ]
        ),
        Post(
            id: 102,
            author: buddy,
            content: "Kelp forest was calm enough for a long hover practice session.",
            visibilityStatus: .publicStatus,
            imageUrl: nil,
            mediaUrls: [],
            createdAt: now.addingTimeInterval(-7_200),
            likeCount: 18,
            commentCount: 0,
            likedByMe: false,
            comments: []
        )
    ]

    static let locations = [
        DiveLocation(
            id: 201,
            name: "Breakwater Cove",
            description: "Protected entry with kelp, sand channels, and lots of training traffic.",
            imageUrl: nil,
            city: "Monterey",
            state: "CA",
            country: "US",
            latitude: nil,
            longitude: nil,
            difficultyLevel: "Beginner",
            popularityScore: 96
        )
    ]

    static let shops = [
        DiveShop(
            id: 301,
            name: "Harbor Dive Supply",
            description: "Air fills, rentals, and local charters.",
            imageUrl: nil,
            phoneNumber: "555-0100",
            email: "hello@example.com",
            websiteUrl: nil,
            streetAddress: "1 Ocean Ave",
            city: "Monterey",
            state: "CA",
            country: "US",
            locationName: "Breakwater Cove"
        )
    ]

    static let articles = [
        LearnArticle(
            id: 401,
            slug: "pre-dive-buddy-check",
            title: "Pre-dive buddy check",
            summary: "Run a consistent check before every entry.",
            content: "Confirm BCD, weights, releases, air, and final plan with your buddy.",
            category: "Safety",
            difficultyLevel: "Beginner",
            estimatedMinutes: 6,
            updatedAt: now
        )
    ]

    static let conversations = [
        Conversation(
            id: 601,
            participant: buddy,
            lastMessage: "Boat leaves at 8?",
            unreadCount: 1,
            updatedAt: now.addingTimeInterval(-900)
        )
    ]

    static let messages = [
        ChatMessage(id: 701, senderId: buddy.id, senderProfileImageUrl: nil, body: "Boat leaves at 8?", createdAt: now.addingTimeInterval(-900), sentByCurrentUser: false),
        ChatMessage(id: 702, senderId: currentUser.id, senderProfileImageUrl: nil, body: "Yep, I will bring the spare light.", createdAt: now.addingTimeInterval(-700), sentByCurrentUser: true)
    ]

    static let notifications = [
        AppNotification(id: 801, title: "New message", body: "Kai sent you a dive note.", read: false, createdAt: now.addingTimeInterval(-600), type: "message"),
        AppNotification(id: 802, title: "Post liked", body: "Someone liked your reef post.", read: true, createdAt: now.addingTimeInterval(-4_000), type: "like")
    ]
}

struct PreviewAuthRepository: AuthRepositoryProtocol {
    func restoreCurrentUser() async throws -> User? { PreviewData.currentUser }
    func login(username: String, password: String) async throws -> User { PreviewData.currentUser }
    func register(email: String, username: String, password: String, firstName: String?, lastName: String?) async throws -> User { PreviewData.currentUser }
    func logout() async {}
    func currentUser() async throws -> User { PreviewData.currentUser }
}

struct PreviewFeedRepository: FeedRepositoryProtocol {
    func loadFeed(page: Int, size: Int) async throws -> [Post] { PreviewData.posts }

    func postDetail(id: Int) async throws -> Post {
        PreviewData.posts.first { $0.id == id } ?? PreviewData.posts[0]
    }

    func createPost(caption: String, mediaUrls: [String]) async throws -> Post {
        Post(
            id: 999,
            author: PreviewData.currentUser,
            content: caption,
            visibilityStatus: .publicStatus,
            imageUrl: mediaUrls.first.flatMap(URL.init(string:)),
            mediaUrls: mediaUrls.compactMap(URL.init(string:)),
            createdAt: PreviewData.now,
            likeCount: 0,
            commentCount: 0,
            likedByMe: false,
            comments: []
        )
    }

    func toggleLike(postID: Int) async throws -> Post {
        var post = try await postDetail(id: postID)
        post.likedByMe.toggle()
        post.likeCount = max(0, post.likeCount + (post.likedByMe ? 1 : -1))
        return post
    }

    func addComment(postID: Int, body: String) async throws -> Post {
        var post = try await postDetail(id: postID)
        post.comments.append(Comment(id: 998, userId: PreviewData.currentUser.id, username: PreviewData.currentUser.username, body: body, createdAt: PreviewData.now))
        post.commentCount = post.comments.count
        return post
    }
}

struct PreviewProfileRepository: ProfileRepositoryProtocol {
    func profiles(query: String) async throws -> [User] {
        [PreviewData.currentUser, PreviewData.buddy].filter { user in
            query.isEmpty || user.username.localizedCaseInsensitiveContains(query) || user.displayName.localizedCaseInsensitiveContains(query)
        }
    }

    func profile(userID: Int) async throws -> User {
        userID == PreviewData.currentUser.id ? PreviewData.currentUser : PreviewData.buddy
    }

    func currentProfile() async throws -> User { PreviewData.currentUser }

    func updateCurrentProfile(_ update: ProfileUpdate) async throws -> User {
        var user = PreviewData.currentUser
        user.firstName = update.firstName ?? user.firstName
        user.lastName = update.lastName ?? user.lastName
        user.city = update.city ?? user.city
        user.state = update.state ?? user.state
        user.country = update.country ?? user.country
        user.bio = update.bio ?? user.bio
        user.diveCount = update.diveCount ?? user.diveCount
        user.profileImageUrl = update.profileImageUrl ?? user.profileImageUrl
        return user
    }

    func follow(userID: Int, shouldFollow: Bool) async throws -> FollowSummary {
        FollowSummary(followingCount: 77, followerCount: shouldFollow ? 212 : 211, followedByCurrentUser: shouldFollow)
    }
}

struct PreviewDiscoverRepository: DiscoverRepositoryProtocol {
    func locations(query: String) async throws -> [DiveLocation] { PreviewData.locations }
    func shops(query: String) async throws -> [DiveShop] { PreviewData.shops }
    func learnArticles() async throws -> [LearnArticle] { PreviewData.articles }
}

struct PreviewMessagingRepository: MessagingRepositoryProtocol {
    func conversations() async throws -> [Conversation] { PreviewData.conversations }
    func startConversation(userID: Int) async throws -> Conversation { PreviewData.conversations[0] }
    func messages(conversationID: Int) async throws -> [ChatMessage] { PreviewData.messages }
    func sendMessage(conversationID: Int, body: String) async throws {}
    func unreadCount() async throws -> Int { 1 }
}

struct PreviewNotificationsRepository: NotificationsRepositoryProtocol {
    func notifications() async throws -> [AppNotification] { PreviewData.notifications }
    func unreadCount() async throws -> Int { PreviewData.notifications.filter { !$0.read }.count }
    func markRead(id: Int) async throws {}
}
