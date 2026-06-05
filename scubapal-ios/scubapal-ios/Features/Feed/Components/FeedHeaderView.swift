import SwiftUI

struct FeedHeaderView: View {
    let postCount: Int
    let unreadMessages: Int
    let unreadNotifications: Int
    let onLearnTapped: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Dive lounge")
                    .font(.system(size: 26, weight: .black))
                    .foregroundStyle(ScubaTheme.ink)
                    .lineLimit(1)
                Text("\(postCount) posts  /  \(unreadMessages) chats  /  \(unreadNotifications) alerts")
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundStyle(ScubaTheme.muted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
            }
            Spacer()
            IconCircleButton(systemImage: "book.pages.fill", action: onLearnTapped)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 8)
    }
}
