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

    init(
        userID: Int? = nil,
        seedUser: User? = nil,
        profileRepository: ProfileRepository = AppEnvironment.live.profileRepository,
        messagingRepository: MessagingRepository = AppEnvironment.live.messagingRepository
    ) {
        self.userID = userID
        self.seedUser = seedUser
        _viewModel = StateObject(
            wrappedValue: ProfileViewModel(
                profileRepository: profileRepository,
                messagingRepository: messagingRepository
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
            ThreadView(conversation: conversation)
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
            switch viewModel.user {
            case .idle, .loading:
                ProgressView()
                    .tint(ScubaTheme.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 32)
            case let .failed(message):
                EmptyStateView(title: "Profile unavailable", message: message, systemImage: "person.crop.circle.badge.exclamationmark")
            case let .loaded(user):
                profileCard(user)
                actionRow(user)
                aboutCard(user)
            }
        }
        .padding(.horizontal, 18)
    }

    private func profileCard(_ user: User) -> some View {
        VStack(spacing: 18) {
            HStack(alignment: .center, spacing: 16) {
                AvatarView(user: user, size: 104)
                VStack(alignment: .leading, spacing: 8) {
                    Text(user.displayName)
                        .font(.system(size: 25, weight: .black))
                        .foregroundStyle(ScubaTheme.ink)
                        .lineLimit(2)
                    Text("@\(user.username)")
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundStyle(ScubaTheme.primary)
                    if let place = [user.city, user.state, user.country].compactMap({ $0 }).nilIfEmpty?.joined(separator: ", ") {
                        Label(place, systemImage: "location.fill")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(ScubaTheme.muted)
                            .lineLimit(1)
                    }
                }
                Spacer()
            }

            HStack(spacing: 10) {
                ProfileStat(value: "\(user.followersCount)", label: "followers")
                ProfileStat(value: "\(user.followingCount)", label: "following")
                ProfileStat(value: "\(user.diveCount)", label: "dives")
            }
        }
        .padding(18)
        .glassPanel(radius: 32, fill: ScubaTheme.surface.opacity(0.68), border: ScubaTheme.primary.opacity(0.2))
    }

    @ViewBuilder
    private func actionRow(_ user: User) -> some View {
        if isMine {
            HStack(spacing: 10) {
                ScubaButton(title: "Edit profile", systemImage: "pencil", style: .primary) {
                    showingEditor = true
                }
                ScubaButton(title: "Refresh", systemImage: "arrow.clockwise", style: .quiet) {
                    Task { await load() }
                }
            }
        } else {
            HStack(spacing: 10) {
                ScubaButton(title: user.followedByMe ? "Following" : "Follow", systemImage: user.followedByMe ? "checkmark.circle.fill" : "person.badge.plus.fill", isLoading: viewModel.isMutating) {
                    follow(user)
                }
                ScubaButton(title: "Message", systemImage: "bubble.left.and.bubble.right.fill", style: .quiet, isLoading: viewModel.isMutating) {
                    message(user)
                }
            }
        }
    }

    private func aboutCard(_ user: User) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("About")
                .font(.system(size: 20, weight: .black))
                .foregroundStyle(ScubaTheme.ink)
            Text(user.bio?.nilIfBlank ?? "No bio yet.")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(ScubaTheme.muted)
                .lineSpacing(4)
            HStack(spacing: 8) {
                MiniTag(title: user.country ?? "Ocean")
                MiniTag(title: "\(user.diveCount) dives")
                MiniTag(title: user.followedByMe ? "Follows you" : "Scuba Pal")
            }
        }
        .padding(16)
        .glassPanel(radius: 24, fill: ScubaTheme.surface.opacity(0.58))
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
                appUI.showToast(error.localizedDescription, systemImage: "exclamationmark.triangle.fill")
            }
        }
    }

    private func updateProfile(_ update: ProfileUpdate) async {
        switch await viewModel.updateProfile(update) {
        case let .success(updated):
            session.updateStoredUser(updated)
            appUI.showToast("Profile updated", systemImage: "checkmark.circle.fill")
        case let .failure(error):
            appUI.showToast(error.localizedDescription, systemImage: "exclamationmark.triangle.fill")
        }
    }
}

private struct ProfileStat: View {
    var value: String
    var label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .black))
                .foregroundStyle(ScubaTheme.ink)
            Text(label)
                .font(.system(size: 11, weight: .heavy))
                .foregroundStyle(ScubaTheme.muted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(ScubaTheme.surface2.opacity(0.58), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct MiniTag: View {
    var title: String

    var body: some View {
        Text(title)
            .font(.system(size: 12, weight: .black))
            .foregroundStyle(ScubaTheme.ink)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(ScubaTheme.surface2.opacity(0.7), in: Capsule())
    }
}

private struct EditProfileSheet: View {
    @Environment(\.dismiss) private var dismiss
    var user: User
    var onSave: (ProfileUpdate) async -> Void

    @State private var firstName = ""
    @State private var lastName = ""
    @State private var city = ""
    @State private var state = ""
    @State private var country = ""
    @State private var bio = ""
    @State private var imageURL = ""
    @State private var diveCount = ""
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    FloatingTextField(title: "First name", text: $firstName, systemImage: "person.fill", textContentType: .givenName)
                    FloatingTextField(title: "Last name", text: $lastName, systemImage: "person.text.rectangle.fill", textContentType: .familyName)
                    FloatingTextField(title: "City", text: $city, systemImage: "building.2.fill")
                    FloatingTextField(title: "State", text: $state, systemImage: "map.fill")
                    FloatingTextField(title: "Country", text: $country, systemImage: "globe.americas.fill")
                    FloatingTextField(title: "Profile image URL", text: $imageURL, systemImage: "photo.fill", keyboardType: .URL)
                    FloatingTextField(title: "Dive count", text: $diveCount, systemImage: "number", keyboardType: .numberPad)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Bio")
                            .font(.system(size: 13, weight: .heavy))
                            .foregroundStyle(ScubaTheme.muted)
                        TextEditor(text: $bio)
                            .frame(minHeight: 120)
                            .scrollContentBackground(.hidden)
                            .foregroundStyle(ScubaTheme.ink)
                            .padding(10)
                            .background(ScubaTheme.surface.opacity(0.78), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(ScubaTheme.border, lineWidth: 1))
                    }
                    ScubaButton(title: "Save profile", systemImage: "checkmark.circle.fill", isLoading: isSaving) {
                        save()
                    }
                }
                .padding(20)
            }
            .appBackground()
            .navigationTitle("Edit profile")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                firstName = user.firstName ?? ""
                lastName = user.lastName ?? ""
                city = user.city ?? ""
                state = user.state ?? ""
                country = user.country ?? ""
                bio = user.bio ?? ""
                imageURL = user.profileImageUrl ?? ""
                diveCount = "\(user.diveCount)"
            }
        }
    }

    private func save() {
        isSaving = true
        let update = ProfileUpdate(
            firstName: firstName.nilIfBlank,
            lastName: lastName.nilIfBlank,
            phoneNumber: nil,
            city: city.nilIfBlank,
            state: state.nilIfBlank,
            country: country.nilIfBlank,
            bio: bio.nilIfBlank,
            diveCount: Int(diveCount),
            profileImageUrl: imageURL.nilIfBlank
        )
        Task {
            await onSave(update)
            isSaving = false
            dismiss()
        }
    }
}

private extension Array {
    var nilIfEmpty: [Element]? {
        isEmpty ? nil : self
    }
}
