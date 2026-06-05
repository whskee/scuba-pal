import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case feed
    case discover
    case messages
    case notifications
    case profile

    var id: String { rawValue }

    var title: String {
        switch self {
        case .feed: "Feed"
        case .discover: "Discover"
        case .messages: "Messages"
        case .notifications: "Alerts"
        case .profile: "Profile"
        }
    }

    var icon: String {
        switch self {
        case .feed: "water.waves"
        case .discover: "safari"
        case .messages: "message"
        case .notifications: "bell.badge"
        case .profile: "person.crop.circle"
        }
    }

    var filledIcon: String {
        switch self {
        case .feed: "water.waves"
        case .discover: "safari.fill"
        case .messages: "message.fill"
        case .notifications: "bell.fill"
        case .profile: "person.crop.circle.fill"
        }
    }
}

struct AppShellView: View {
    @EnvironmentObject private var badges: BadgeStore
    let dependencies: AppDependencies
    @State private var selectedTab: AppTab = .feed

    init(dependencies: AppDependencies = .live) {
        self.dependencies = dependencies
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                FeedView(dependencies: dependencies)
            }
            .tag(AppTab.feed)

            NavigationStack {
                DiscoverView(dependencies: dependencies)
            }
            .tag(AppTab.discover)

            NavigationStack {
                ConversationsView(dependencies: dependencies)
            }
            .tag(AppTab.messages)

            NavigationStack {
                NotificationsView(dependencies: dependencies)
            }
            .tag(AppTab.notifications)

            NavigationStack {
                ProfileView(dependencies: dependencies)
            }
            .tag(AppTab.profile)
        }
        .tint(ScubaTheme.primary)
        .overlay(alignment: .bottom) {
            CustomTabBar(selectedTab: $selectedTab)
                .padding(.horizontal, 18)
                .padding(.bottom, 10)
        }
        .toolbar(.hidden, for: .tabBar)
        .task {
            await badges.refresh()
        }
    }
}

private struct CustomTabBar: View {
    @EnvironmentObject private var badges: BadgeStore
    @Binding var selectedTab: AppTab
    @Namespace private var tabNamespace

    var body: some View {
        HStack(spacing: 6) {
            ForEach(AppTab.allCases) { tab in
                Button {
                    withAnimation(.snappy(duration: 0.24)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 5) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: selectedTab == tab ? tab.filledIcon : tab.icon)
                                .font(.system(size: 20, weight: .bold))
                                .symbolEffect(.bounce, value: selectedTab == tab)
                            if badge(for: tab) > 0 {
                                Text(badge(for: tab) > 99 ? "99+" : "\(badge(for: tab))")
                                    .font(.system(size: 9, weight: .black))
                                    .foregroundStyle(ScubaTheme.darkText)
                                    .padding(.horizontal, 4)
                                    .frame(minWidth: 16, minHeight: 16)
                                    .background(ScubaTheme.primary, in: Capsule())
                                    .offset(x: 9, y: -7)
                            }
                        }
                        Text(tab.title)
                            .font(.system(size: 10.5, weight: .heavy))
                            .lineLimit(1)
                    }
                    .foregroundStyle(selectedTab == tab ? ScubaTheme.reef : ScubaTheme.muted)
                    .frame(maxWidth: .infinity)
                    .frame(height: 58)
                    .background {
                        if selectedTab == tab {
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(ScubaTheme.primary.opacity(0.16))
                                .matchedGeometryEffect(id: "tab-selection", in: tabNamespace)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .stroke(ScubaTheme.primary.opacity(0.2), lineWidth: 1)
                                )
                        }
                    }
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
        .padding(7)
        .background(ScubaTheme.background.opacity(0.64), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(LinearGradient(colors: [ScubaTheme.primary.opacity(0.28), ScubaTheme.secondary.opacity(0.16), Color.white.opacity(0.08)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.42), radius: 26, x: 0, y: 14)
    }

    private func badge(for tab: AppTab) -> Int {
        switch tab {
        case .messages: badges.unreadMessages
        case .notifications: badges.unreadNotifications
        default: 0
        }
    }
}
