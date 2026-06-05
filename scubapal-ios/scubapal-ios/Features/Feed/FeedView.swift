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
                FeedHeaderView(
                    postCount: viewModel.posts.count,
                    unreadMessages: badges.unreadMessages,
                    unreadNotifications: badges.unreadNotifications,
                    onLearnTapped: showLearnToast
                )
                FeedFilterRail(filters: filters, activeFilter: $activeFilter)
                ComposePromptView(user: session.currentUser) {
                    showingComposer = true
                }
                FeedContentView(
                    state: viewModel.state,
                    posts: viewModel.posts,
                    onLike: like,
                    onSave: showSavedToast
                )
            }
            .padding(.top, 14)
            .padding(.bottom, 104)
        }
        .refreshable { await loadFeed(showLoading: false) }
        .scrollIndicators(.hidden)
        .navigationDestination(for: Post.self) { post in
            PostDetailView(post: post)
        }
        .navigationDestination(for: User.self) { user in
            ProfileView(userID: user.id, seedUser: user)
        }
        .sheet(isPresented: $showingComposer) {
            CreatePostSheet { caption, urls in
                await createPost(caption: caption, mediaUrls: urls)
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .animation(.smooth(duration: 0.35), value: viewModel.posts)
        .animation(.smooth(duration: 0.2), value: viewModel.state.errorMessage)
        .task { await loadFeed(showLoading: viewModel.posts.isEmpty) }
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

    private func showLearnToast() {
        appUI.showToast("Learn is available from Discover", systemImage: "graduationcap.fill")
    }

    private func showSavedToast() {
        appUI.showToast("Saved for later", systemImage: "bookmark.fill")
    }
}
