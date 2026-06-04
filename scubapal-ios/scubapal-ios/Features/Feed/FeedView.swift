import SwiftUI

struct FeedView: View {
    @EnvironmentObject private var session: SessionStore
    @EnvironmentObject private var badges: BadgeStore
    @EnvironmentObject private var appUI: AppUIStore
    @StateObject private var viewModel: FeedViewModel
    @State private var activeFilter = "For you"
    @State private var showingComposer = false

    private let filters = ["For you", "Local", "Buddies", "Gear", "Training"]

    init(repository: FeedRepository = AppEnvironment.live.feedRepository) {
        _viewModel = StateObject(wrappedValue: FeedViewModel(repository: repository))
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 18) {
                feedHeader
                filterRail
                composePrompt

                if case .idle = viewModel.state {
                    ProgressView()
                        .tint(ScubaTheme.primary)
                        .padding(.top, 28)
                } else if case .loading = viewModel.state {
                    ProgressView()
                        .tint(ScubaTheme.primary)
                        .padding(.top, 28)
                } else if let errorMessage = viewModel.state.errorMessage {
                    EmptyStateView(title: "Feed unavailable", message: errorMessage, systemImage: "wifi.exclamationmark")
                } else if viewModel.posts.isEmpty {
                    EmptyStateView(title: "No posts yet", message: "Create the first Scuba Pal post.", systemImage: "plus.bubble")
                } else {
                    MasonryFeed(posts: viewModel.posts, onLike: like, onSave: { appUI.showToast("Saved for later", systemImage: "bookmark.fill") })
                        .padding(.horizontal, 14)
                }
            }
            .padding(.top, 14)
            .padding(.bottom, 104)
        }
        .refreshable { await loadFeed(showLoading: false) }
        .scrollIndicators(.hidden)
        .navigationDestination(for: Post.self) { post in
            PostDetailView(post: post)
        }
        .sheet(isPresented: $showingComposer) {
            CreatePostSheet { caption, urls in
                await createPost(caption: caption, mediaUrls: urls)
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .task { await loadFeed(showLoading: viewModel.posts.isEmpty) }
    }

    private var feedHeader: some View {
        VStack(spacing: 12) {
            BrandedScreenHeader(
                title: "Dive feed",
                eyebrow: "Scuba Pal",
                subtitle: "Stories, buddy moments, gear finds, and ocean notes from your circle.",
                systemImage: "water.waves"
            ) {
                IconCircleButton(systemImage: "graduationcap.fill") {
                    appUI.showToast("Learn is available from Discover", systemImage: "graduationcap.fill")
                }
            }

            HStack(spacing: 10) {
                StatChip(value: "\(viewModel.posts.count)", label: "posts")
                StatChip(value: "\(badges.unreadMessages)", label: "chats")
                StatChip(value: "\(badges.unreadNotifications)", label: "alerts")
            }
            .padding(.horizontal, 18)
        }
    }

    private var filterRail: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 10) {
                ForEach(filters, id: \.self) { filter in
                    Button {
                        withAnimation(.snappy(duration: 0.22)) { activeFilter = filter }
                    } label: {
                        Text(filter)
                            .font(.system(size: 13, weight: .heavy))
                            .foregroundStyle(activeFilter == filter ? ScubaTheme.darkText : ScubaTheme.ink)
                            .padding(.horizontal, 14)
                            .frame(height: 40)
                            .background(activeFilter == filter ? ScubaTheme.primary : ScubaTheme.surface.opacity(0.82), in: Capsule())
                            .overlay(Capsule().stroke(activeFilter == filter ? ScubaTheme.primary : ScubaTheme.border, lineWidth: 1))
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
            .padding(.horizontal, 18)
        }
        .scrollIndicators(.hidden)
    }

    private var composePrompt: some View {
        Button {
            showingComposer = true
        } label: {
            HStack(spacing: 12) {
                AvatarView(user: session.currentUser, size: 42)
                Text("Share a dive moment...")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(ScubaTheme.muted)
                Spacer()
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(ScubaTheme.primary)
            }
            .padding(14)
            .glassPanel(radius: 24, fill: ScubaTheme.background.opacity(0.32))
        }
        .buttonStyle(ScaleButtonStyle())
        .padding(.horizontal, 18)
    }

    private func loadFeed(showLoading: Bool) async {
        await viewModel.load(showLoading: showLoading)
    }

    private func like(_ post: Post) {
        Task {
            if let error = await viewModel.toggleLike(post) {
                appUI.showToast(error, systemImage: "exclamationmark.triangle.fill")
            }
        }
    }

    private func createPost(caption: String, mediaUrls: [String]) async {
        if let error = await viewModel.createPost(caption: caption, mediaUrls: mediaUrls) {
            appUI.showToast(error, systemImage: "exclamationmark.triangle.fill")
        } else {
            appUI.showToast("Posted to your feed", systemImage: "paperplane.fill")
        }
    }
}

private struct StatChip: View {
    var value: String
    var label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(ScubaTheme.ink)
            Text(label)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(ScubaTheme.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(ScubaTheme.surface2.opacity(0.5), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(ScubaTheme.primary.opacity(0.12), lineWidth: 1)
        )
    }
}

private struct MasonryFeed: View {
    var posts: [Post]
    var onLike: (Post) -> Void
    var onSave: () -> Void

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
    var post: Post
    var index: Int
    var onLike: (Post) -> Void
    var onSave: () -> Void
    @State private var saved = false

