import Foundation

struct FeedRepository: Sendable {
    let apiClient: APIClient
    let mapper: PostMapper

    func loadFeed(page: Int = 0, size: Int = 30) async throws -> [Post] {
        let endpoint = Endpoint(
            path: "/api/posts",
            query: ["page": "\(page)", "size": "\(size)"]
        )
        let response: PageResponseDTO<FeedPostDTO> = try await apiClient.request(endpoint)
        return try (response.content ?? []).map(mapper.map)
    }

    func postDetail(id: Int) async throws -> Post {
        let response: PostDetailDTO = try await apiClient.request(Endpoint(path: "/api/posts/\(id)"))
        return try mapper.map(response)
    }

    func createPost(caption: String, mediaUrls: [String]) async throws -> Post {
        let endpoint = Endpoint(path: "/api/posts/me", method: .post)
        let response: FeedPostDTO = try await apiClient.request(
            endpoint,
            body: CreatePostRequest(
                caption: caption,
                visibilityStatus: "PUBLIC",
                mediaUrls: mediaUrls
            )
        )
        return try mapper.map(response)
    }

    func toggleLike(postID: Int) async throws -> Post {
        let endpoint = Endpoint(path: "/api/posts/\(postID)/like", method: .post)
        let response: FeedPostDTO = try await apiClient.request(endpoint)
        return try mapper.map(response)
    }

    func addComment(postID: Int, body: String) async throws -> Post {
        let endpoint = Endpoint(path: "/api/posts/\(postID)/comments", method: .post)
        let response: PostDetailDTO = try await apiClient.request(
            endpoint,
            body: CreateCommentRequest(commentText: body)
        )
        return try mapper.map(response)
    }
}
