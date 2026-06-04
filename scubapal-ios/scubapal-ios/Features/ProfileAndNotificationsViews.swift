import SwiftUI

struct NotificationsView: View {
    @EnvironmentObject private var session: AppSession
    @State private var notifications: Loadable<[AppNotification]> = .idle

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                BrandedScreenHeader(
                    title: "Notifications",
                    eyebrow: "Activity",
                    subtitle: "Follows, messages, likes, and comments from your dive circle.",
                    systemImage: "bell.badge.fill"
                ) {
                    IconCircleButton(systemImage: "arrow.clockwise", badge: session.unreadNotifications) {
                        Task { await load() }
                    }
                }

                content
            }
            .padding(.top, 14)
            .padding(.bottom, 104)
        }
        .scrollIndicators(.hidden)
        .refreshable { await load() }
        .task { await load() }
    }

    @ViewBuilder
    private var content: some View {
        VStack(spacing: 12) {
            switch notifications {
            case .idle, .loading:
                ProgressView()
                    .tint(ScubaTheme.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 32)
            case let .failed(message):
                EmptyStateView(title: "Alerts unavailable", message: message, systemImage: "wifi.exclamationmark")
            case let .loaded(items):
                if items.isEmpty {
                    EmptyStateView(title: "No notifications", message: "Follows, messages, likes, and comments will appear here.", systemImage: "bell")
                } else {
                    ForEach(items) { item in
                        Button {
                            markRead(item)
                        } label: {
                            NotificationRow(notification: item)
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                }
            }
        }
        .padding(.horizontal, 18)
    }

    private func load() async {
        notifications = .loading
        do {
            let items = try await session.api.notifications()
            withAnimation(.smooth(duration: 0.28)) { notifications = .loaded(items) }
            await session.refreshBadges()
        } catch {
            withAnimation(.smooth(duration: 0.2)) { notifications = .failed(error.localizedDescription) }
        }
    }

    private func markRead(_ item: AppNotification) {
        guard !item.read else { return }
        if var current = notifications.value, let index = current.firstIndex(where: { $0.id == item.id }) {
            current[index].read = true
            withAnimation(.snappy(duration: 0.2)) { notifications = .loaded(current) }
        }
        Task {
            try? await session.api.markNotificationRead(id: item.id)
            await session.refreshBadges()
        }
    }
}

private struct NotificationRow: View {
    var notification: AppNotification

    var body: some View {
        HStack(alignment: .top, spacing: 13) {
            Image(systemName: icon)
                .font(.system(size: 21, weight: .bold))
                .foregroundStyle(notification.read ? ScubaTheme.ink : ScubaTheme.darkText)
                .frame(width: 50, height: 50)
                .background(notification.read ? ScubaTheme.surface2.opacity(0.65) : ScubaTheme.primary, in: Circle())
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(notification.title)
                        .font(.system(size: 16, weight: .black))
                        .foregroundStyle(ScubaTheme.ink)
                    Spacer()
                    if !notification.read {
                        Circle()
                            .fill(ScubaTheme.primary)
                            .frame(width: 9, height: 9)
                    }
                }
                Text(notification.body)
                    .font(.system(size: 14, weight: notification.read ? .medium : .semibold))
                    .foregroundStyle(notification.read ? ScubaTheme.muted : ScubaTheme.ink.opacity(0.92))
                    .lineSpacing(3)
                Text(notification.createdAt.relativeShort())
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundStyle(ScubaTheme.muted)
            }
        }
        .padding(15)
        .glassPanel(radius: 26, fill: notification.read ? ScubaTheme.surface.opacity(0.62) : ScubaTheme.surface2.opacity(0.68), border: notification.read ? ScubaTheme.border : ScubaTheme.primary.opacity(0.5))
    }

    private var icon: String {
        let type = notification.type?.lowercased() ?? "\(notification.title) \(notification.body)".lowercased()
        if type.contains("message") { return "bubble.left.and.bubble.right.fill" }
        if type.contains("follow") { return "person.badge.plus.fill" }
        if type.contains("like") { return "heart.fill" }
        if type.contains("comment") { return "text.bubble.fill" }
        return "bell.fill"
    }
}

struct ProfileView: View {
    @EnvironmentObject private var session: AppSession
    var userID: Int?
    var seedUser: User?

    @State private var user: Loadable<User> = .idle
    @State private var showingEditor = false
    @State private var isMutating = false
    @State private var navigateConversation: Conversation?

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
            if let loaded = user.value {
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
            switch user {
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
                ScubaButton(title: user.followedByMe ? "Following" : "Follow", systemImage: user.followedByMe ? "checkmark.circle.fill" : "person.badge.plus.fill", isLoading: isMutating) {
                    follow(user)
                }
                ScubaButton(title: "Message", systemImage: "bubble.left.and.bubble.right.fill", style: .quiet, isLoading: isMutating) {
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
        if let seedUser, user.value == nil {
            user = .loaded(seedUser)
        } else {
            user = .loading
        }
        do {
            let loaded: User
            if isMine {
                loaded = (try? await session.api.currentProfile()) ?? session.currentUser ?? seedUser ?? User(id: 0, username: "diver", diveCount: 0, followersCount: 0, followingCount: 0, followedByMe: false)
            } else {
                loaded = try await session.api.profile(userID: userID ?? 0)
            }
            withAnimation(.smooth(duration: 0.28)) { user = .loaded(loaded) }
            if isMine { session.updateStoredUser(loaded) }
        } catch {
            withAnimation(.smooth(duration: 0.2)) { user = .failed(error.localizedDescription) }
        }
    }

    private func follow(_ user: User) {
        isMutating = true
        Task {
            do {
                let summary = try await session.api.follow(userID: user.id, shouldFollow: !user.followedByMe)
                var updated = user
                updated.followedByMe = summary.followedByCurrentUser ?? !user.followedByMe
                updated.followersCount = summary.followerCount ?? user.followersCount
                updated.followingCount = summary.followingCount ?? user.followingCount
                withAnimation(.snappy(duration: 0.22)) { self.user = .loaded(updated) }
            } catch {
                session.showToast(error.localizedDescription, systemImage: "exclamationmark.triangle.fill")
            }
            isMutating = false
        }
    }

    private func message(_ user: User) {
        isMutating = true
        Task {
            do {
                navigateConversation = try await session.api.startConversation(userID: user.id)
                await session.refreshBadges()
            } catch {
                session.showToast(error.localizedDescription, systemImage: "exclamationmark.triangle.fill")
            }
            isMutating = false
        }
    }

    private func updateProfile(_ update: UpsertProfileRequest) async {
        do {
            let updated = try await session.api.updateCurrentProfile(update)
            withAnimation(.smooth(duration: 0.28)) { user = .loaded(updated) }
            session.updateStoredUser(updated)
            session.showToast("Profile updated", systemImage: "checkmark.circle.fill")
        } catch {
            session.showToast(error.localizedDescription, systemImage: "exclamationmark.triangle.fill")
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
    var onSave: (UpsertProfileRequest) async -> Void

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
        let update = UpsertProfileRequest(
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
