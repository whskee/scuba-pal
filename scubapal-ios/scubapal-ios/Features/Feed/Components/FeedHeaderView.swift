import SwiftUI

struct FeedHeaderView: View {
    let postCount: Int
    let unreadMessages: Int
    let unreadNotifications: Int
    let onLearnTapped: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            BrandedScreenHeader(
                title: "Dive lounge",
                eyebrow: "ScubaPal",
                subtitle: "Polished logs, buddy moments, rare conditions, and the best finds from your circle.",
                systemImage: "sparkles"
            ) {
                IconCircleButton(systemImage: "book.pages.fill", action: onLearnTapped)
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
        .background(ScubaTheme.surface.opacity(0.62), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(ScubaTheme.secondary.opacity(0.14), lineWidth: 1)
        )
    }
}
