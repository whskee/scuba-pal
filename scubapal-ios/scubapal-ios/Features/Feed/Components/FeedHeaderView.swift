import SwiftUI

struct FeedHeaderView: View {
    let postCount: Int
    let unreadMessages: Int
    let unreadNotifications: Int
    let onLearnTapped: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            BrandedScreenHeader(
                title: "Dive feed",
                eyebrow: "Scuba Pal",
                subtitle: "Stories, buddy moments, gear finds, and ocean notes from your circle.",
                systemImage: "water.waves"
            ) {
                IconCircleButton(systemImage: "graduationcap.fill", action: onLearnTapped)
            }

            HStack(spacing: 10) {
                StatChip(value: "\(postCount)", label: "posts")
                StatChip(value: "\(unreadMessages)", label: "chats")
                StatChip(value: "\(unreadNotifications)", label: "alerts")
            }
            .padding(.horizontal, 18)
        }
    }
}

private struct StatChip: View {
    let value: String
    let label: String

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
