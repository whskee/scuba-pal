import SwiftUI

struct FeedContentView: View {
    let state: Loadable<[Post]>
    let posts: [Post]
    let onLike: (Post) -> Void
    let onSave: () -> Void

    var body: some View {
        if case .idle = state {
            loadingView
        } else if case .loading = state {
            loadingView
        } else if let errorMessage = state.errorMessage {
            EmptyStateView(title: "Feed unavailable", message: errorMessage, systemImage: "wifi.exclamationmark")
        } else if posts.isEmpty {
            EmptyStateView(title: "No posts yet", message: "Create the first Scuba Pal post.", systemImage: "plus.bubble")
        } else {
            MasonryFeed(posts: posts, onLike: onLike, onSave: onSave)
                .padding(.horizontal, 14)
        }
    }

    private var loadingView: some View {
        ProgressView()
            .tint(ScubaTheme.primary)
            .padding(.top, 28)
    }
}

private struct MasonryFeed: View {
    let posts: [Post]
    let onLike: (Post) -> Void
    let onSave: () -> Void

    private var columns: ([Post], [Post]) {
        posts.enumerated().reduce(into: ([Post](), [Post]())) { result, element in
            if element.offset.isMultiple(of: 2) {
                result.0.append(element.element)
            } else {
                result.1.append(element.element)
            }
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 16) {
                ForEach(Array(columns.0.enumerated()), id: \.element.id) { index, post in
                    PinterestPostCard(post: post, index: index * 2, onLike: onLike, onSave: onSave)
                }
            }
            VStack(spacing: 16) {
                Spacer(minLength: 34)
                ForEach(Array(columns.1.enumerated()), id: \.element.id) { index, post in
                    PinterestPostCard(post: post, index: index * 2 + 1, onLike: onLike, onSave: onSave)
                }
            }
        }
    }
}

private struct PinterestPostCard: View {
    let post: Post
    let index: Int
    let onLike: (Post) -> Void
    let onSave: () -> Void
    @State private var saved = false

    private var imageHeight: CGFloat {
        188 + CGFloat((index * 47) % 118)
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            NavigationLink(value: post) {
                VStack(alignment: .leading, spacing: 0) {
                    RemoteImage(url: post.imageUrl, cornerRadius: 0)
                        .frame(height: post.imageUrl == nil ? 138 : imageHeight)
                        .clipped()

                    VStack(alignment: .leading, spacing: 10) {
                        Text(post.content.isEmpty ? "Ocean moment" : post.content)
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundStyle(ScubaTheme.darkText)
                            .lineLimit(3)
                            .multilineTextAlignment(.leading)

                        HStack(spacing: 8) {
                            AvatarView(user: post.author, size: 28)
                            Text("@\(post.author.username)")
                                .font(.system(size: 12, weight: .heavy))
                                .foregroundStyle(Color(red: 0.39, green: 0.45, blue: 0.52))
                                .lineLimit(1)
                            Spacer(minLength: 4)
                            Label("\(post.likeCount)", systemImage: post.likedByMe ? "heart.fill" : "heart")
                                .font(.system(size: 11, weight: .black))
                                .foregroundStyle(post.likedByMe ? ScubaTheme.accent : Color(red: 0.39, green: 0.45, blue: 0.52))
                                .labelStyle(.titleAndIcon)
                        }
                    }
                    .padding(13)
                    .background(Color.white)
                }
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .shadow(color: .black.opacity(0.24), radius: 18, x: 0, y: 12)
            }
            .buttonStyle(ScaleButtonStyle())

            HStack(spacing: 8) {
                floatingAction(systemImage: post.likedByMe ? "heart.fill" : "heart", active: post.likedByMe, color: ScubaTheme.accent) {
                    onLike(post)
                }
                floatingAction(systemImage: saved ? "bookmark.fill" : "bookmark", active: saved, color: ScubaTheme.primary) {
                    withAnimation(.snappy(duration: 0.22)) {
                        saved.toggle()
                    }
                    onSave()
                }
            }
            .padding(10)
        }
    }

    private func floatingAction(systemImage: String, active: Bool, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 15, weight: .heavy))
                .foregroundStyle(active ? color : ScubaTheme.darkText)
                .frame(width: 36, height: 36)
                .background(Color.white.opacity(0.9), in: Circle())
                .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
