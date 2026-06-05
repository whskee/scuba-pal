import Combine
import Foundation

@MainActor
final class DiscoverViewModel: ObservableObject {
    @Published private(set) var profiles: Loadable<[User]> = .idle
    @Published private(set) var shops: Loadable<[DiveShop]> = .idle
    @Published private(set) var locations: Loadable<[DiveLocation]> = .idle
    @Published private(set) var lessons: Loadable<[LearnArticle]> = .idle

    private let discoverRepository: DiscoverRepository
    private let profileRepository: ProfileRepository

    init(
        discoverRepository: DiscoverRepository,
        profileRepository: ProfileRepository
    ) {
        self.discoverRepository = discoverRepository
        self.profileRepository = profileRepository
    }

    func load(filter: DiscoverFilter, query: String, currentUserID: Int?) async {
        let term = query.trimmingCharacters(in: .whitespacesAndNewlines)
        do {
            switch filter {
            case .profiles:
                profiles = .loading
                let items = try await profileRepository.profiles(query: term)
                    .filter { $0.id != currentUserID }
                profiles = .loaded(items)
            case .shops:
                shops = .loading
                let items = try await discoverRepository.shops(query: term)
                shops = .loaded(items)
            case .locations:
                locations = .loading
                let items = try await discoverRepository.locations(query: term)
                locations = .loaded(items)
            case .learn:
                lessons = .loading
                let all = try await discoverRepository.learnArticles()
                let filtered = term.isEmpty ? all : all.filter {
                    [$0.title, $0.summary, $0.category, $0.difficultyLevel]
                        .joined(separator: " ")
                        .localizedCaseInsensitiveContains(term)
                }
                lessons = .loaded(filtered)
            }
        } catch {
            switch filter {
            case .profiles: profiles = .failed(error.localizedDescription)
            case .shops: shops = .failed(error.localizedDescription)
            case .locations: locations = .failed(error.localizedDescription)
            case .learn: lessons = .failed(error.localizedDescription)
            }
        }
    }
}
