import SwiftUI

struct FeedView: View {
    @EnvironmentObject private var session: SessionStore
    @EnvironmentObject private var badges: BadgeStore
    @EnvironmentObject private var appUI: AppUIStore
    @StateObject private var viewModel: FeedViewModel
    @State private var activeFilter = "For you"

    private let dependencies: AppDependencies
    private let filters = ["For you", "Local", "Buddies", "Gear", "Training"]

    init(dependencies: AppDependencies = .live) {
        self.dependencies = dependencies
        _viewModel = StateObject(wrappedValue: FeedViewModel(repository: dependencies.feedRepository))
    }

    var body: some View {
        ZStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    FeedHeaderView(
                        postCount: viewModel.posts.count,
                        unreadMessages: badges.unreadMessages,
                        unreadNotifications: badges.unreadNotifications,
                        onLearnTapped: showLearnToast
                    )
                    FeedFilterRail(filters: filters, activeFilter: $activeFilter)
                    FeedContentView(
                        state: viewModel.state,
                        onLike: like,
                        onSave: showSavedToast
                    )
                }
                .padding(.top, 8)
                .padding(.bottom, 124)
            }
            .refreshable { await loadFeed(showLoading: false) }
            .scrollIndicators(.hidden)

            FloatingComposeButton(user: session.currentUser) { caption, urls in
                await createPost(caption: caption, mediaUrls: urls)
            }
        }
        .navigationDestination(for: Post.self) { post in
            PostDetailView(post: post, dependencies: dependencies)
        }
        .navigationDestination(for: User.self) { user in
            ProfileView(userID: user.id, seedUser: user, dependencies: dependencies)
        }
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
