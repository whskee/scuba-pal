import SwiftUI

struct PostDetailView: View {
    @EnvironmentObject private var appUI: AppUIStore
    @StateObject private var viewModel: PostDetailViewModel
    @State private var commentText = ""
    private let dependencies: AppDependencies

    init(post: Post, dependencies: AppDependencies = .live) {
        self.dependencies = dependencies
        _viewModel = StateObject(
            wrappedValue: PostDetailViewModel(post: post, repository: dependencies.feedRepository)
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                hero
                actionBar
                commentsSection
            }
            .padding(18)
            .padding(.bottom, 86)
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Post")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: User.self) { user in
            ProfileView(userID: user.id, seedUser: user, dependencies: dependencies)
        }
        .task { await loadDetail() }
    }

    private var hero: some View {
        RemoteImage(url: viewModel.post.imageUrl, cornerRadius: 32)
            .frame(height: 360)
            .clipped()
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 7) {
                    NavigationLink(value: viewModel.post.author) {
                        HStack(spacing: 8) {
                            AvatarView(user: viewModel.post.author, size: 34)
                            Text("@\(viewModel.post.author.username)")
                                .font(.system(size: 13, weight: .heavy))
                                .foregroundStyle(ScubaTheme.primary)
                        }
                    }
                    .buttonStyle(ScaleButtonStyle())
                    Text(viewModel.post.content)
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(ScubaTheme.ink)
                        .lineSpacing(3)
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(LinearGradient(colors: [.clear, .black.opacity(0.72)], startPoint: .top, endPoint: .bottom))
            }
    }

    private var actionBar: some View {
        HStack(spacing: 10) {
            ScubaButton(title: "\(viewModel.post.likeCount) likes", systemImage: viewModel.post.likedByMe ? "heart.fill" : "heart", style: .quiet) {
                like()
            }
            ScubaButton(title: "\(viewModel.post.commentCount) comments", systemImage: "bubble.left.fill", style: .quiet) {}
        }
    }

    private var commentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Comments")
                .font(.system(size: 22, weight: .black))
                .foregroundStyle(ScubaTheme.ink)

            HStack(spacing: 10) {
                FloatingTextField(title: "Add a comment", text: $commentText, systemImage: "bubble.left.fill")
                Button(action: addComment) {
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
                    CommentRow(comment: comment)
                }
            }
        }
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

private struct CommentRow: View {
    let comment: Comment

    var body: some View {
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
