import SwiftUI

struct ProfileSummaryCard: View {
    var user: User

    var body: some View {
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
                    if let place = locationText {
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

    private var locationText: String? {
        [user.city, user.state, user.country]
            .compactMap { $0 }
            .nilIfEmpty?
            .joined(separator: ", ")
    }
}

struct ProfileActionRow: View {
    var user: User
    var isMine: Bool
    var isMutating: Bool
    var onEdit: () -> Void
    var onRefresh: () -> Void
    var onFollow: () -> Void
    var onMessage: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            if isMine {
                ScubaButton(title: "Edit profile", systemImage: "pencil", style: .primary, action: onEdit)
                ScubaButton(title: "Refresh", systemImage: "arrow.clockwise", style: .quiet, action: onRefresh)
            } else {
                ScubaButton(
                    title: user.followedByMe ? "Following" : "Follow",
                    systemImage: user.followedByMe ? "checkmark.circle.fill" : "person.badge.plus.fill",
                    isLoading: isMutating,
                    action: onFollow
                )
                ScubaButton(
                    title: "Message",
                    systemImage: "bubble.left.and.bubble.right.fill",
                    style: .quiet,
                    isLoading: isMutating,
                    action: onMessage
                )
            }
        }
    }
}

struct ProfileAboutCard: View {
    var user: User

    var body: some View {
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
                MiniTag(title: user.followedByMe ? "Follows you" : "ScubaPal")
            }
        }
        .padding(16)
        .glassPanel(radius: 24, fill: ScubaTheme.surface.opacity(0.58))
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

private extension Array {
    var nilIfEmpty: [Element]? {
        isEmpty ? nil : self
    }
}
