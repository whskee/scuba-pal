import SwiftUI

struct NotificationsView: View {
    @EnvironmentObject private var badges: BadgeStore
    @EnvironmentObject private var appUI: AppUIStore
    @StateObject private var viewModel: NotificationsViewModel

    init(dependencies: AppDependencies = .live) {
        _viewModel = StateObject(wrappedValue: NotificationsViewModel(repository: dependencies.notificationsRepository))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                BrandedScreenHeader(
                    title: "Notifications",
                    eyebrow: "Activity",
                    subtitle: "Follows, messages, likes, and comments from your dive circle.",
                    systemImage: "bell.badge.fill"
                ) {
                    IconCircleButton(systemImage: "arrow.clockwise", badge: badges.unreadNotifications) {
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
            LoadableCollectionView(
                state: viewModel.state,
                errorTitle: "Alerts unavailable"
            ) {
                EmptyStateView(title: "No notifications", message: "Follows, messages, likes, and comments will appear here.", systemImage: "bell")
            } content: { items in
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
        .padding(.horizontal, 18)
    }

    private func load() async {
        await viewModel.load()
        await badges.refresh()
    }

    private func markRead(_ item: AppNotification) {
        Task {
            if let error = await viewModel.markRead(item) {
                appUI.showToast(error, systemImage: "exclamationmark.triangle.fill")
            }
            await badges.refresh()
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
        .glassPanel(
            radius: 26,
            fill: notification.read ? ScubaTheme.surface.opacity(0.62) : ScubaTheme.surface2.opacity(0.68),
            border: notification.read ? ScubaTheme.border : ScubaTheme.primary.opacity(0.5)
        )
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
