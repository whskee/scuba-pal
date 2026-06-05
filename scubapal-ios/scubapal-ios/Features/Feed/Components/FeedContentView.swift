import SwiftUI

struct FeedContentView: View {
    let state: Loadable<[Post]>
    let onLike: (Post) -> Void
    let onSave: () -> Void

    var body: some View {
        LoadableCollectionView(
            state: state,
            loadingTopPadding: 28,
            errorTitle: "Feed unavailable"
        ) {
            EmptyStateView(title: "No posts yet", message: "Create the first ScubaPal post.", systemImage: "plus.bubble")
        } content: { posts in
            FeedPostGrid(posts: posts, onLike: onLike, onSave: onSave)
                .padding(.horizontal, 16)
        }
    }
}