    private var imageHeight: CGFloat {
        188 + CGFloat((index * 47) % 118)
    }

    var body: some View {
        NavigationLink(value: post) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .topTrailing) {
                    RemoteImage(url: post.imageUrl, cornerRadius: 0)
                        .frame(height: post.imageUrl == nil ? 138 : imageHeight)
                        .clipped()

                    HStack(spacing: 8) {
                        floatingAction(systemImage: post.likedByMe ? "heart.fill" : "heart", active: post.likedByMe, color: ScubaTheme.accent) {
                            onLike(post)
                        }
                        floatingAction(systemImage: saved ? "bookmark.fill" : "bookmark", active: saved, color: ScubaTheme.primary) {
                            withAnimation(.snappy(duration: 0.22)) { saved.toggle() }
                            onSave()
                        }
                    }
                    .padding(10)
                }

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

struct PostDetailView: View {
    @EnvironmentObject private var appUI: AppUIStore
    @StateObject private var viewModel: PostDetailViewModel
    @State private var commentText = ""

    init(post: Post, repository: FeedRepository = AppEnvironment.live.feedRepository) {
        _viewModel = StateObject(
            wrappedValue: PostDetailViewModel(post: post, repository: repository)
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                RemoteImage(url: viewModel.post.imageUrl, cornerRadius: 32)
                    .frame(height: 360)
                    .clipped()
                    .overlay(alignment: .bottomLeading) {
                        VStack(alignment: .leading, spacing: 7) {
                            Text("@\(viewModel.post.author.username)")
                                .font(.system(size: 13, weight: .heavy))
                                .foregroundStyle(ScubaTheme.primary)
                            Text(viewModel.post.content)
                                .font(.system(size: 22, weight: .black))
                                .foregroundStyle(ScubaTheme.ink)
                                .lineSpacing(3)
                        }
                        .padding(18)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(LinearGradient(colors: [.clear, .black.opacity(0.72)], startPoint: .top, endPoint: .bottom))
                    }

                HStack(spacing: 10) {
                    ScubaButton(title: "\(viewModel.post.likeCount) likes", systemImage: viewModel.post.likedByMe ? "heart.fill" : "heart", style: .quiet) {
                        like()
                    }
                    ScubaButton(title: "\(viewModel.post.commentCount) comments", systemImage: "bubble.left.fill", style: .quiet) {}
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Comments")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(ScubaTheme.ink)

                    HStack(spacing: 10) {
                        FloatingTextField(title: "Add a comment", text: $commentText, systemImage: "bubble.left.fill")
                        Button {
                            addComment()
                        } label: {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundStyle(commentText.nilIfBlank == nil ? ScubaTheme.muted : ScubaTheme.primary)
                        }
                        .disabled(commentText.nilIfBlank == nil)
                    }

                    if viewModel.post.comments.isEmpty {
                        EmptyStateView(title: "No comments", message: "Start the conversation.", systemImage: "bubble.left")
                    } else {
                        ForEach(viewModel.post.comments) { comment in
                            HStack(alignment: .top, spacing: 10) {
                                AvatarView(user: User(id: comment.userId, username: comment.username, diveCount: 0, followersCount: 0, followingCount: 0, followedByMe: false), size: 36)
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("@\(comment.username)")
                                        .font(.system(size: 13, weight: .heavy))
                                        .foregroundStyle(ScubaTheme.ink)
                                    Text(comment.body)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundStyle(ScubaTheme.muted)
                                }
                            }
                            .padding(14)
                            .glassPanel(radius: 20, fill: ScubaTheme.surface.opacity(0.55))
                        }
                    }
                }
            }
            .padding(18)
            .padding(.bottom, 86)
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Post")
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadDetail() }
    }

    private func loadDetail() async {
        await viewModel.load()
    }

    private func like() {
        Task {
            if let error = await viewModel.toggleLike() {
                appUI.showToast(error, systemImage: "exclamationmark.triangle.fill")
            }
        }
    }

    private func addComment() {
        guard let text = commentText.nilIfBlank else { return }
        commentText = ""
        Task {
            if let error = await viewModel.addComment(text) {
                appUI.showToast(error, systemImage: "exclamationmark.triangle.fill")
            }
        }
    }
}

private struct CreatePostSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var caption = ""
    @State private var mediaURL = ""
    @State private var isSubmitting = false
    var onSubmit: (String, [String]) async -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                FloatingTextField(title: "Caption", text: $caption, systemImage: "text.quote")
                FloatingTextField(title: "Image URL", text: $mediaURL, systemImage: "photo.fill", keyboardType: .URL)
                Text("Image upload can be added on top of the backend media upload contract; URL posting is supported now.")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(ScubaTheme.muted)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                ScubaButton(title: "Post", systemImage: "paperplane.fill", isLoading: isSubmitting, isDisabled: caption.nilIfBlank == nil) {
                    submit()
                }
            }
            .padding(20)
            .appBackground()
            .navigationTitle("New post")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func submit() {
        guard let caption = caption.nilIfBlank else { return }
        isSubmitting = true
        Task {
            let urls = mediaURL.nilIfBlank.map { [$0] } ?? []
            await onSubmit(caption, urls)
            isSubmitting = false
            dismiss()
        }
    }
}
