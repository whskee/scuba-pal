import Combine
import Foundation

@MainActor
final class NotificationsViewModel: ObservableObject {
    @Published private(set) var state: Loadable<[AppNotification]> = .idle

    private let repository: NotificationsRepository

    init(repository: NotificationsRepository) {
        self.repository = repository
    }

    func load() async {
        state = .loading
        do {
            let items = try await repository.notifications()
            state = .loaded(items)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func markRead(_ item: AppNotification) async -> String? {
        guard !item.read else { return nil }
        if var current = state.value, let index = current.firstIndex(where: { $0.id == item.id }) {
            current[index].read = true
            state = .loaded(current)
        }
        do {
            try await repository.markRead(id: item.id)
            return nil
        } catch {
            if var current = state.value, let index = current.firstIndex(where: { $0.id == item.id }) {
                current[index] = item
                state = .loaded(current)
            }
            return error.localizedDescription
        }
    }
}
