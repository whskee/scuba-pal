import SwiftUI

struct FeedView: View {
    @EnvironmentObject private var session: AppSession
    @State private var posts: [Post] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var activeFilter = "For you"
    @State private var showingComposer = false

    private let filters = ["For you", "Local", "Buddies", "Gear", "Training"]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 18) {
                feedHeader
                filterRail
                composePrompt

                if isLoading {
                    ProgressView()
                        .tint(ScubaTheme.primary)
                        .padding(.top, 28)
                } else if let errorMessage {
                    EmptyStateView(title: "Feed unavailable", message: errorMessage, systemImage: "wifi.exclamationmark")
                } else if posts.isEmpty {
                    EmptyStateView(title: "No posts yet", message: "Create the first Scuba Pal post.", systemImage: "plus.bubble")
                } else {
                    MasonryFeed(posts: posts, onLike: like, onSave: { session.showToast("Saved for later", systemImage: "bookmark.fill") })
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
        .task { await loadFeed(showLoading: posts.isEmpty) }
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
                    session.showToast("Learn is available from Discover", systemImage: "graduationcap.fill")
                }
            }

            HStack(spacing: 10) {
                StatChip(value: "\(posts.count)", label: "posts")
                StatChip(value: "\(session.unreadMessages)", label: "chats")
                StatChip(value: "\(session.unreadNotifications)", label: "alerts")
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
        if showLoading { isLoading = true }
        errorMessage = nil
        do {
            let next = try await session.api.feed()
            withAnimation(.smooth(duration: 0.35)) {
                posts = next
                isLoading = false
            }
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    private func like(_ post: Post) {
        guard let index = posts.firstIndex(where: { $0.id == post.id }) else { return }
        var optimistic = posts[index]
        optimistic.likedByMe.toggle()
        optimistic.likeCount = max(0, optimistic.likeCount + (optimistic.likedByMe ? 1 : -1))
        withAnimation(.snappy(duration: 0.24)) { posts[index] = optimistic }

        Task {
            do {
                let updated = try await session.api.toggleLike(postID: post.id)
                await MainActor.run {
                    if let updateIndex = posts.firstIndex(where: { $0.id == post.id }) {
                        withAnimation(.snappy(duration: 0.2)) { posts[updateIndex] = updated }
                    }
                }
            } catch {
                await MainActor.run {
                    if let rollbackIndex = posts.firstIndex(where: { $0.id == post.id }) {
                        withAnimation(.snappy(duration: 0.2)) { posts[rollbackIndex] = post }
                    }
                    session.showToast(error.localizedDescription, systemImage: "exclamationmark.triangle.fill")
                }
            }
        }
    }

    private func createPost(caption: String, mediaUrls: [String]) async {
        do {
            let created = try await session.api.createPost(caption: caption, mediaUrls: mediaUrls)
            withAnimation(.smooth(duration: 0.35)) {
                posts.insert(created, at: 0)
            }
            session.showToast("Posted to your feed", systemImage: "paperplane.fill")
        } catch {
            session.showToast(error.localizedDescription, systemImage: "exclamationmark.triangle.fill")
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
    @EnvironmentObject private var session: AppSession
    @State private var post: Post
    @State private var commentText = ""
    @State private var isLoading = false

    init(post: Post) {
        _post = State(initialValue: post)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                RemoteImage(url: post.imageUrl, cornerRadius: 32)
                    .frame(height: 360)
                    .clipped()
                    .overlay(alignment: .bottomLeading) {
                        VStack(alignment: .leading, spacing: 7) {
                            Text("@\(post.author.username)")
                                .font(.system(size: 13, weight: .heavy))
                                .foregroundStyle(ScubaTheme.primary)
                            Text(post.content)
                                .font(.system(size: 22, weight: .black))
                                .foregroundStyle(ScubaTheme.ink)
                                .lineSpacing(3)
                        }
                        .padding(18)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(LinearGradient(colors: [.clear, .black.opacity(0.72)], startPoint: .top, endPoint: .bottom))
                    }

                HStack(spacing: 10) {
                    ScubaButton(title: "\(post.likeCount) likes", systemImage: post.likedByMe ? "heart.fill" : "heart", style: .quiet) {
                        like()
                    }
                    ScubaButton(title: "\(post.commentCount) comments", systemImage: "bubble.left.fill", style: .quiet) {}
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

                    if post.comments.isEmpty {
                        EmptyStateView(title: "No comments", message: "Start the conversation.", systemImage: "bubble.left")
                    } else {
                        ForEach(post.comments) { comment in
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
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        if let detail = try? await session.api.postDetail(id: post.id) {
            withAnimation(.smooth(duration: 0.25)) { post = detail }
        }
    }

    private func like() {
        let previous = post
        post.likedByMe.toggle()
        post.likeCount = max(0, post.likeCount + (post.likedByMe ? 1 : -1))
        Task {
            do {
                post = try await session.api.toggleLike(postID: previous.id)
            } catch {
                post = previous
                session.showToast(error.localizedDescription, systemImage: "exclamationmark.triangle.fill")
            }
        }
    }

    private func addComment() {
        guard let text = commentText.nilIfBlank else { return }
        commentText = ""
        Task {
            do {
                post = try await session.api.addComment(postID: post.id, body: text)
            } catch {
                session.showToast(error.localizedDescription, systemImage: "exclamationmark.triangle.fill")
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
