import SwiftUI

struct FeedPostGrid: View {
    let posts: [Post]
    let onLike: (Post) -> Void
    let onSave: () -> Void

    private let columns = [
        GridItem(.flexible(minimum: 0), spacing: 14, alignment: .top),
        GridItem(.flexible(minimum: 0), spacing: 14, alignment: .top)
    ]

    var body: some View {
        LazyVGrid(columns: columns, alignment: .center, spacing: 16) {
            ForEach(Array(posts.enumerated()), id: \.element.id) { index, post in
                LuxuryPostCard(post: post, index: index, onLike: onLike, onSave: onSave)
                    .equatable()
            }
        }
    }
}
