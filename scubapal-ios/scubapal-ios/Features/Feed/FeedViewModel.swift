import Combine
import Foundation

@MainActor
final class FeedViewModel: ObservableObject {
    @Published private(set) var state: Loadable<[Post]> = .idle

    private let repository: any FeedRepositoryProtocol

    init(repository: any FeedRepositoryProtocol) {
        self.repository = repository
    }

    var posts: [Post] {
        state.value ?? []
    }

    func load(showLoading: Bool) async {
        if showLoading { state = .loading }
        do {
            let posts = try await repository.loadFeed()
            state = .loaded(posts)
        } catch {
            state = .failed(error.userFacingMessage)
        }
    }

    func toggleLike(_ post: Post) async -> String? {
        guard var posts = state.value, let index = posts.firstIndex(where: { $0.id == post.id }) else {
            return nil
        }

        var optimistic = posts[index]
        optimistic.likedByMe.toggle()
        optimistic.likeCount = max(0, optimistic.likeCount + (optimistic.likedByMe ? 1 : -1))
        posts[index] = optimistic
        state = .loaded(posts)

        do {
            let updated = try await repository.toggleLike(postID: post.id)
            guard var current = state.value, let updateIndex = current.firstIndex(where: { $0.id == post.id }) else {
                return nil
            }
            current[updateIndex] = updated
            state = .loaded(current)
            return nil
        } catch {
            guard var current = state.value, let rollbackIndex = current.firstIndex(where: { $0.id == post.id }) else {
                return error.userFacingMessage
            }
            current[rollbackIndex] = post
            state = .loaded(current)
            return error.userFacingMessage
        }
    }

    func createPost(caption: String, mediaUrls: [String]) async -> String? {
        do {
            let created = try await repository.createPost(caption: caption, mediaUrls: mediaUrls)
            var posts = state.value ?? []
            posts.insert(created, at: 0)
            state = .loaded(posts)
            return nil
        } catch {
            return error.userFacingMessage
        }
    }
}

@MainActor
final class PostDetailViewModel: ObservableObject {
    @Published private(set) var post: Post
    @Published private(set) var isLoading = false

    private let repository: any FeedRepositoryProtocol

    init(post: Post, repository: any FeedRepositoryProtocol) {
        self.post = post
        self.repository = repository
    }

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        guard let detail = try? await repository.postDetail(id: post.id) else { return }
        post = detail
    }

    func toggleLike() async -> String? {
        let previous = post
        post.likedByMe.toggle()
        post.likeCount = max(0, post.likeCount + (post.likedByMe ? 1 : -1))
        do {
            post = try await repository.toggleLike(postID: previous.id)
            return nil
        } catch {
            post = previous
            return error.userFacingMessage
        }
    }

    func addComment(_ text: String) async -> String? {
        do {
            post = try await repository.addComment(postID: post.id, body: text)
            return nil
        } catch {
            return error.userFacingMessage
        }
    }
}
