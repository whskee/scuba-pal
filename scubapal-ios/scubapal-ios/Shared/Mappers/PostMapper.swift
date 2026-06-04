import Foundation

struct PostMapper: Sendable {
    let mediaURLResolver: MediaURLResolver

    func map(_ input: FeedPostDTO) throws -> Post {
        try post(
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

    func map(_ input: PostDetailDTO) throws -> Post {
        let comments = try (input.commentList ?? []).map(map)
        return try post(
            id: input.postId,
            userID: input.userId,
            username: input.username,
            authorImage: input.authorProfileImageUrl,
            caption: input.caption,
            imageURL: input.imageUrl,
            mediaURLs: input.mediaUrls,
            likes: input.likes,
            comments: input.comments ?? comments.count,
            liked: input.likedByCurrentUser,
            createdAt: input.createdAt,
            commentList: comments
        )
    }

    func map(_ input: CommentDTO) throws -> Comment {
        Comment(
            id: try RequiredField.value(input.commentId, "commentId"),
            userId: try RequiredField.value(input.userId, "comment.userId"),
            username: try RequiredField.nonBlank(input.username, "comment.username"),
            body: input.commentText ?? "",
            createdAt: try DateParsing.fromAPI(input.createdAt, field: "comment.createdAt")
        )
    }

    private func post(
        id: Int?,
        userID: Int?,
        username: String?,
        authorImage: String?,
        caption: String?,
        imageURL: String?,
        mediaURLs: [String]?,
        likes: Int?,
        comments: Int?,
        liked: Bool?,
        createdAt: String?,
        commentList: [Comment]
    ) throws -> Post {
        let resolved = (mediaURLs ?? []).compactMap(mediaURLResolver.resolve)
        let primary = mediaURLResolver.resolve(imageURL) ?? resolved.first
        return Post(
            id: try RequiredField.value(id, "postId"),
            author: User(
                id: try RequiredField.value(userID, "post.userId"),
                username: try RequiredField.nonBlank(username, "post.username"),
                firstName: nil,
                lastName: nil,
                email: nil,
                city: nil,
                state: nil,
                country: nil,
                profileImageUrl: authorImage,
                profileImageURL: mediaURLResolver.resolve(authorImage),
                bio: nil,
                diveCount: 0,
                followersCount: 0,
                followingCount: 0,
                followedByMe: false
            ),
            content: caption ?? "",
            imageUrl: primary,
            mediaUrls: resolved.isEmpty ? (primary.map { [$0] } ?? []) : resolved,
            createdAt: try DateParsing.fromAPI(createdAt, field: "post.createdAt"),
            likeCount: likes ?? 0,
            commentCount: comments ?? commentList.count,
            likedByMe: liked ?? false,
            comments: commentList
        )
    }
}
