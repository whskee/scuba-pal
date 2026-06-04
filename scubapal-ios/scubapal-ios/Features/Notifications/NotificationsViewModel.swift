import Combine
import SwiftUI

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
            withAnimation(.smooth(duration: 0.28)) { state = .loaded(items) }
        } catch {
            withAnimation(.smooth(duration: 0.2)) { state = .failed(error.localizedDescription) }
        }
    }

    func markRead(_ item: AppNotification) async -> String? {
        guard !item.read else { return nil }
        if var current = state.value, let index = current.firstIndex(where: { $0.id == item.id }) {
            current[index].read = true
            withAnimation(.snappy(duration: 0.2)) { state = .loaded(current) }
        }
        do {
            try await repository.markRead(id: item.id)
            return nil
        } catch {
            if var current = state.value, let index = current.firstIndex(where: { $0.id == item.id }) {
                current[index] = item
                withAnimation(.snappy(duration: 0.2)) { state = .loaded(current) }
            }
            return error.localizedDescription
        }
    }
}
