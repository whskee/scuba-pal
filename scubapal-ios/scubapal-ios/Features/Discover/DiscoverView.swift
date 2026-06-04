import SwiftUI

enum DiscoverFilter: String, CaseIterable, Identifiable {
    case profiles = "Profiles"
    case shops = "Shops"
    case locations = "Locations"
    case learn = "Learn"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .profiles: "person.2.fill"
        case .shops: "storefront.fill"
        case .locations: "map.fill"
        case .learn: "graduationcap.fill"
        }
    }
}

struct DiscoverView: View {
    @EnvironmentObject private var session: SessionStore
    @StateObject private var viewModel: DiscoverViewModel
    @State private var searchText = ""
    @State private var activeFilter: DiscoverFilter = .profiles

    init(
        discoverRepository: DiscoverRepository = AppEnvironment.live.discoverRepository,
        profileRepository: ProfileRepository = AppEnvironment.live.profileRepository
    ) {
        _viewModel = StateObject(
            wrappedValue: DiscoverViewModel(
                discoverRepository: discoverRepository,
                profileRepository: profileRepository
            )
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                FloatingTextField(title: placeholder, text: $searchText, systemImage: "magnifyingglass")
                    .padding(.horizontal, 18)
                filterPicker
                content
            }
            .padding(.top, 14)
            .padding(.bottom, 104)
        }
        .scrollIndicators(.hidden)
        .navigationDestination(for: User.self) { user in
            ProfileView(userID: user.id, seedUser: user)
        }
        .task(id: activeFilter) { await loadCurrent() }
        .task(id: searchText) {
            try? await Task.sleep(for: .milliseconds(260))
            guard !Task.isCancelled else { return }
            await loadCurrent()
        }
    }

    private var header: some View {
        BrandedScreenHeader(
            title: "Discover",
            eyebrow: "Explore",
            subtitle: "Find divers, shops, locations, and skills without leaving the flow.",
            systemImage: "safari.fill"
        ) {
            Image(systemName: activeFilter.icon)
                .font(.system(size: 19, weight: .black))
                .foregroundStyle(ScubaTheme.darkText)
                .frame(width: 44, height: 44)
                .background(ScubaTheme.reefGradient, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    private var filterPicker: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 10) {
                ForEach(DiscoverFilter.allCases) { filter in
                    Button {
                        withAnimation(.snappy(duration: 0.22)) { activeFilter = filter }
                    } label: {
                        Label(filter.rawValue, systemImage: filter.icon)
                            .font(.system(size: 13, weight: .heavy))
                            .foregroundStyle(activeFilter == filter ? ScubaTheme.darkText : ScubaTheme.ink)
                            .padding(.horizontal, 13)
                            .frame(height: 42)
                            .background(activeFilter == filter ? ScubaTheme.primary : ScubaTheme.surface.opacity(0.8), in: Capsule())
                            .overlay(Capsule().stroke(activeFilter == filter ? ScubaTheme.primary : ScubaTheme.border, lineWidth: 1))
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
            .padding(.horizontal, 18)
        }
        .scrollIndicators(.hidden)
    }

    @ViewBuilder
    private var content: some View {
        switch activeFilter {
        case .profiles:
            resultList(viewModel.profiles, empty: "No profiles found") { user in
                NavigationLink(value: user) {
                    UserResultRow(user: user)
                }
                .buttonStyle(ScaleButtonStyle())
            }
        case .shops:
            resultList(viewModel.shops, empty: "No shops found") { shop in
                PlaceResultRow(title: shop.name, subtitle: [shop.city, shop.state, shop.country].compactMap { $0 }.joined(separator: ", "), description: shop.description, imageURL: shop.imageUrl, systemImage: "storefront.fill")
            }
        case .locations:
            resultList(viewModel.locations, empty: "No locations found") { location in
                PlaceResultRow(title: location.name, subtitle: [location.city, location.state, location.country].compactMap { $0 }.joined(separator: ", "), description: location.description, imageURL: location.imageUrl, systemImage: "mappin.and.ellipse")
            }
        case .learn:
            resultList(viewModel.lessons, empty: "No lessons yet") { article in
                LearnArticleCard(article: article)
            }
        }
    }

    private var placeholder: String {
        switch activeFilter {
        case .profiles: "Search username or name"
        case .shops: "Search shop, city, or location"
        case .locations: "Search city, country, or site"
        case .learn: "Search lessons"
        }
    }

    private func resultList<Value, Row: View>(_ state: Loadable<[Value]>, empty: String, @ViewBuilder row: @escaping (Value) -> Row) -> some View {
        VStack(spacing: 12) {
            switch state {
            case .idle, .loading:
                ProgressView()
                    .tint(ScubaTheme.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 26)
            case let .failed(message):
                EmptyStateView(title: "Could not search", message: message, systemImage: "wifi.exclamationmark")
            case let .loaded(items):
                if items.isEmpty {
                    EmptyStateView(title: empty, message: searchText.nilIfBlank == nil ? "Pull a broader term into search." : "Try a different query.", systemImage: "magnifyingglass")
                } else {
                    ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                        row(item)
                    }
                }
            }
        }
        .padding(.horizontal, 18)
    }

    private func loadCurrent() async {
        await viewModel.load(
            filter: activeFilter,
            query: searchText,
            currentUserID: session.currentUser?.id
        )
    }
}

private struct UserResultRow: View {
    var user: User

    var body: some View {
        HStack(spacing: 13) {
            AvatarView(user: user, size: 56)
            VStack(alignment: .leading, spacing: 5) {
                Text("@\(user.username)")
                    .font(.system(size: 16, weight: .black))
                    .foregroundStyle(ScubaTheme.ink)
                    .lineLimit(1)
                Text(user.displayName == "@\(user.username)" ? (user.bio ?? "Scuba Pal diver") : user.displayName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(ScubaTheme.muted)
                    .lineLimit(1)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .heavy))
                .foregroundStyle(ScubaTheme.muted)
        }
        .padding(14)
        .glassPanel(radius: 24, fill: ScubaTheme.surface.opacity(0.62))
    }
}

private struct PlaceResultRow: View {
    var title: String
    var subtitle: String
    var description: String?
    var imageURL: URL?
    var systemImage: String

    var body: some View {
        HStack(spacing: 13) {
            if imageURL != nil {
                RemoteImage(url: imageURL, cornerRadius: 18)
                    .frame(width: 72, height: 72)
            } else {
                Image(systemName: systemImage)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(ScubaTheme.primary)
                    .frame(width: 72, height: 72)
                    .background(ScubaTheme.surface2.opacity(0.72), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.system(size: 16, weight: .black))
                    .foregroundStyle(ScubaTheme.ink)
                    .lineLimit(1)
                Text(subtitle.isEmpty ? "Dive resource" : subtitle)
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundStyle(ScubaTheme.primary)
                    .lineLimit(1)
                if let description, !description.isEmpty {
                    Text(description)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(ScubaTheme.muted)
                        .lineLimit(2)
                }
            }
            Spacer()
        }
        .padding(14)
        .glassPanel(radius: 24, fill: ScubaTheme.surface.opacity(0.62))
    }
}

struct LearnArticleCard: View {
    var article: LearnArticle

    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack {
                Label(article.category, systemImage: "graduationcap.fill")
                    .font(.system(size: 12, weight: .black))
                    .foregroundStyle(ScubaTheme.primary)
                    .lineLimit(1)
                Spacer()
                Text("\(article.estimatedMinutes) min")
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundStyle(ScubaTheme.muted)
            }
            Text(article.title)
                .font(.system(size: 20, weight: .black))
                .foregroundStyle(ScubaTheme.ink)
            Text(article.summary)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(ScubaTheme.muted)
                .lineSpacing(3)
            Text(article.content)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(ScubaTheme.ink.opacity(0.88))
                .lineSpacing(4)
                .lineLimit(5)
            Text(article.difficultyLevel)
                .font(.system(size: 12, weight: .black))
                .foregroundStyle(ScubaTheme.darkText)
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(ScubaTheme.sand, in: Capsule())
        }
        .padding(16)
        .glassPanel(radius: 24, fill: ScubaTheme.surface.opacity(0.62))
    }
}
