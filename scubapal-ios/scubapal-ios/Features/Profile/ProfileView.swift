import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var session: SessionStore
    @EnvironmentObject private var badges: BadgeStore
    @EnvironmentObject private var appUI: AppUIStore
    var userID: Int?
    var seedUser: User?

    @StateObject private var viewModel: ProfileViewModel
    @State private var showingEditor = false
    @State private var navigateConversation: Conversation?
    private let dependencies: AppDependencies

    init(
        userID: Int? = nil,
        seedUser: User? = nil,
        dependencies: AppDependencies = .live
    ) {
        self.userID = userID
        self.seedUser = seedUser
        self.dependencies = dependencies
        _viewModel = StateObject(
            wrappedValue: ProfileViewModel(
                profileRepository: dependencies.profileRepository,
                messagingRepository: dependencies.messagingRepository
            )
        )
    }

    private var isMine: Bool {
        userID == nil || userID == session.currentUser?.id
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                content
            }
            .padding(.top, 14)
            .padding(.bottom, 104)
        }
        .scrollIndicators(.hidden)
        .navigationDestination(item: $navigateConversation) { conversation in
            ThreadView(conversation: conversation, dependencies: dependencies)
        }
        .sheet(isPresented: $showingEditor) {
            if let loaded = viewModel.user.value {
                EditProfileSheet(user: loaded) { update in
                    await updateProfile(update)
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
        }
        .task { await load() }
    }

    @ViewBuilder
    private var header: some View {
        BrandedScreenHeader(
            title: isMine ? "Profile" : "Diver",
            eyebrow: isMine ? "Your identity" : "Dive profile",
            subtitle: isMine ? "Your ocean identity, stats, and public story." : "Profile, stats, and contact actions.",
            systemImage: "person.crop.circle.fill"
        ) {
            if isMine {
                IconCircleButton(systemImage: "rectangle.portrait.and.arrow.right") {
                    Task { await session.logout() }
                }
            } else {
                BrandMarkView(size: 44)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        VStack(spacing: 14) {
            LoadableValueView(
                state: viewModel.user,
                errorTitle: "Profile unavailable",
                errorSystemImage: "person.crop.circle.badge.exclamationmark"
            ) { user in
                ProfileSummaryCard(user: user)
                ProfileActionRow(
                    user: user,
                    isMine: isMine,
                    isMutating: viewModel.isMutating,
                    onEdit: showEditor,
                    onRefresh: refreshProfile,
                    onFollow: { follow(user) },
                    onMessage: { message(user) }
                )
                ProfileAboutCard(user: user)
            }
        }
        .padding(.horizontal, 18)
    }

    private func load() async {
        await viewModel.load(
            isMine: isMine,
            userID: userID,
            seedUser: seedUser,
            currentUser: session.currentUser
        )
        if isMine, let loaded = viewModel.user.value {
            session.updateStoredUser(loaded)
        }
    }

    private func showEditor() {
        showingEditor = true
    }

    private func refreshProfile() {
        Task { await load() }
    }

    private func follow(_ user: User) {
        Task {
            if let error = await viewModel.follow(user) {
                appUI.showToast(error, systemImage: "exclamationmark.triangle.fill")
            }
        }
    }

    private func message(_ user: User) {
        Task {
            switch await viewModel.startConversation(with: user) {
            case let .success(conversation):
                navigateConversation = conversation
                await badges.refresh()
            case let .failure(error):
                appUI.showToast(error.userFacingMessage, systemImage: "exclamationmark.triangle.fill")
            }
        }
    }

    private func updateProfile(_ update: ProfileUpdate) async {
        switch await viewModel.updateProfile(update) {
        case let .success(updated):
            session.updateStoredUser(updated)
            appUI.showToast("Profile updated", systemImage: "checkmark.circle.fill")
        case let .failure(error):
            appUI.showToast(error.userFacingMessage, systemImage: "exclamationmark.triangle.fill")
        }
    }
}
